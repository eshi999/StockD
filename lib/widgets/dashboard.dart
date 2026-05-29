import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../models/curriculum.dart';
import '../models/models.dart';
import '../providers/sage_provider.dart';

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final progress = ref.watch(progressProvider);
    final worlds = Curriculum.worlds;
    final isWide = size.width > 900;

    return Column(
      children: [
        _DashboardHeader(),
        Expanded(
          child: isWide
              ? _WideLayout(worlds: worlds, progress: progress)
              : _NarrowLayout(worlds: worlds, progress: progress),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: StockDTheme.surface,
        border: Border(bottom: BorderSide(color: StockDTheme.border)),
      ),
      child: Row(
        children: [
          Text('HOME', style: StockDTheme.labelSmall),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 14, color: StockDTheme.textMuted),
          const SizedBox(width: 6),
          Text('DASHBOARD',
              style: StockDTheme.labelSmall.copyWith(color: StockDTheme.sage)),
          const Spacer(),
          const _LiveTicker(),
          const SizedBox(width: 20),
          _SearchBar(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 30,
      child: TextField(
        style: StockDTheme.bodyMono.copyWith(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Search concepts...',
          hintStyle: StockDTheme.labelSmall,
          prefixIcon: const Icon(Icons.search_rounded,
              size: 14, color: StockDTheme.textMuted),
          filled: true,
          fillColor: StockDTheme.card,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: StockDTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: StockDTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: StockDTheme.sage),
          ),
        ),
      ),
    );
  }
}

// ── Wide Layout ───────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final List<World> worlds;
  final UserProgress progress;
  const _WideLayout({required this.worlds, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _LeftPanel(worlds: worlds),
        ),
        const VerticalDivider(width: 1, color: StockDTheme.border),
        SizedBox(
          width: 300,
          child: _RightPanel(progress: progress),
        ),
      ],
    );
  }
}

