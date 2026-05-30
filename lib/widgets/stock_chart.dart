import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class StockChart extends StatefulWidget {
  final List<ChartPoint> data;
  final String title;
  final Color? color;
  final bool showGrid;
  final bool showVolume;
  final double height;

  const StockChart({
    super.key,
    required this.data,
    required this.title,
    this.color,
    this.showGrid = true,
    this.showVolume = false,
    this.height = 220,
  });

  @override
  State<StockChart> createState() => _StockChartState();
}

class _StockChartState extends State<StockChart> {
  int? _touchedIndex;

  List<FlSpot> get _spots => widget.data
      .asMap()
      .entries
      .map((e) => FlSpot(e.key.toDouble(), e.value.close))
      .toList();

  double get _minY {
    if (widget.data.isEmpty) return 0;
    final min = widget.data.map((p) => p.close).reduce((a, b) => a < b ? a : b);
    return (min * 0.995).floorToDouble();
  }

  double get _maxY {
    if (widget.data.isEmpty) return 100;
    final max = widget.data.map((p) => p.close).reduce((a, b) => a > b ? a : b);
    return (max * 1.005).ceilToDouble();
  }

  bool get _isPositive {
    if (widget.data.length < 2) return true;
    return widget.data.last.close >= widget.data.first.close;
  }

  double get _changePercent {
    if (widget.data.length < 2) return 0;
    final first = widget.data.first.close;
    final last = widget.data.last.close;
    return ((last - first) / first) * 100;
  }

  Color get _chartColor =>
      widget.color ?? (_isPositive ? StockDTheme.sage : StockDTheme.danger);

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return _buildEmpty();

    return Container(
      decoration: BoxDecoration(
        color: StockDTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StockDTheme.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          SizedBox(
            height: widget.height,
            child: _buildChart(),
          ),
          if (_touchedIndex != null) ...[
            const SizedBox(height: 8),
            _buildTooltip(),
          ],
          const SizedBox(height: 8),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final sign = _isPositive ? '+' : '';
    final pctStr = '$sign${_changePercent.toStringAsFixed(2)}%';
    final price = widget.data.isNotEmpty
        ? '\$${widget.data.last.close.toStringAsFixed(2)}'
        : '--';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: StockDTheme.labelSmall),
              const SizedBox(height: 2),
              Text(price,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: StockDTheme.textPrimary,
                  )),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _chartColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _chartColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(
                _isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: _chartColor,
              ),
              const SizedBox(width: 3),
              Text(pctStr,
                  style: StockDTheme.bodyMono
                      .copyWith(fontSize: 12, color: _chartColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final spots = _spots;
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          horizontalInterval: (_maxY - _minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: StockDTheme.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: StockDTheme.labelSmall,
                ),
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (widget.data.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= widget.data.length) {
                  return const SizedBox.shrink();
                }
                final date = widget.data[idx].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: StockDTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (widget.data.length - 1).toDouble(),
        minY: _minY,
        maxY: _maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (event, response) {
            setState(() {
              if (response?.lineBarSpots?.isNotEmpty == true &&
                  event is FlPointerHoverEvent) {
                _touchedIndex = response!.lineBarSpots!.first.spotIndex;
              } else {
                _touchedIndex = null;
              }
            });
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => StockDTheme.surface,
            tooltipBorder: const BorderSide(color: StockDTheme.border),
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              final pt = widget.data[s.spotIndex];
              return LineTooltipItem(
                '\$${pt.close.toStringAsFixed(2)}\n'
                '${pt.date.month}/${pt.date.day}/${pt.date.year}',
                StockDTheme.bodyMono.copyWith(fontSize: 11),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: _chartColor,
            barWidth: 2,
            dotData: FlDotData(
              show: _touchedIndex != null,
              checkToShowDot: (spot, barData) {
                final idx = spots.indexOf(spot);
                return idx == _touchedIndex;
              },
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: _chartColor,
                strokeWidth: 2,
                strokeColor: StockDTheme.bg,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _chartColor.withValues(alpha: 0.15),
                  _chartColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildTooltip() {
    if (_touchedIndex == null || _touchedIndex! >= widget.data.length) {
      return const SizedBox.shrink();
    }
    final pt = widget.data[_touchedIndex!];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: StockDTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${pt.date.year}-'
            '${pt.date.month.toString().padLeft(2, '0')}-'
            '${pt.date.day.toString().padLeft(2, '0')}',
            style: StockDTheme.labelSmall,
          ),
          const SizedBox(width: 12),
          Text(
            '\$${pt.close.toStringAsFixed(2)}',
            style:
                StockDTheme.bodyMono.copyWith(fontSize: 12, color: _chartColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    final first = widget.data.first;
    final last = widget.data.last;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${first.date.month}/${first.date.day}/${first.date.year}',
          style: StockDTheme.labelSmall,
        ),
        Text(
          '${last.date.month}/${last.date.day}/${last.date.year}',
          style: StockDTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: StockDTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 32, color: StockDTheme.textMuted),
            const SizedBox(height: 8),
            Text('No chart data available', style: StockDTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
