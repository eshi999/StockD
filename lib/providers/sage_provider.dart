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
    // Always kill any zombie process holding port 8000 before launching fresh
    if (await ref.read(sageServiceProvider).isBackendAlive()) {
      debugPrint('SAGE: port 8000 already active, killing before relaunch');
      stopBackend();
      await Future.delayed(const Duration(seconds: 2));
    }

    try {
      final Map<String, String> secureEnv =
          Map<String, String>.from(Platform.environment);
      secureEnv["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python";

      if (kReleaseMode) {
        final String backendPath = _resolveBackendPath();
        debugPrint('SAGE: launching backend at $backendPath');

        if (!File(backendPath).existsSync()) {
          debugPrint('SAGE: launcher script not found at $backendPath');
          state = BackendStatus.offline;
          return;
        }

        _process = await Process.start(
          backendPath,
          [],
          workingDirectory: p.dirname(backendPath),
          mode: ProcessStartMode.normal,
          environment: secureEnv,
          // Windows requires runInShell: true to execute .bat files properly
          runInShell: Platform.isWindows, 
        );
      } else {
        // Development: run via local Python
        _process = await Process.start(
          Platform.isWindows ? 'python' : 'python3',
          ['-m', 'uvicorn', 'main:app', '--port', '8000'],
          workingDirectory: _mlDir(),
          mode: ProcessStartMode.normal,
          environment: secureEnv,
        );
      }

      // Pipe stdout and stderr so all Python output surfaces in Flutter console
      _process!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((line) => debugPrint('SAGE stdout: $line'));
      _process!.stderr
          .transform(const SystemEncoding().decoder)
          .listen((line) => debugPrint('SAGE stderr: $line'));

      // Monitor for unexpected crashes after startup
      _process!.exitCode.then((code) {
        debugPrint('SAGE: process exited with code $code');
        if (state == BackendStatus.online) {
          state = BackendStatus.offline;
        }
        _process = null;
      });

      // Poll until backend responds — TF can take 90-120s on cold start
      for (int i = 0; i < 120; i++) {
        await Future.delayed(const Duration(seconds: 1));

        // Stop polling immediately if process already died
        if (_process == null) {
          debugPrint('SAGE: process died during startup');
          state = BackendStatus.offline;
          return;
        }

        if (await ref.read(sageServiceProvider).isBackendAlive()) {
          debugPrint('SAGE: online after ${i + 1}s');
          state = BackendStatus.online;
          return;
        }
      }

      debugPrint('SAGE: timed out after 120s');
      state = BackendStatus.offline;

    } catch (e) {
      debugPrint('SAGE: start failed: $e');
      state = BackendStatus.offline;
    }
  }

  String _resolveBackendPath() {
    // Match the exact output names from our CI/CD pipelines
    final String binaryName =
        Platform.isWindows ? 'sage_launcher.bat' : 'sage_launcher.sh';

    if (Platform.isLinux) {
      final String realExe =
          File(Platform.resolvedExecutable).resolveSymbolicLinksSync();
      final String bundleDir = p.join(
          p.dirname(realExe), 'data', 'flutter_assets', 'backend_bundle');
      return _pickPath(bundleDir, binaryName);

    } else if (Platform.isMacOS) {
      final String contentsDir =
          p.dirname(p.dirname(Platform.resolvedExecutable));
      final String bundleDir = p.join(
          contentsDir,
          'Frameworks',
          'App.framework',
          'Resources',
          'flutter_assets',
          'backend_bundle');
      return _pickPath(bundleDir, binaryName);

    } else if (Platform.isWindows) {
      final String bundleDir = p.join(
          p.dirname(Platform.resolvedExecutable),
          'data',
          'flutter_assets',
          'backend_bundle');
      return _pickPath(bundleDir, binaryName);

    } else {
      throw UnsupportedError(
          'SAGE backend not supported on ${Platform.operatingSystem}');
    }
  }

  String _pickPath(String bundleDir, String binaryName) {
    // The new CI/CD pipeline places the launcher directly in the bundleDir (flat layout)
    final String flat = p.join(bundleDir, binaryName);
    final String nested = p.join(bundleDir, 'sage_backend', binaryName);

    if (File(flat).existsSync()) {
      debugPrint('SAGE: using flat layout: $flat');
      return flat;
    }
    if (File(nested).existsSync()) {
      debugPrint('SAGE: using nested layout: $nested');
      return nested;
    }
    
    // Return flat as default so Process.start throws a clear "file not found" path error
    return flat;
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
