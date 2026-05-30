import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import 'theme/app_theme.dart';
import 'widgets/sidebar.dart';
import 'screens/home/home_screen.dart';
import 'screens/world/world_screen.dart';
import 'screens/lesson/lesson_screen.dart';
import 'screens/lesson/result_screen.dart';
import 'screens/sage/sage_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/overworld/overworld_screen.dart';
import 'providers/sage_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  double targetWidth = 1280;
  double targetHeight = 720;

  try {
    final view = PlatformDispatcher.instance.implicitView;
    if (view != null &&
        view.physicalSize.width > 0 &&
        view.physicalSize.height > 0) {
      final logicalWidth = view.physicalSize.width / view.devicePixelRatio;
      final logicalHeight = view.physicalSize.height / view.devicePixelRatio;
      targetWidth = min(1440.0, max(1024.0, logicalWidth * 0.8));
      targetHeight = min(900.0, max(768.0, logicalHeight * 0.8));
    }
  } catch (e) {
    debugPrint('Fallback scaling applied: $e');
  }

  WindowOptions windowOptions = WindowOptions(
    size: Size(targetWidth, targetHeight),
    minimumSize: const Size(1024, 720),
    center: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setPreventClose(true);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: StockDApp()));
}

class StockDApp extends ConsumerStatefulWidget {
  const StockDApp({super.key});

  @override
  ConsumerState<StockDApp> createState() => _StockDAppState();
}

class _StockDAppState extends ConsumerState<StockDApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    ref.read(backendProvider.notifier).stopBackend();
    await windowManager.destroy();
  }

  @override
  Widget build(BuildContext context) {
    final backendStatus = ref.watch(backendProvider);

    return MaterialApp.router(
      title: 'StockD',
      debugShowCheckedModeBanner: false,
      theme: StockDTheme.theme,
      routerConfig: _router,
      builder: (context, child) {
        // Show splash if still starting.
        // Once online or skipped (offline), child is rendered.
        if (backendStatus == BackendStatus.starting || backendStatus == BackendStatus.offline) {
          return Stack(
            children: [
              if (child != null) child,
              if (backendStatus != BackendStatus.offline) const _BackendSplash(),
            ],
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OverworldScreen()),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/world/:worldIndex',
          builder: (context, state) {
            final i = int.tryParse(state.pathParameters['worldIndex'] ?? '0') ?? 0;
            return WorldScreen(worldIndex: i);
          },
        ),
        GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
        GoRoute(path: '/sage', builder: (context, state) => const SageScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsPlaceholder()),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StockDTheme.bg,
      body: Row(
        children: [
          const AppSidebar(),
          const VerticalDivider(width: 1, color: StockDTheme.border),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Backend Splash with Retry/Skip ────────────────────────────────────────────
class _BackendSplash extends ConsumerStatefulWidget {
  const _BackendSplash();
  @override
  ConsumerState<_BackendSplash> createState() => _BackendSplashState();
}

class _BackendSplashState extends ConsumerState<_BackendSplash> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(backendProvider);

    return Container(
      color: StockDTheme.bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => Container(
                width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: StockDTheme.gradient),
                child: child,
              ),
              child: const Center(child: Text('S', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(height: 24),
            Text('StockD', style: StockDTheme.displayLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 10),
            Text(status == BackendStatus.offline ? 'SAGE FAILED TO LOAD' : 'INITIALIZING SAGE',
                style: StockDTheme.labelSmall.copyWith(color: StockDTheme.sage, letterSpacing: 3)),
            const SizedBox(height: 32),
            
            // Logic to switch between loading and Retry/Skip
            if (status == BackendStatus.offline)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: () => ref.read(backendProvider.notifier).retry(), child: const Text("Retry")),
                  const SizedBox(width: 12),
                  OutlinedButton(onPressed: () => ref.read(backendProvider.notifier).skipToOffline(), child: const Text("Skip")),
                ],
              )
            else
              const SizedBox(
                width: 220,
                child: LinearProgressIndicator(minHeight: 3, valueColor: AlwaysStoppedAnimation(StockDTheme.sage)),
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('SETTINGS'));
}
