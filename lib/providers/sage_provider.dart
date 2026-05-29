import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for kReleaseMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart'
    as p; // For cross-platform bundle path management
import '../models/models.dart';
import '../services/sage_service.dart';

// ── Backend Status ────────────────────────────────────────────────────────────
enum BackendStatus { starting, online, offline }

class BackendNotifier extends Notifier<BackendStatus> {
  Process? _process;

  @override
  BackendStatus build() {
    _startBackend();

    // Auto-cleanup hook if Riverpod manages to tear down the provider context
    ref.onDispose(() {
      stopBackend();
    });

    return BackendStatus.starting;
  }

  // ── NEW: Safely Kill Process (Resolves the main.dart compilation error) ──
  void stopBackend() {
    if (_process != null) {
      _process!.kill();
      _process = null;
    }
  }

  Future<void> _startBackend() async {
    final alive = await ref.read(sageServiceProvider).isBackendAlive();
    if (alive) {
      state = BackendStatus.online;
      return;
    }
    try {
      if (kReleaseMode) {
        // PRODUCTION: Run bundled PyInstaller standalone binary asset
        String executableName =
            Platform.isWindows ? 'sage_backend.exe' : 'sage_backend';
        String backendPath = p.join(Directory.current.path, 'data',
            'flutter_assets', 'backend_bundle', 'sage_backend', executableName);

        _process = await Process.start(
          backendPath,
          [],
          mode:
              ProcessStartMode.normal, // Ties lifecycle to host shell instance
        );
      } else {
        // DEVELOPMENT: Run via local Python shell execution environment
        _process = await Process.start(
          'python',
          ['-m', 'uvicorn', 'main:app', '--host', '0.0.0.0', '--port', '8000'],
          workingDirectory: _mlDir(),
          mode: ProcessStartMode
              .normal, // Changed from detached to allow clean kills
        );

        _process!.stdout.transform(SystemEncoding().decoder).listen((data) {
          debugPrint('🐍 PYTHON STDOUT: $data');
        });

        _process!.stderr.transform(SystemEncoding().decoder).listen((data) {
          debugPrint('❌ PYTHON STDERR: $data');
        });
      }

      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 1));
        final alive = await ref.read(sageServiceProvider).isBackendAlive();
        if (alive) {
          state = BackendStatus.online;
          return;
        }
      }
      state = BackendStatus.offline;
    } catch (_) {
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
