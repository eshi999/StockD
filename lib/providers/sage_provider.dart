import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/sage_service.dart';

// ── Backend Status ────────────────────────────────────────────────────────────
enum BackendStatus { starting, online, offline }

class BackendNotifier extends Notifier<BackendStatus> {
  Process? _process;

  @override
  BackendStatus build() {
    _startBackend();
    return BackendStatus.starting;
  }

  Future<void> _startBackend() async {
    final alive = await ref.read(sageServiceProvider).isBackendAlive();
    if (alive) {
      state = BackendStatus.online;
      return;
    }
    try {
      _process = await Process.start(
        'python3.12',
        ['-m', 'uvicorn', 'main:app', '--host', '0.0.0.0', '--port', '8000'],
        workingDirectory: _mlDir(),
        mode: ProcessStartMode.detachedWithStdio,
      );
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
    final exe    = Platform.resolvedExecutable;
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
          question:        question,
          userAnswerIndex: userAnswerIndex,
        );
    state = result;
  }

  void clear() => state = null;
}

final sageProvider = NotifierProvider<SageNotifier, SageExplanation?>(
  SageNotifier.new,
);