// ── Narrow Layout ─────────────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final List<World> worlds;
  final UserProgress progress;
  const _NarrowLayout({required this.worlds, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _RightPanel(progress: progress),
          const SizedBox(height: 20),
          _LeftPanel(worlds: worlds),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEFT PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _LeftPanel extends StatelessWidget {
  final List<World> worlds;
  const _LeftPanel({required this.worlds});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          sliver: SliverToBoxAdapter(
            child: Text('CONTINUE', style: StockDTheme.labelSmall),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          sliver: SliverToBoxAdapter(
            child: _ContinueCard(worlds: worlds),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          sliver: SliverToBoxAdapter(
            child: Text('ALL WORLDS', style: StockDTheme.labelSmall),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 155,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _WorldCard(world: worlds[i], index: i),
              childCount: worlds.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Continue Card ─────────────────────────────────────────────────────────────
class _ContinueCard extends StatelessWidget {
  final List<World> worlds;
  const _ContinueCard({required this.worlds});

  @override
  Widget build(BuildContext context) {
    World? activeWorld;
    Level? activeLevel;

    for (final w in worlds) {
      if (!w.isUnlocked) continue;
      for (final l in w.levels) {
        if (l.isUnlocked && !l.isCompleted) {
          activeWorld = w;
          activeLevel = l;
          break;
        }
      }
      if (activeLevel != null) break;
    }

    if (activeWorld == null || activeLevel == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context
          .go('/lesson/${activeWorld!.index}/${activeLevel!.levelIndex}'),
      child: Container(
        // FIXED: Replaced rigid height: 76 with dynamic constraints and responsive padding
        constraints: const BoxConstraints(minHeight: 76),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              activeWorld.accentColor.withValues(alpha: 0.15),
              StockDTheme.card,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: activeWorld.accentColor.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Text(_worldEmoji(activeWorld.index),
                style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize
                    .min, // Packs tightly to prevent flex boundary spills
                children: [
                  Text('CONTINUE',
                      style: StockDTheme.labelSmall
                          .copyWith(color: activeWorld.accentColor)),
                  const SizedBox(height: 2),
                  // FIXED: Enforced text maxLines and ellipsis scaling properties
                  Text(
                    activeLevel.title,
                    style: StockDTheme.headingMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    activeLevel.subtitle,
                    style: StockDTheme.bodyLarge.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: activeWorld.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'START  ▶',
                style: StockDTheme.labelSmall.copyWith(
                  color: StockDTheme.bg,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  String _worldEmoji(int index) => switch (index) {
        0 => '🌿',
        1 => '🏘️',
        2 => '🏙️',
        _ => '🔒',
      };
}

// ── World Card ────────────────────────────────────────────────────────────────
class _WorldCard extends StatefulWidget {
  final World world;
  final int index;
  const _WorldCard({required this.world, required this.index});

  @override
  State<_WorldCard> createState() => _WorldCardState();
}

class _WorldCardState extends State<_WorldCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.world;
    final locked = !w.isUnlocked;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: locked ? null : () => context.go('/world/${w.index}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: _hovered && !locked ? StockDTheme.card : StockDTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered && !locked
                  ? w.accentColor.withValues(alpha: 0.6)
                  : StockDTheme.border,
            ),
            boxShadow: _hovered && !locked
                ? [
                    BoxShadow(
                      color: w.accentColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                    )
                  ]
                : [],
          ),
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: locked ? 0.45 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_worldEmoji(w.index),
                        style: const TextStyle(fontSize: 22)),
                    const Spacer(),
                    if (locked)
                      const Icon(Icons.lock_rounded,
                          size: 14, color: StockDTheme.textMuted)
                    else
                      _DifficultyBadge(
                          difficulty: w.difficulty, color: w.accentColor),
                  ],
                ),
                const SizedBox(height: 10),
                Text(w.title, style: StockDTheme.headingMedium),
                Text(w.subtitle,
                    style: StockDTheme.bodyLarge.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: w.progress,
                          minHeight: 4,
                          backgroundColor: StockDTheme.border,
                          valueColor: AlwaysStoppedAnimation(w.accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${w.completedLevels}/${w.levels.length}',
                      style: StockDTheme.bodyMono
                          .copyWith(fontSize: 11, color: w.accentColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 80))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.08);
  }

  String _worldEmoji(int index) => switch (index) {
        0 => '🌿',
        1 => '🏘️',
        2 => '🏙️',
        _ => '🔒',
      };
}

// ── Difficulty Badge ──────────────────────────────────────────────────────────
class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;
  final Color color;
  const _DifficultyBadge({required this.difficulty, required this.color});

  String get _label => switch (difficulty) {
        Difficulty.beginner => 'BEGINNER',
        Difficulty.intermediate => 'INTER',
        Difficulty.advanced => 'ADVANCED',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(_label,
          style: StockDTheme.labelSmall.copyWith(color: color, fontSize: 9)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIGHT PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final UserProgress progress;
  const _RightPanel({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR STATS', style: StockDTheme.labelSmall),
          const SizedBox(height: 10),
          _StatsGrid(progress: progress),
          const SizedBox(height: 20),
          Text('S&P 500 — 30D', style: StockDTheme.labelSmall),
          const SizedBox(height: 10),
          const _MiniChart(),
          const SizedBox(height: 20),
          Text('SAGE STATUS', style: StockDTheme.labelSmall),
          const SizedBox(height: 10),
          const _SageStatusCard(),
          const SizedBox(height: 20),
          Text('RECENT ACTIVITY', style: StockDTheme.labelSmall),
          const SizedBox(height: 10),
          const _RecentActivity(),
        ],
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final UserProgress progress;
  const _StatsGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    final accuracy = (progress.accuracy * 100).toStringAsFixed(0);
    final stats = [
      _Stat('TOTAL XP', '${progress.xp}', Icons.bolt_rounded, StockDTheme.gold),
      _Stat('STREAK', '${progress.streak}d', Icons.local_fire_department,
          const Color(0xFFFF6B35)),
      _Stat('ACCURACY', '$accuracy%', Icons.track_changes_rounded,
          StockDTheme.sage),
      _Stat('ANSWERED', '${progress.totalAnswered}', Icons.check_circle_rounded,
          StockDTheme.info),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.7,
      children: stats
          .asMap()
          .entries
          .map((e) => _StatCard(stat: e.value, delay: e.key * 60))
          .toList(),
    );
  }
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  final int delay;
  const _StatCard({required this.stat, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StockDTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 13, color: stat.color),
              const SizedBox(width: 5),
              Text(stat.label, style: StockDTheme.labelSmall),
            ],
          ),
          Text(
            stat.value,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: stat.color,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .scale(begin: const Offset(0.95, 0.95));
  }
}

// ── Mini Chart ────────────────────────────────────────────────────────────────
class _MiniChart extends StatelessWidget {
  const _MiniChart();

  static final List<FlSpot> _spots = [
    const FlSpot(0, 4510),
    const FlSpot(1, 4490),
    const FlSpot(2, 4530),
    const FlSpot(3, 4560),
    const FlSpot(4, 4520),
    const FlSpot(5, 4590),
    const FlSpot(6, 4610),
    const FlSpot(7, 4640),
    const FlSpot(8, 4660),
    const FlSpot(9, 4700),
    const FlSpot(10, 4720),
    const FlSpot(11, 4750),
    const FlSpot(12, 4780),
    const FlSpot(13, 4760),
    const FlSpot(14, 4800),
    const FlSpot(15, 4830),
    const FlSpot(16, 4810),
    const FlSpot(17, 4850),
    const FlSpot(18, 4880),
    const FlSpot(19, 4860),
    const FlSpot(20, 4900),
    const FlSpot(21, 4920),
    const FlSpot(22, 4905),
    const FlSpot(23, 4940),
    const FlSpot(24, 4965),
    const FlSpot(25, 4980),
    const FlSpot(26, 4960),
    const FlSpot(27, 5000),
    const FlSpot(28, 5020),
    const FlSpot(29, 5045),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      decoration: BoxDecoration(
        color: StockDTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('SPY', style: StockDTheme.bodyMono.copyWith(fontSize: 12)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: StockDTheme.sage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('+11.9%',
                    style: StockDTheme.bodyMono.copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 29,
                minY: 4400,
                maxY: 5100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: StockDTheme.sage,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          StockDTheme.sage.withValues(alpha: 0.18),
                          StockDTheme.sage.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }
}

// ── SAGE Status Card ──────────────────────────────────────────────────────────
// CHANGED: Converted to a ConsumerWidget to listen to your background process
class _SageStatusCard extends ConsumerWidget {
  const _SageStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Read the real state from your sage_provider
    final backendStatus = ref.watch(backendProvider);

    final isOnline = backendStatus == BackendStatus.online;
    final isStarting = backendStatus == BackendStatus.starting;

    // 2. Dynamically update text and colors based on status
    String titleText = 'SAGE OFFLINE';
    Color titleColor = StockDTheme.textMuted;
    String subtitleText = 'Activate your Conda env to link pipeline';
    Color borderColor = StockDTheme.border;

    if (isOnline) {
      titleText = 'SAGE ONLINE';
      titleColor = StockDTheme.sage;
      subtitleText = 'ML backend connected · Ready to explain';
      borderColor = StockDTheme.sage.withValues(alpha: 0.4);
    } else if (isStarting) {
      titleText = 'SAGE STARTING';
      titleColor = StockDTheme.gold;
      subtitleText = 'Initializing local model paths...';
      borderColor = StockDTheme.gold.withValues(alpha: 0.4);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StockDTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Passes true if online or starting so it visually stays active/pulses
          _PulseDot(online: isOnline || isStarting),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: StockDTheme.headingMedium.copyWith(
                    fontSize: 12,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: StockDTheme.bodyLarge.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chat button
          GestureDetector(
            onTap: () => context.go('/chat'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: StockDTheme.sageGlow,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: StockDTheme.sage.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded,
                      size: 12, color: StockDTheme.sage),
                  const SizedBox(width: 4),
                  Text('Chat',
                      style: StockDTheme.labelSmall
                          .copyWith(color: StockDTheme.sage)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final bool online;
  const _PulseDot({required this.online});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.online ? StockDTheme.sage : StockDTheme.textMuted;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.4 + 0.6 * _ctrl.value),
          boxShadow: widget.online
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5 * _ctrl.value),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
      ),
    );
  }
}

// ── Recent Activity ───────────────────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const _items = [
    _Activity(Icons.check_circle_rounded, StockDTheme.sage,
        'Completed: What Is a Stock?', '2h ago'),
    _Activity(Icons.close_rounded, StockDTheme.danger, 'SAGE helped: P/E Ratio',
        '2h ago'),
    _Activity(Icons.bolt_rounded, StockDTheme.gold,
        'Earned 50 XP · Perfect Score', '3h ago'),
    _Activity(Icons.lock_open_rounded, StockDTheme.info, 'Unlocked: Level 2',
        'Yesterday'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items
          .asMap()
          .entries
          .map((e) => _ActivityRow(item: e.value, delay: e.key * 50))
          .toList(),
    );
  }
}

class _Activity {
  final IconData icon;
  final Color color;
  final String label, time;
  const _Activity(this.icon, this.color, this.label, this.time);
}

class _ActivityRow extends StatelessWidget {
  final _Activity item;
  final int delay;
  const _ActivityRow({required this.item, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(item.icon, size: 14, color: item.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.label,
                style: StockDTheme.bodyLarge.copyWith(fontSize: 12)),
          ),
          Text(item.time, style: StockDTheme.labelSmall),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideX(begin: 0.05);
  }
}

// ── Live Ticker ───────────────────────────────────────────────────────────────
class _LiveTicker extends StatelessWidget {
  const _LiveTicker();

  static const _tickers = [
    ('SPY', '+0.42%', true),
    ('AAPL', '+1.20%', true),
    ('TSLA', '-0.80%', false),
    ('NVDA', '+2.10%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _tickers
          .map((t) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Text(t.$1,
                        style: StockDTheme.bodyMono.copyWith(
                          fontSize: 11,
                          color: StockDTheme.textSecondary,
                        )),
                    const SizedBox(width: 4),
                    Text(t.$2,
                        style: StockDTheme.bodyMono.copyWith(
                          fontSize: 11,
                          color: t.$3 ? StockDTheme.sage : StockDTheme.danger,
                        )),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
