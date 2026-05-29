import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../models/curriculum.dart';
import '../models/models.dart';

class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({super.key});

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  bool _collapsed = false;

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 64;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final worlds = Curriculum.worlds;
    final location = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: _collapsed ? _collapsedWidth : _expandedWidth,
      color: StockDTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildXPBar(progress),
          const SizedBox(height: 12),
          _buildLabel('WORLDS'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: worlds.length,
              itemBuilder: (ctx, i) => _WorldNavItem(
                world: worlds[i],
                collapsed: _collapsed,
                isActive: location.startsWith('/world/$i'),
                onTap: () => context.go('/world/$i'),
                delay: i * 60,
              ),
            ),
          ),
          _buildDivider(),
          _buildNavItem(Icons.home_rounded, 'Home', '/dashboard'),
          _buildNavItem(Icons.chat_bubble_rounded, 'Chat SAGE', '/chat'),
          _buildNavItem(Icons.auto_awesome_rounded, 'SAGE', '/sage'),
          _buildNavItem(Icons.settings_rounded, 'Settings', '/settings'),
          _buildDivider(),
          _buildCollapseButton(),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: StockDTheme.border)),
      ),
      child: Row(
        children: [
          _SageLogo(size: _collapsed ? 28 : 32),
          if (!_collapsed) ...[
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('StockD',
                    style: StockDTheme.headingLarge.copyWith(fontSize: 18)),
                Text('LEARN · TRADE · MASTER', style: StockDTheme.labelSmall),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── XP Bar ─────────────────────────────────────────────────────────────────
  Widget _buildXPBar(UserProgress progress) {
    if (_collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: StockDTheme.sage, width: 2),
          ),
          child: Center(
            child: Text(
              '${progress.xp ~/ 100}',
              style: StockDTheme.bodyMono.copyWith(fontSize: 10),
            ),
          ),
        ),
      );
    }

    final pct = ((progress.xp % 500) / 500).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: StockDTheme.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: StockDTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(progress.xpLabel,
                    style: StockDTheme.labelSmall
                        .copyWith(color: StockDTheme.gold)),
                Text('${progress.xp} XP',
                    style: StockDTheme.bodyMono.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: StockDTheme.border,
                valueColor: const AlwaysStoppedAnimation(StockDTheme.sage),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  value: '${progress.streak}d',
                  color: const Color(0xFFFF6B35),
                ),
                _StatChip(
                  icon: Icons.favorite_rounded,
                  value: '${progress.hearts}',
                  color: StockDTheme.danger,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Nav Item ───────────────────────────────────────────────────────────────
  Widget _buildNavItem(IconData icon, String label, String route) {
    final location = GoRouterState.of(context).uri.toString();
    final isActive = location == route;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: _collapsed ? 0 : 10),
          decoration: isActive
              ? BoxDecoration(
                  color: StockDTheme.sageGlow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: StockDTheme.sage.withValues(alpha: 0.4),
                  ),
                )
              : null,
          child: Row(
            mainAxisAlignment:
                _collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 18,
                  color: isActive ? StockDTheme.sage : StockDTheme.textMuted),
              if (!_collapsed) ...[
                const SizedBox(width: 10),
                Text(label,
                    style: StockDTheme.bodyLarge.copyWith(
                      fontSize: 13,
                      color: isActive
                          ? StockDTheme.sage
                          : StockDTheme.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    if (_collapsed) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(text, style: StockDTheme.labelSmall),
    );
  }

  Widget _buildDivider() => Container(
        height: 1,
        color: StockDTheme.border,
        margin: const EdgeInsets.symmetric(vertical: 6),
      );

  Widget _buildCollapseButton() {
    return InkWell(
      onTap: () => setState(() => _collapsed = !_collapsed),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment:
              _collapsed ? MainAxisAlignment.center : MainAxisAlignment.end,
          children: [
            Icon(
              _collapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              color: StockDTheme.textMuted,
              size: 20,
            ),
            if (!_collapsed) ...[
              const SizedBox(width: 4),
              Text('Collapse', style: StockDTheme.labelSmall),
            ],
          ],
        ),
      ),
    );
  }
}

// ── World Nav Item ────────────────────────────────────────────────────────────
class _WorldNavItem extends StatelessWidget {
  final World world;
  final bool collapsed;
  final bool isActive;
  final VoidCallback onTap;
  final int delay;

  const _WorldNavItem({
    required this.world,
    required this.collapsed,
    required this.isActive,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !world.isUnlocked;

    return Opacity(
      opacity: locked ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 10,
              vertical: 8,
            ),
            decoration: isActive
                ? BoxDecoration(
                    color: StockDTheme.sageGlow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: StockDTheme.sage.withValues(alpha: 0.4),
                    ),
                  )
                : null,
            child: collapsed
                ? Center(
                    child: Text(
                      _worldEmoji(world.index),
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : Row(
                    children: [
                      Text(_worldEmoji(world.index),
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              world.title,
                              style: StockDTheme.headingMedium.copyWith(
                                fontSize: 12,
                                color: isActive
                                    ? StockDTheme.sage
                                    : StockDTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: world.progress,
                                minHeight: 3,
                                backgroundColor: StockDTheme.border,
                                valueColor:
                                    AlwaysStoppedAnimation(world.accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (locked)
                        const Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: StockDTheme.textMuted,
                        ),
                    ],
                  ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideX(begin: -0.1);
  }

  String _worldEmoji(int index) => switch (index) {
        0 => '🌿',
        1 => '🏘️',
        2 => '🏙️',
        _ => '🔒',
      };
}

// ── SAGE Logo ─────────────────────────────────────────────────────────────────
class _SageLogo extends StatelessWidget {
  final double size;
  const _SageLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: StockDTheme.gradient,
        boxShadow: [
          BoxShadow(
            color: StockDTheme.sage.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: StockDTheme.bg,
          ),
        ),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(value,
            style: StockDTheme.bodyMono.copyWith(fontSize: 11, color: color)),
      ],
    );
  }
}
