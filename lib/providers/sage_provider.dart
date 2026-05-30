import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';
import '../services/sage_service.dart';

// ── Backend Status ────────────────────────────────────────────────────────────
enum BackendStatus { starting, online, offline }

class BackendNotifier extends Notifier<BackendStatus> {
  Process? _process;

  @override
  BackendStatus build() {
    _startBackend();
    ref.onDispose(() => stopBackend());
    return BackendStatus.starting;
  }

  void stopBackend() {
    _process?.kill();
    _process = null;
  }

  Future<void> _startBackend() async {
    // 1. Quick check if already online
    if (await ref.read(sageServiceProvider).isBackendAlive()) {
      state = BackendStatus.online;
      return;
    }

    try {
      if (kReleaseMode) {
        // PRODUCTION: Use the executable's directory as the anchor
        final String exeDir = p.dirname(Platform.resolvedExecutable);

        // Path matches the CI/CD injection location:
        // flutter_assets/backend_bundle/sage_backend/sage_backend(.exe)
        final String backendPath = p.join(
            exeDir,
            'data',
            'flutter_assets',
            'backend_bundle',
            'sage_backend',
            Platform.isWindows ? 'sage_backend.exe' : 'sage_backend');

        _process = await Process.start(
          backendPath,
          [],
          workingDirectory:
              p.dirname(backendPath), // Essential for finding Python libs
          mode: ProcessStartMode.normal,
        );
      } else {
        // DEVELOPMENT: Run via local Python shell
        _process = await Process.start(
          'python',
          ['-m', 'uvicorn', 'main:app', '--port', '8000'],
          workingDirectory: _mlDir(),
          mode: ProcessStartMode.normal,
        );
      }

      // 2. Poll for readiness
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (await ref.read(sageServiceProvider).isBackendAlive()) {
          state = BackendStatus.online;
          return;
        }
      }
      state = BackendStatus.offline;
    } catch (e) {
      debugPrint("Backend start failed: $e");
      state = BackendStatus.offline;
    }
  }

  Future<void> retry() async {
    state = BackendStatus.starting;
    await _startBackend();
  }

  void skipToOffline() => state = BackendStatus.offline;

  String _mlDir() {
    final exe = Platform.resolvedExecutable;
    final exeDir = File(exe).parent;
    Directory dir = exeDir;
    for (int i = 0; i < 8; i++) {
      final ml = Directory('${dir.path}/ML');
      if (ml.existsSync()) return ml.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return '../ML';
  }
}

final backendProvider = NotifierProvider<BackendNotifier, BackendStatus>(
  BackendNotifier.new,
);

// ── SAGE Explanation ──────────────────────────────────────────────────────────
class SageNotifier extends Notifier<SageExplanation?> {
  @override
  SageExplanation? build() => null;

  Future<void> explain({
    required StockQuestion question,
    required int userAnswerIndex,
  }) async {
    state = SageExplanation.loading(question.id);
    final result = await ref.read(sageServiceProvider).explainQuestion(
          question: question,
          userAnswerIndex: userAnswerIndex,
        );
    state = result;
  }

  void clear() => state = null;
}

final sageProvider = NotifierProvider<SageNotifier, SageExplanation?>(
  SageNotifier.new,
);
