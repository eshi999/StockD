import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/lesson_provider.dart';

class QuestionCard extends StatelessWidget {
  final StockQuestion question;
  final AnswerState answerState;
  final int? selectedIndex;
  final void Function(int) onAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    required this.answerState,
    required this.selectedIndex,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConceptChip(),
        const SizedBox(height: 14),
        _buildPrompt(),
        const SizedBox(height: 24),
        _buildOptions(),
      ],
    );
  }

  // ── Concept chip ───────────────────────────────────────────────────────────
  Widget _buildConceptChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: StockDTheme.sageGlow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StockDTheme.sage.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 11, color: StockDTheme.sage),
          const SizedBox(width: 5),
          Text(
            question.concept.toUpperCase(),
            style: StockDTheme.labelSmall.copyWith(color: StockDTheme.sage),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ── Prompt ─────────────────────────────────────────────────────────────────
  Widget _buildPrompt() {
    return Text(
      question.prompt,
      style: StockDTheme.headingLarge.copyWith(
        fontSize: 18,
        height: 1.4,
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideY(begin: 0.05);
  }

  // ── Options ────────────────────────────────────────────────────────────────
  Widget _buildOptions() {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final i = entry.key;
        final label = entry.value;

        OptionState state = OptionState.idle;
        if (answerState != AnswerState.unanswered) {
          if (i == question.correctIndex) {
            state = OptionState.correct;
          } else if (i == selectedIndex) {
            state = OptionState.wrong;
          } else {
            state = OptionState.dimmed;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnswerOption(
            label: label,
            index: i,
            state: state,
            enabled: answerState == AnswerState.unanswered,
            onTap: () => onAnswer(i),
            delay: i * 60,
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Answer Option
// ─────────────────────────────────────────────────────────────────────────────
enum OptionState { idle, selected, correct, wrong, dimmed }

class AnswerOption extends StatefulWidget {
  final String label;
  final int index;
  final OptionState state;
  final bool enabled;
  final VoidCallback onTap;
  final int delay;

  const AnswerOption({
    super.key,
    required this.label,
    required this.index,
    required this.state,
    required this.enabled,
    required this.onTap,
    required this.delay,
  });

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _hovered = false;

  Color get _borderColor => switch (widget.state) {
        OptionState.correct => StockDTheme.sage,
        OptionState.wrong => StockDTheme.danger,
        OptionState.selected => StockDTheme.info,
        OptionState.dimmed => StockDTheme.border,
        OptionState.idle => _hovered
            ? StockDTheme.info.withValues(alpha: 0.6)
            : StockDTheme.border,
      };

  Color get _bgColor => switch (widget.state) {
        OptionState.correct => StockDTheme.sage.withValues(alpha: 0.1),
        OptionState.wrong => StockDTheme.danger.withValues(alpha: 0.1),
        OptionState.selected => StockDTheme.info.withValues(alpha: 0.08),
        OptionState.dimmed => StockDTheme.surface,
        OptionState.idle => _hovered ? StockDTheme.card : StockDTheme.surface,
      };

  Color get _textColor => switch (widget.state) {
        OptionState.correct => StockDTheme.sage,
        OptionState.wrong => StockDTheme.danger,
        OptionState.selected => StockDTheme.info,
        OptionState.dimmed => StockDTheme.textMuted,
        OptionState.idle => StockDTheme.textPrimary,
      };

  IconData? get _trailingIcon => switch (widget.state) {
        OptionState.correct => Icons.check_circle_rounded,
        OptionState.wrong => Icons.cancel_rounded,
        _ => null,
      };

  String get _optionLetter =>
      String.fromCharCode('A'.codeUnitAt(0) + widget.index);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _borderColor.withValues(alpha: 0.15),
                  border: Border.all(color: _borderColor),
                ),
                child: Center(
                  child: Text(
                    _optionLetter,
                    style: StockDTheme.bodyMono.copyWith(
                      fontSize: 12,
                      color: _borderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Label
              Expanded(
                child: Text(
                  widget.label,
                  style: StockDTheme.bodyLarge.copyWith(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: widget.state == OptionState.correct ||
                            widget.state == OptionState.wrong
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
              // Trailing icon
              if (_trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(_trailingIcon, size: 18, color: _textColor),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 280.ms)
        .slideX(begin: 0.04);
  }
}
