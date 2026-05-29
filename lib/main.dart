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

  // Define default window dimensions
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
    // Gracefully terminate the backend process before closing the window
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
        if (backendStatus == BackendStatus.starting) {
          return Stack(
            children: [
              if (child != null) child,
              const _BackendSplash(),
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
    GoRoute(
      path: '/',
      builder: (context, state) => const OverworldScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/world/:worldIndex',
          builder: (context, state) {
            final i =
                int.tryParse(state.pathParameters['worldIndex'] ?? '0') ?? 0;
            return WorldScreen(worldIndex: i);
          },
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/sage',
          builder: (context, state) => const SageScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPlaceholder(),
        ),
      ],
    ),
    GoRoute(
      path: '/lesson/:worldIndex/:levelIndex',
      builder: (context, state) {
        final w = int.tryParse(state.pathParameters['worldIndex'] ?? '0') ?? 0;
        final l = int.tryParse(state.pathParameters['levelIndex'] ?? '0') ?? 0;
        return LessonScreen(worldIndex: w, levelIndex: l);
      },
    ),
    GoRoute(
      path: '/result/:worldIndex/:levelIndex',
      builder: (context, state) {
        final w = int.tryParse(state.pathParameters['worldIndex'] ?? '0') ?? 0;
        final l = int.tryParse(state.pathParameters['levelIndex'] ?? '0') ?? 0;
        final score = state.extra as int? ?? 0;
        return ResultScreen(worldIndex: w, levelIndex: l, score: score);
      },
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

class _BackendSplash extends ConsumerWidget {
  const _BackendSplash();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: StockDTheme.bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: StockDTheme.gradient,
              ),
              child: const Center(
                child: Text('S',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            Text('StockD',
                style: StockDTheme.displayLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 32),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: StockDTheme.border,
                valueColor: AlwaysStoppedAnimation(StockDTheme.sage),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => ref.read(backendProvider.notifier).skipToOffline(),
              child: const Text('Skip (run without SAGE)',
                  style: TextStyle(decoration: TextDecoration.underline)),
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
