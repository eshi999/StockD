import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/curriculum.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/sage_provider.dart';
import '../../services/storage_service.dart';

class ResultScreen extends ConsumerWidget {
  final int worldIndex;
  final int levelIndex;
  final int score;

  const ResultScreen({
    super.key,
    required this.worldIndex,
    required this.levelIndex,
    required this.score,
  });

  int get _stars {
    if (score >= 9) return 3;
    if (score >= 7) return 2;
    if (score >= 5) return 1;
    return 0;
  }

  int get _xpEarned {
    if (score >= 9) return 150;
    if (score >= 7) return 100;
    if (score >= 5) return 50;
    return 10;
  }

  bool get _isGameOver => score < 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = Curriculum.worlds[worldIndex];
    final level = world.levels[levelIndex];
    final pct = (score / 10 * 100).round();

    return Scaffold(
      backgroundColor: StockDTheme.bg,
      body: Center(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.star_rounded,
                      size: i == 1 ? 56 : 44,
                      color: i < _stars
                          ? world.accentColor
                          : StockDTheme.textMuted,
                    )
                        .animate(delay: Duration(milliseconds: 200 + i * 150))
                        .scale(
                          begin: const Offset(0, 0),
                          curve: Curves.elasticOut,
                          duration: 600.ms,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _stars >= 3
                    ? 'PERFECT!'
                    : _stars >= 2
                        ? 'GREAT WORK!'
                        : _stars >= 1
                            ? 'LEVEL COMPLETE'
                            : 'KEEP PRACTICING',
                style: StockDTheme.displayLarge.copyWith(
                  color: world.accentColor,
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 8),
              Text(level.title, style: StockDTheme.headingMedium),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: StockDTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StockDTheme.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultStat(
                      label: 'SCORE',
                      value: '$score / 10',
                      color: world.accentColor,
                    ),
                    _ResultStat(
                      label: 'ACCURACY',
                      value: '$pct%',
                      color: StockDTheme.info,
                    ),
                    _ResultStat(
                      label: 'XP EARNED',
                      value: '+$_xpEarned',
                      color: StockDTheme.gold,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, _) {
                  return Row(
                    children: [
                      if (!_isGameOver)
                        Expanded(
                          child: _OutlineButton(
                            label: 'RETRY',
                            onTap: () {
                              final w = Curriculum.worlds[worldIndex];
                              final l = w.levels[levelIndex];
                              ref
                                  .read(lessonProvider.notifier)
                                  .startLesson(l.questions);
                              ref.read(sageProvider.notifier).clear();
                              context.go('/lesson/$worldIndex/$levelIndex');
                            },
                          ),
                        )
                      else
                        Expanded(
                          child: _FilledButton(
                            label: 'BACK TO WORLDS',
                            color: StockDTheme.danger,
                            onTap: () {
                              ref
                                  .read(progressProvider.notifier)
                                  .refillHearts();
                              context.go('/world/$worldIndex');
                            },
                          ),
                        ),
                      if (!_isGameOver) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _FilledButton(
                            label: 'CONTINUE →',
                            color: world.accentColor,
                            onTap: () async {
                              final w = Curriculum.worlds[worldIndex];
                              final l = w.levels[levelIndex];

                              // Save stars and score for this level
                              await StorageService().saveLevelResult(
                                l.id,
                                _stars,
                                score,
                              );

                              // Update level object in memory
                              l.stars = _stars;
                              l.bestScore = score;

                              // Unlock the next level if it exists
                              if (levelIndex + 1 < w.levels.length) {
                                w.levels[levelIndex + 1].isUnlocked = true;
                              }

                              // Award XP bonus
                              ref
                                  .read(progressProvider.notifier)
                                  .completeLevel(score: score);
                              ref.read(lessonProvider.notifier).reset();

                              if (context.mounted) {
                                context.go('/world/$worldIndex');
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(delay: 800.ms);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: StockDTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: StockDTheme.border),
        ),
        child: Center(
          child: Text(label, style: StockDTheme.labelSmall),
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FilledButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: StockDTheme.labelSmall.copyWith(color: StockDTheme.bg),
          ),
        ),
      ),
    );
  }
}
