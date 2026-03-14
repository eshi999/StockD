import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/curriculum.dart';
import '../../models/models.dart';

class OverworldScreen extends StatefulWidget {
  const OverworldScreen({super.key});

  @override
  State<OverworldScreen> createState() => _OverworldScreenState();
}

class _OverworldScreenState extends State<OverworldScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  int? _hoveredWorld;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final worlds = Curriculum.worlds;

    return Scaffold(
      backgroundColor: StockDTheme.bg,
      body: Stack(
        children: [
          // Background image
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
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(context),
          ),
          // Dashed path
          Positioned.fill(
            child: CustomPaint(
              painter: _PathPainter(
                worldCount: worlds.length,
                size: size,
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
              top: pos.dy - 140,
              child: _WorldIsland(
                world: world,
                index: i,
                isHovered: _hoveredWorld == i,
                floatCtrl: _floatCtrl,
                onHover: (h) => setState(() => _hoveredWorld = h ? i : null),
                onTap: world.isUnlocked ? () => context.go('/world/$i') : null,
              ),
            );
          }),
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

  Offset _worldPosition(int index, int total, Size size) {
    final spacing = size.width / (total + 1);
    final x = spacing * (index + 1);
    final y = size.height * 0.52 + (index % 2 == 0 ? -20.0 : 20.0);
    return Offset(x, y);
  }
}

// ── World Island ──────────────────────────────────────────────────────────────
class _WorldIsland extends StatelessWidget {
  final World world;
  final int index;
  final bool isHovered;
  final AnimationController floatCtrl;
  final void Function(bool) onHover;
  final VoidCallback? onTap;

  const _WorldIsland({
    required this.world,
    required this.index,
    required this.isHovered,
    required this.floatCtrl,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !world.isUnlocked;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 240,
          height: 280,
          child: AnimatedBuilder(
            animation: floatCtrl,
            builder: (_, child) {
              final floatOffset =
                  (floatCtrl.value - 0.5) * (index % 2 == 0 ? 12.0 : -8.0);
              return Transform.translate(
                offset: Offset(0, floatOffset),
                child: child,
              );
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(isHovered && !locked ? 1.06 : 1.0,
                        isHovered && !locked ? 1.06 : 1.0, 1.0),
                  transformAlignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isHovered && !locked)
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: world.accentColor.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      Opacity(
                        opacity: locked ? 0.5 : 1.0,
                        child: Image.asset(
                          world.imagePath,
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
                    color: isHovered && !locked
                        ? world.accentColor.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHovered && !locked
                          ? world.accentColor
                          : Colors.white.withValues(alpha: 0.25),
                    ),
                    boxShadow: isHovered && !locked
                        ? [
                            BoxShadow(
                              color: world.accentColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'WORLD ${index + 1}',
                        style: StockDTheme.labelSmall.copyWith(
                          color: isHovered && !locked
                              ? StockDTheme.bg
                              : Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                      if (isHovered && !locked) ...[
                        const SizedBox(height: 2),
                        Text(
                          world.title,
                          style: StockDTheme.headingMedium.copyWith(
                            fontSize: 12,
                            color: StockDTheme.bg,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!locked && world.completedLevels > 0) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: world.progress,
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(world.accentColor),
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
        .animate(delay: Duration(milliseconds: 200 + index * 150))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.1);
  }
}

// ── Path Painter ──────────────────────────────────────────────────────────────
class _PathPainter extends CustomPainter {
  final int worldCount;
  final Size size;

  const _PathPainter({required this.worldCount, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final spacing = canvasSize.width / (worldCount + 1);

    for (int i = 0; i < worldCount - 1; i++) {
      final x1 = spacing * (i + 1);
      final y1 = canvasSize.height * 0.52 + (i % 2 == 0 ? -20.0 : 20.0);
      final x2 = spacing * (i + 2);
      final y2 = canvasSize.height * 0.52 + ((i + 1) % 2 == 0 ? -20.0 : 20.0);

      final path = Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2);
      _drawDashed(canvas, path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    double distance = 0.0;
    bool drawing = true;

    for (final metric in path.computeMetrics()) {
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
      old.worldCount != worldCount || old.size != size;
}
