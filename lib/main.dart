import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

void main() {
  runApp(const ProviderScope(child: StockDApp()));
}

class StockDApp extends ConsumerWidget {
  const StockDApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            final i = int.tryParse(
                state.pathParameters['worldIndex'] ?? '0') ?? 0;
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
        final w = int.tryParse(
            state.pathParameters['worldIndex'] ?? '0') ?? 0;
        final l = int.tryParse(
            state.pathParameters['levelIndex'] ?? '0') ?? 0;
        return LessonScreen(worldIndex: w, levelIndex: l);
      },
    ),
    GoRoute(
      path: '/result/:worldIndex/:levelIndex',
      builder: (context, state) {
        final w = int.tryParse(
            state.pathParameters['worldIndex'] ?? '0') ?? 0;
        final l = int.tryParse(
            state.pathParameters['levelIndex'] ?? '0') ?? 0;
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
                boxShadow: [
                  BoxShadow(
                    color: StockDTheme.sage.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: StockDTheme.bg,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('StockD',
                style: StockDTheme.displayLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 6),
            Text('LEARN · TRADE · MASTER',
                style: StockDTheme.labelSmall.copyWith(
                  letterSpacing: 3,
                  color: StockDTheme.textSecondary,
                )),
            const SizedBox(height: 32),
            Text('Starting SAGE backend...',
                style: StockDTheme.bodyMono.copyWith(fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: StockDTheme.border,
                valueColor:
                    const AlwaysStoppedAnimation(StockDTheme.sage),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () =>
                  ref.read(backendProvider.notifier).skipToOffline(),
              child: Text(
                'Skip (run without SAGE)',
                style: StockDTheme.labelSmall.copyWith(
                  color: StockDTheme.textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
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
  Widget build(BuildContext context) {
    return const _ComingSoon(
      icon: Icons.settings_rounded,
      label: 'SETTINGS',
      sub: 'Preferences & account settings\ncoming soon',
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _ComingSoon({
    required this.icon,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: StockDTheme.textMuted),
          const SizedBox(height: 14),
          Text(label, style: StockDTheme.headingLarge),
          const SizedBox(height: 8),
          Text(sub,
              style: StockDTheme.bodyLarge,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
