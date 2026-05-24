import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/curriculum.dart';
import '../../models/models.dart';
import '../../providers/progress_provider.dart';
import '../../providers/trading_provider.dart';
import '../../services/storage_service.dart';

class OverworldScreen extends ConsumerStatefulWidget {
  const OverworldScreen({super.key});

  @override
  ConsumerState<OverworldScreen> createState() => _OverworldScreenState();
}

class _OverworldScreenState extends ConsumerState<OverworldScreen> {
  int? _hoveredWorld;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await StorageService().applyToWorlds(Curriculum.worlds);
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StockDTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: StockDTheme.border),
        ),
        title: Text('Reset Progress', style: StockDTheme.headingMedium),
        content: Text(
          'This will clear all XP, stars, hearts, and trade history. '
          'You will start from the beginning.',
          style: StockDTheme.bodyLarge.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: StockDTheme.labelSmall),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'RESET',
              style: StockDTheme.labelSmall.copyWith(color: StockDTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await StorageService().clearAll();
    Curriculum.resetProgress();
    ref.invalidate(progressProvider);
    ref.invalidate(tradingProvider);
    setState(() => _loaded = false);
    await _loadProgress();
  }

  // Island center Y — all islands sit at the same height
  static const double _islandCenterY = 0.45;
  // How far the path dips below the islands
  static const double _pathDipY = 0.58;

  Offset _worldPosition(int index, int total, Size size) {
    final spacing = size.width / (total + 1);
    final x = spacing * (index + 1);
    final y = size.height * _islandCenterY;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: StockDTheme.bg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(StockDTheme.sage),
          ),
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    final worlds = Curriculum.worlds;

    return Scaffold(
      backgroundColor: StockDTheme.bg,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_overworld.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),
          // Dashed path — drawn below islands
          Positioned.fill(
            child: CustomPaint(
              painter: _PathPainter(
                worlds: worlds,
                size: size,
                islandCenterY: _islandCenterY,
                pathDipY: _pathDipY,
              ),
            ),
          ),
          // World islands
          ...worlds.asMap().entries.map((entry) {
            final i = entry.key;
            final world = entry.value;
            final pos = _worldPosition(i, worlds.length, size);
            return Positioned(
              left: pos.dx - 120,
              top: pos.dy - 120,
              child: _WorldIsland(
                world: world,
                index: i,
                isHovered: _hoveredWorld == i,
                onHover: (h) => setState(() => _hoveredWorld = h ? i : null),
                onTap: world.isUnlocked ? () => context.go('/world/$i') : null,
              ),
            );
          }),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context),
          ),
          // Bottom hint
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SELECT A WORLD TO BEGIN',
                style: StockDTheme.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 3,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fadeIn(duration: 1200.ms)
                  .then()
                  .fadeOut(duration: 1200.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: StockDTheme.gradient,
              boxShadow: [
                BoxShadow(
                  color: StockDTheme.sage.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: StockDTheme.bg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('StockD',
                  style: StockDTheme.headingLarge.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  )),
              Text('LEARN · TRADE · MASTER',
                  style: StockDTheme.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  )),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _confirmReset(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.refresh_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Reset',
                      style:
                          StockDTheme.labelSmall.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dashboard_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Dashboard',
                      style:
                          StockDTheme.labelSmall.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ── World Island ──────────────────────────────────────────────────────────────
class _WorldIsland extends StatefulWidget {
  final World world;
  final int index;
  final bool isHovered;
  final void Function(bool) onHover;
  final VoidCallback? onTap;

  const _WorldIsland({
    required this.world,
    required this.index,
    required this.isHovered,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_WorldIsland> createState() => _WorldIslandState();
}

class _WorldIslandState extends State<_WorldIsland>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(_WorldIsland old) {
    super.didUpdateWidget(old);
    if (widget.isHovered && widget.world.isUnlocked) {
      if (!_floatCtrl.isAnimating) {
        _floatCtrl.repeat(reverse: true);
      }
    } else {
      _floatCtrl.stop();
      _floatCtrl.animateTo(
        0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = !widget.world.isUnlocked;

    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: 240,
          height: 260,
          child: AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, child) {
              final floatOffset =
                  widget.isHovered ? (_floatCtrl.value - 0.5) * 10.0 : 0.0;
              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(
                      widget.isHovered && !locked ? 1.06 : 1.0,
                      widget.isHovered && !locked ? 1.06 : 1.0,
                      1.0,
                    ),
                  transformAlignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.isHovered && !locked)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.world.accentColor
                                    .withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      Opacity(
                        opacity: locked ? 0.5 : 1.0,
                        child: Image.asset(
                          widget.world.imagePath,
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (locked)
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: widget.isHovered && !locked
                        ? widget.world.accentColor.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isHovered && !locked
                          ? widget.world.accentColor
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                    boxShadow: widget.isHovered && !locked
                        ? [
                            BoxShadow(
                              color: widget.world.accentColor
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'WORLD ${widget.index + 1}',
                        style: StockDTheme.labelSmall.copyWith(
                          color: widget.isHovered && !locked
                              ? StockDTheme.bg
                              : Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                      if (widget.isHovered && !locked) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.world.title,
                          style: StockDTheme.headingMedium.copyWith(
                            fontSize: 12,
                            color: StockDTheme.bg,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!locked && widget.world.completedLevels > 0) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: widget.world.progress,
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor:
                            AlwaysStoppedAnimation(widget.world.accentColor),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 200 + widget.index * 150))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1);
  }
}

// ── Path Painter ──────────────────────────────────────────────────────────────
class _PathPainter extends CustomPainter {
  final List<World> worlds;
  final Size size;
  final double islandCenterY;
  final double pathDipY;

  const _PathPainter({
    required this.worlds,
    required this.size,
    required this.islandCenterY,
    required this.pathDipY,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final total = worlds.length;
    final spacing = canvasSize.width / (total + 1);
    final islandY = canvasSize.height * islandCenterY;
    final dipY = canvasSize.height * pathDipY;
    // Connect from the bottom-center of each island
    const islandBottomOffset = 90.0;

    for (int i = 0; i < total - 1; i++) {
      final x1 = spacing * (i + 1);
      final x2 = spacing * (i + 2);
      final y = islandY + islandBottomOffset;
      final midX = (x1 + x2) / 2;

      // Single cubic bezier dipping below the islands — no straight segments
      final path = Path()
        ..moveTo(x1, y)
        ..cubicTo(
          midX - (x2 - x1) * 0.15,
          dipY,
          midX + (x2 - x1) * 0.15,
          dipY,
          x2,
          y,
        );

      _drawDashed(canvas, path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;
    bool drawing = true;

    for (final metric in path.computeMetrics()) {
      distance = 0.0;
      drawing = true;
      while (distance < metric.length) {
        final len = drawing ? dashWidth : dashSpace;
        if (drawing) {
          final extracted = metric.extractPath(
            distance,
            (distance + len).clamp(0, metric.length),
          );
          canvas.drawPath(extracted, paint);
        }
        distance += len;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.worlds.length != worlds.length || old.size != size;
}
