import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/curriculum.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';

class WorldScreen extends StatefulWidget {
  final int worldIndex;
  const WorldScreen({super.key, required this.worldIndex});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final worlds = Curriculum.worlds;
    if (widget.worldIndex >= worlds.length) return;
    final world = worlds[widget.worldIndex];
    await StorageService().applyToLevels(world.levels);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    final worlds = Curriculum.worlds;
    if (widget.worldIndex >= worlds.length) {
      return const Center(child: Text('World not found'));
    }
    final world = worlds[widget.worldIndex];

    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _WorldHeader(world: world),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: world.levels.length,
            itemBuilder: (ctx, i) => _LevelRow(
              level: world.levels[i],
              world: world,
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorldHeader extends StatelessWidget {
  final World world;
  const _WorldHeader({required this.world});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: StockDTheme.surface,
        border: const Border(bottom: BorderSide(color: StockDTheme.border)),
        image: DecorationImage(
          image: AssetImage(world.imagePath),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(world.difficulty.name.toUpperCase(),
              style: StockDTheme.labelSmall.copyWith(color: world.accentColor)),
          const SizedBox(height: 4),
          Text(world.title,
              style: StockDTheme.displayLarge.copyWith(fontSize: 28)),
          Text(world.subtitle, style: StockDTheme.bodyLarge),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: world.progress,
              minHeight: 4,
              backgroundColor: StockDTheme.border,
              valueColor: AlwaysStoppedAnimation(world.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatefulWidget {
  final Level level;
  final World world;
  final int index;
  const _LevelRow(
      {required this.level, required this.world, required this.index});

  @override
  State<_LevelRow> createState() => _LevelRowState();
}

class _LevelRowState extends State<_LevelRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.level;
    final locked = !l.isUnlocked;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: locked
            ? null
            : () => context.go('/lesson/${widget.world.index}/${l.levelIndex}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered && !locked ? StockDTheme.card : StockDTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: l.isCompleted
                  ? widget.world.accentColor.withValues(alpha: 0.4)
                  : StockDTheme.border,
            ),
          ),
          child: Opacity(
            opacity: locked ? 0.4 : 1.0,
            child: Row(
              children: [
                // Level number / status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: l.isCompleted
                        ? widget.world.accentColor.withValues(alpha: 0.15)
                        : StockDTheme.card,
                    border: Border.all(
                      color: l.isCompleted
                          ? widget.world.accentColor
                          : StockDTheme.border,
                    ),
                  ),
                  child: Center(
                    child: locked
                        ? const Icon(Icons.lock_rounded,
                            size: 16, color: StockDTheme.textMuted)
                        : l.isCompleted
                            ? Icon(Icons.check_rounded,
                                size: 18, color: widget.world.accentColor)
                            : Text(
                                '${widget.index + 1}',
                                style:
                                    StockDTheme.bodyMono.copyWith(fontSize: 14),
                              ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.title, style: StockDTheme.headingMedium),
                      Text(l.subtitle,
                          style: StockDTheme.bodyLarge.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                // Stars (only when completed)
                if (l.isCompleted)
                  Row(
                    children: List.generate(
                      3,
                      (i) => Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: i < l.stars
                            ? widget.world.accentColor
                            : StockDTheme.textMuted,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  '${l.questions.length}Q',
                  style: StockDTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.04);
  }
}
