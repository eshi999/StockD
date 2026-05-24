import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'stock_chart.dart';

class SagePanel extends StatefulWidget {
  final SageExplanation? explanation;
  final VoidCallback onContinue;

  const SagePanel({
    super.key,
    required this.explanation,
    required this.onContinue,
  });

  @override
  State<SagePanel> createState() => _SagePanelState();
}

class _SagePanelState extends State<SagePanel> {
  bool _showChart = true;

  @override
  Widget build(BuildContext context) {
    final explanation = widget.explanation;

    return Container(
      decoration: BoxDecoration(
        color: StockDTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StockDTheme.sage.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: StockDTheme.sage.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1, color: StockDTheme.border),
          Expanded(
            child: explanation == null
                ? _buildIdle()
                : explanation.isLoading
                    ? _buildLoading()
                    : explanation.error != null
                        ? _buildError(explanation.error!)
                        : _buildContent(explanation),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideX(begin: 0.05);
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          // SAGE logo
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: StockDTheme.gradient,
              boxShadow: [
                BoxShadow(
                  color: StockDTheme.sage.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: StockDTheme.bg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SAGE', style: StockDTheme.headingMedium),
              Text('Stock Analysis & Guidance Engine',
                  style: StockDTheme.labelSmall),
            ],
          ),
          const Spacer(),
          if (widget.explanation != null &&
              !widget.explanation!.isLoading &&
              widget.explanation!.chartData != null)
            _ChartToggle(
              showChart: _showChart,
              onToggle: () => setState(() => _showChart = !_showChart),
            ),
        ],
      ),
    );
  }

  // ── States ─────────────────────────────────────────────────────────────────
  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StockDTheme.sageGlow,
              border:
                  Border.all(color: StockDTheme.sage.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 28, color: StockDTheme.sage),
          ),
          const SizedBox(height: 16),
          Text('SAGE is standing by', style: StockDTheme.headingMedium),
          const SizedBox(height: 6),
          Text(
            'Answer a question incorrectly and\nSAGE will explain using real market data.',
            style: StockDTheme.bodyLarge.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation(StockDTheme.sage),
            ),
          ),
          const SizedBox(height: 16),
          Text('SAGE is analyzing...', style: StockDTheme.headingMedium),
          const SizedBox(height: 6),
          Text('Fetching real S&P 500 data',
              style: StockDTheme.bodyLarge.copyWith(fontSize: 12)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 32, color: StockDTheme.danger),
            const SizedBox(height: 12),
            Text('SAGE Unavailable',
                style: StockDTheme.headingMedium
                    .copyWith(color: StockDTheme.danger)),
            const SizedBox(height: 8),
            Text(error,
                style: StockDTheme.bodyLarge.copyWith(fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _ContinueButton(onTap: widget.onContinue),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SageExplanation explanation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          if (_showChart &&
              explanation.chartData != null &&
              explanation.chartData!.isNotEmpty) ...[
            StockChart(
              data: explanation.chartData!,
              title: explanation.chartTitle ?? 'Price History',
              height: 180,
            ),
            const SizedBox(height: 16),
          ],

          // Explanation text
          Text('EXPLANATION', style: StockDTheme.labelSmall),
          const SizedBox(height: 10),
          _ExplanationText(text: explanation.explanation),
          const SizedBox(height: 24),

          // Continue button
          _ContinueButton(onTap: widget.onContinue),
        ],
      ),
    );
  }
}

// ── Explanation Text ──────────────────────────────────────────────────────────
class _ExplanationText extends StatelessWidget {
  final String text;
  const _ExplanationText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final isBullet = line.startsWith('•');
        final isHeader = line.startsWith('──');
        final isEmpty = line.trim().isEmpty;

        if (isEmpty) return const SizedBox(height: 6);

        if (isHeader) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              line,
              style: StockDTheme.bodyMono.copyWith(
                fontSize: 11,
                color: StockDTheme.sage,
              ),
            ),
          );
        }

        if (isBullet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: StockDTheme.bodyMono.copyWith(fontSize: 12)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: StockDTheme.bodyLarge
                        .copyWith(fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: StockDTheme.bodyLarge.copyWith(fontSize: 13, height: 1.6),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

// ── Chart Toggle ──────────────────────────────────────────────────────────────
class _ChartToggle extends StatelessWidget {
  final bool showChart;
  final VoidCallback onToggle;
  const _ChartToggle({required this.showChart, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: showChart ? StockDTheme.sageGlow : StockDTheme.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: showChart
                ? StockDTheme.sage.withValues(alpha: 0.4)
                : StockDTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 13,
              color: showChart ? StockDTheme.sage : StockDTheme.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              'CHART',
              style: StockDTheme.labelSmall.copyWith(
                color: showChart ? StockDTheme.sage : StockDTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Continue Button ───────────────────────────────────────────────────────────
class _ContinueButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ContinueButton({required this.onTap});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
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
                    colors: [
                      Color(0xFF00FFB2),
                      Color(0xFF00D4FF),
                    ],
                  )
                : null,
            color: _hovered ? null : StockDTheme.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? Colors.transparent
                  : StockDTheme.sage.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'CONTINUE  →',
              style: StockDTheme.labelSmall.copyWith(
                color: _hovered ? StockDTheme.bg : StockDTheme.sage,
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
