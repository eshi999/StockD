import 'dart:async';
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
  Timer? _healthTimer;

  @override
  BackendStatus build() {
    _startBackend();
    _startHealthCheck();

    ref.onDispose(() {
      _healthTimer?.cancel();
      stopBackend();
    });

    return BackendStatus.starting;
  }

  void _startHealthCheck() {
    // Poll the health endpoint every 3s to keep UI in sync with actual server state
    _healthTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final isAlive = await ref.read(sageServiceProvider).isBackendAlive();
      if (isAlive && state != BackendStatus.online) {
        state = BackendStatus.online;
      } else if (!isAlive && state == BackendStatus.online) {
        state = BackendStatus.offline;
      }
    });
  }

  Future<void> _startBackend() async {
    // 1. Clear Port 8000 to prevent Error 10048 (Address already in use)
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/F', '/IM', 'python.exe', '/T']);
    } else {
      // Assuming fuser is available on Linux/macOS to free the port
      await Process.run('fuser', ['-k', '8000/tcp']);
    }

    try {
      final Map<String, String> secureEnv = Map<String, String>.from(Platform.environment);
      secureEnv["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python";

      if (kReleaseMode) {
        final String backendPath = _resolveBackendPath();
        debugPrint('SAGE: launching backend at $backendPath');

        if (!File(backendPath).existsSync()) {
          debugPrint('SAGE: launcher not found at $backendPath');
          state = BackendStatus.offline;
          return;
        }

        _process = await Process.start(
          backendPath,
          [],
          workingDirectory: p.dirname(backendPath),
          runInShell: true, // Crucial for executing .bat/.sh via shell
          environment: secureEnv,
        );
      } else {
        // Development: run via local Python environment
        _process = await Process.start(
          Platform.isWindows ? 'python' : 'python3',
          ['-m', 'uvicorn', 'main:app', '--port', '8000'],
          workingDirectory: _mlDir(),
          environment: secureEnv,
        );
      }

      // Log process output for debugging
      _process!.stdout.transform(const SystemEncoding().decoder).listen((line) => debugPrint('SAGE stdout: $line'));
      _process!.stderr.transform(const SystemEncoding().decoder).listen((line) => debugPrint('SAGE stderr: $line'));

    } catch (e) {
      debugPrint('SAGE: start failed: $e');
      state = BackendStatus.offline;
    }
  }

  void stopBackend() {
    _process?.kill();
    _process = null;
  }

  String _resolveBackendPath() {
    final String name = Platform.isWindows ? 'sage_launcher.bat' : 'sage_launcher.sh';
    // Matches the path in your build script: data/flutter_assets/backend_bundle
    return p.join(p.dirname(Platform.resolvedExecutable), 'data', 'flutter_assets', 'backend_bundle', name);
  }

  Future<void> retry() async {
    state = BackendStatus.starting;
    stopBackend();
    await Future.delayed(const Duration(seconds: 2));
    await _startBackend();
  }

  void skipToOffline() {
    stopBackend();
    state = BackendStatus.offline;
  }

  String _mlDir() {
    final exe = Platform.resolvedExecutable;
    Directory dir = File(exe).parent;
    for (int i = 0; i < 8; i++) {
      final ml = Directory(p.join(dir.path, 'ML'));
      if (ml.existsSync()) return ml.path;
      dir = dir.parent;
    }
    return '../ML';
  }
}

final backendProvider = NotifierProvider<BackendNotifier, BackendStatus>(
  BackendNotifier.new,
);

// ── SAGE Explanation Logic ──────────────────────────────────────────────────
class SageNotifier extends Notifier<SageExplanation?> {
  @override
  SageExplanation? build() => null;

  Future<void> explain({required StockQuestion question, required int userAnswerIndex}) async {
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