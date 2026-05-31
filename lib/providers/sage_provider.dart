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
    // Quick check — already running from a previous launch
    if (await ref.read(sageServiceProvider).isBackendAlive()) {
      state = BackendStatus.online;
      return;
    }

    try {
      if (kReleaseMode) {
        final String backendPath = _resolveBackendPath();
        debugPrint('SAGE: launching backend at $backendPath');

        if (!File(backendPath).existsSync()) {
          debugPrint('SAGE: binary not found at $backendPath');
          state = BackendStatus.offline;
          return;
        }

        _process = await Process.start(
          backendPath,
          [],
          workingDirectory: p.dirname(backendPath),
          mode: ProcessStartMode.normal,
          environment: Platform.environment,
        );

        // Pipe stderr so crash logs surface the real error
        _process!.stderr
            .transform(const SystemEncoding().decoder)
            .listen((line) => debugPrint('SAGE stderr: $line'));

      } else {
        // Development: run via local Python
        _process = await Process.start(
          'python',
          ['-m', 'uvicorn', 'main:app', '--port', '8000'],
          workingDirectory: _mlDir(),
          mode: ProcessStartMode.normal,
        );
      }

      // Poll until backend responds — TF can take 30-60s on cold start
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (await ref.read(sageServiceProvider).isBackendAlive()) {
          debugPrint('SAGE: online after ${i + 1}s');
          state = BackendStatus.online;
          return;
        }
      }

      debugPrint('SAGE: timed out after 60s');
      state = BackendStatus.offline;

    } catch (e) {
      debugPrint('SAGE: start failed: $e');
      state = BackendStatus.offline;
    }
  }

  String _resolveBackendPath() {
    final String binaryName =
        Platform.isWindows ? 'sage_backend.exe' : 'sage_backend';

    if (Platform.isLinux) {
      // resolvedExecutable on Linux returns the symlink in /usr/bin/ —
      // resolve it to get the real binary in /usr/lib/StockD-1.2.0/
      //
      // Layout:
      //   /usr/lib/StockD-1.2.0/
      //     stockd
      //     data/flutter_assets/backend_bundle/
      //       sage_backend/sage_backend   ← nested (correct)
      //       sage_backend                ← flat (old builds)
      final String realExe =
          File(Platform.resolvedExecutable).resolveSymbolicLinksSync();
      final String bundleDir = p.join(
          p.dirname(realExe), 'data', 'flutter_assets', 'backend_bundle');
      return _pickPath(bundleDir, binaryName);

    } else if (Platform.isMacOS) {
      // resolvedExecutable = StockD.app/Contents/MacOS/StockD
      // Assets live at:
      //   StockD.app/Contents/Frameworks/App.framework/Resources/flutter_assets/
      //
      // Layout:
      //   backend_bundle/
      //     sage_backend/sage_backend     ← nested (correct)
      //     sage_backend                  ← flat (old builds)
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
      // No symlinks — resolvedExecutable is the real path.
      //
      // Layout:
      //   StockD\
      //     StockD.exe
      //     data\flutter_assets\backend_bundle\
      //       sage_backend\sage_backend.exe  ← nested (correct)
      //       sage_backend.exe               ← flat (old builds)
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

  // Handles both layouts:
  //   nested: backend_bundle/sage_backend/sage_backend(.exe)  ← new builds
  //   flat:   backend_bundle/sage_backend(.exe)               ← old builds
  String _pickPath(String bundleDir, String binaryName) {
    final String nested = p.join(bundleDir, 'sage_backend', binaryName);
    final String flat = p.join(bundleDir, binaryName);

    if (File(nested).existsSync()) {
      debugPrint('SAGE: using nested layout: $nested');
      return nested;
    }
    debugPrint('SAGE: using flat layout: $flat');
    return flat;
  }

  Future<void> retry() async {
    state = BackendStatus.starting;
    await _startBackend();
  }

  void skipToOffline() {
    stopBackend();
    state = BackendStatus.offline;
  }

  String _mlDir() {
    // Dev mode only — walks up from the executable to find the ML/ folder
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
