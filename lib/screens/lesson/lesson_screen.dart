import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/curriculum.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/sage_provider.dart';
import '../../widgets/question_card.dart';
import '../../widgets/sage_panel.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final int worldIndex;
  final int levelIndex;

  const LessonScreen({
    super.key,
    required this.worldIndex,
    required this.levelIndex,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLesson());
  }

  void _startLesson() {
    final worlds = Curriculum.worlds;
    if (widget.worldIndex >= worlds.length) return;
    final world = worlds[widget.worldIndex];
    if (widget.levelIndex >= world.levels.length) return;
    final level = world.levels[widget.levelIndex];
    ref.read(lessonProvider.notifier).startLesson(level.questions);
    ref.read(sageProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonProvider);

    if (lessonState == null) {
      return const Scaffold(
        backgroundColor: StockDTheme.bg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(StockDTheme.sage),
          ),
        ),
      );
    }

    // Game Over: 0 lives left (NEW)
    if (ref.read(progressProvider).hearts == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/result/${widget.worldIndex}/${widget.levelIndex}',
            extra: lessonState.score);
      });
      return const SizedBox.shrink();
    }

    if (lessonState.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(progressProvider.notifier)
            .completeLevel(score: lessonState.score);
        context.go(
          '/result/${widget.worldIndex}/${widget.levelIndex}',
          extra: lessonState.score,
        );
      });
      return const SizedBox.shrink();
    }

    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: StockDTheme.bg,
      body: Column(
        children: [
          _LessonTopBar(
            worldIndex: widget.worldIndex,
            levelIndex: widget.levelIndex,
            lessonState: lessonState,
          ),
          Expanded(
            child: isWide
                ? _WideLayout(lessonState: lessonState)
                : _NarrowLayout(lessonState: lessonState),
          ),
        ],
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────
class _LessonTopBar extends ConsumerWidget {
  final int worldIndex;
  final int levelIndex;
  final LessonState lessonState;

  const _LessonTopBar({
    required this.worldIndex,
    required this.levelIndex,
    required this.lessonState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final world = Curriculum.worlds[worldIndex];
    final level = world.levels[levelIndex];
    final qNum = lessonState.currentIndex + 1;
    final total = lessonState.questions.length;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: StockDTheme.surface,
        border: Border(bottom: BorderSide(color: StockDTheme.border)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              ref.read(lessonProvider.notifier).reset();
              ref.read(sageProvider.notifier).clear();
              context.go('/world/$worldIndex');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: StockDTheme.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: StockDTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_rounded,
                      size: 14, color: StockDTheme.textMuted),
                  const SizedBox(width: 5),
                  Text('EXIT', style: StockDTheme.labelSmall),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Level info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(world.title,
                  style: StockDTheme.labelSmall
                      .copyWith(color: world.accentColor)),
              Text(level.title,
                  style: StockDTheme.headingMedium.copyWith(fontSize: 13)),
            ],
          ),
          const Spacer(),

          // Question counter
          Text(
            '$qNum / $total',
            style: StockDTheme.bodyMono.copyWith(fontSize: 13),
          ),
          const SizedBox(width: 16),

          // Hearts
          Row(
            children: List.generate(
                5,
                (i) => Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: i < progress.hearts
                            ? StockDTheme.danger
                            : StockDTheme.textMuted,
                      ),
                    )),
          ),
          const SizedBox(width: 16),

          // Progress bar
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: lessonState.progress,
                minHeight: 6,
                backgroundColor: StockDTheme.border,
                valueColor: AlwaysStoppedAnimation(world.accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wide Layout ───────────────────────────────────────────────────────────────
class _WideLayout extends ConsumerWidget {
  final LessonState lessonState;
  const _WideLayout({required this.lessonState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sage = ref.watch(sageProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question side
        Expanded(
          flex: 3,
          child: _QuestionPane(lessonState: lessonState),
        ),
        const VerticalDivider(width: 1, color: StockDTheme.border),
        // SAGE side
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SagePanel(
              explanation: sage,
              onContinue: () => ref.read(lessonProvider.notifier).next(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Narrow Layout ─────────────────────────────────────────────────────────────
class _NarrowLayout extends ConsumerWidget {
  final LessonState lessonState;
  const _NarrowLayout({required this.lessonState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sage = ref.watch(sageProvider);
    final showingSage = sage != null && !sage.isLoading;

    return showingSage
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: SagePanel(
              explanation: sage,
              onContinue: () => ref.read(lessonProvider.notifier).next(),
            ),
          )
        : _QuestionPane(lessonState: lessonState);
  }
}

// ── Question Pane ─────────────────────────────────────────────────────────────
class _QuestionPane extends ConsumerWidget {
  final LessonState lessonState;
  const _QuestionPane({required this.lessonState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = lessonState.currentQuestion;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionCard(
            question: question,
            answerState: lessonState.answerState,
            selectedIndex: lessonState.selectedIndex,
            onAnswer: (i) => _handleAnswer(ref, i, question),
          ),
          const SizedBox(height: 24),

          // Bottom bar — next button when answered correctly
          if (lessonState.answerState == AnswerState.correct)
            _NextButton(
              onTap: () => ref.read(lessonProvider.notifier).next(),
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  void _handleAnswer(WidgetRef ref, int index, StockQuestion question) {
    ref.read(lessonProvider.notifier).answer(index);
    ref.read(progressProvider.notifier).recordAnswer(
          correct: index == question.correctIndex,
        );

    // Trigger SAGE on wrong answer
    if (index != question.correctIndex) {
      ref.read(sageProvider.notifier).explain(
            question: question,
            userAnswerIndex: index,
          );
    }
  }
}

// ── Next Button ───────────────────────────────────────────────────────────────
class _NextButton extends StatefulWidget {
  final VoidCallback onTap;
  const _NextButton({required this.onTap});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: _hovered
                ? const LinearGradient(
                    colors: [Color(0xFF00FFB2), Color(0xFF00D4FF)],
                  )
                : null,
            color: _hovered ? null : StockDTheme.sage,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'NEXT QUESTION →',
              style: StockDTheme.labelSmall.copyWith(
                color: StockDTheme.bg,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
