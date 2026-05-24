import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/trading_provider.dart';
import '../../providers/sage_provider.dart';
import '../../services/sage_service.dart';
import '../../widgets/stock_chart.dart';

class TradingScreen extends ConsumerStatefulWidget {
  const TradingScreen({super.key});

  @override
  ConsumerState<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends ConsumerState<TradingScreen> {
  static const _tickers = [
    'AAPL',
    'MSFT',
    'GOOGL',
    'AMZN',
    'NVDA',
    'META',
    'TSLA',
    'JPM',
    'V',
    'SPY',
  ];

  String _ticker = 'AAPL';
  List<ChartPoint> _chartData = [];
  bool _chartLoading = false;
  bool _isBuying = true;
  final _qtyController = TextEditingController(text: '1');
  final _searchController = TextEditingController();
  String? _feedback;
  bool _feedbackIsError = false;

  // Last known price per ticker, populated as charts load.
  final Map<String, double> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadChart(_ticker);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChart(String ticker) async {
    setState(() {
      _chartLoading = true;
      _chartData = [];
    });
    final data = await ref.read(sageServiceProvider).getHistoricalData(ticker);
    if (!mounted) return;
    setState(() {
      _chartData = data;
      _chartLoading = false;
      if (data.isNotEmpty) _prices[ticker] = data.last.close;
    });
  }

  double get _currentPrice => _prices[_ticker] ?? 0.0;

  void _submitTrade() {
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
    if (_currentPrice <= 0) {
      _setFeedback('Price data unavailable', isError: true);
      return;
    }
    final notifier = ref.read(tradingProvider.notifier);
    final error = _isBuying
        ? notifier.buy(_ticker, qty, _currentPrice)
        : notifier.sell(_ticker, qty, _currentPrice);

    if (error != null) {
      _setFeedback(error, isError: true);
    } else {
      final action = _isBuying ? 'Bought' : 'Sold';
      _setFeedback(
        '$action $qty x $_ticker at \$${_currentPrice.toStringAsFixed(2)}',
        isError: false,
      );
    }
  }

  void _setFeedback(String msg, {required bool isError}) => setState(() {
        _feedback = msg;
        _feedbackIsError = isError;
      });

  void _confirmReset() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StockDTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: StockDTheme.border),
        ),
        title: Text('Reset Portfolio', style: StockDTheme.headingMedium),
        content: Text(
          'This will clear all positions and trade history, '
          'and restore your cash to \$${kTradingStartCash.toStringAsFixed(0)}.',
          style: StockDTheme.bodyLarge.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: StockDTheme.labelSmall),
          ),
          TextButton(
            onPressed: () {
              ref.read(tradingProvider.notifier).reset();
              setState(() => _feedback = null);
              Navigator.pop(ctx);
            },
            child: Text(
              'RESET',
              style: StockDTheme.labelSmall.copyWith(color: StockDTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trading = ref.watch(tradingProvider);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 900;

    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildLeftPanel(trading)),
                    const VerticalDivider(width: 1, color: StockDTheme.border),
                    SizedBox(
                      width: 280,
                      child: _buildRightPanel(trading),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLeftPanel(trading),
                      const Divider(height: 1, color: StockDTheme.border),
                      _buildRightPanel(trading),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    final backend = ref.watch(backendProvider);
    final isOnline = backend == BackendStatus.online;

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
          Text(
            'TRADING SIM',
            style: StockDTheme.labelSmall.copyWith(color: StockDTheme.gold),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: (isOnline ? StockDTheme.sage : StockDTheme.textMuted)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: (isOnline ? StockDTheme.sage : StockDTheme.textMuted)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              isOnline ? 'LIVE DATA' : 'SIMULATED DATA',
              style: StockDTheme.labelSmall.copyWith(
                color: isOnline ? StockDTheme.sage : StockDTheme.textMuted,
                fontSize: 9,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _confirmReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: StockDTheme.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: StockDTheme.border),
              ),
              child: Text('RESET', style: StockDTheme.labelSmall),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ── Left Panel ────────────────────────────────────────────────────────────

  Widget _buildLeftPanel(TradingState trading) {
    final position = trading.positions[_ticker];
    final change = _chartData.length >= 2
        ? ((_currentPrice - _chartData.first.close) / _chartData.first.close) *
            100
        : 0.0;
    final isPositive = change >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ticker selector + price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: StockDTheme.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: StockDTheme.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    // Show null in the dropdown when a custom ticker is active
                    value: _tickers.contains(_ticker) ? _ticker : null,
                    hint: Text(_ticker, style: StockDTheme.headingMedium),
                    dropdownColor: StockDTheme.card,
                    style: StockDTheme.headingMedium,
                    items: _tickers
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t),
                            ))
                        .toList(),
                    onChanged: (t) {
                      if (t != null && t != _ticker) {
                        setState(() {
                          _ticker = t;
                          _feedback = null;
                          _searchController.clear();
                        });
                        _loadChart(t);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Custom ticker search field
              SizedBox(
                width: 130,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.characters,
                  style: StockDTheme.bodyMono.copyWith(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Any ticker...',
                    hintStyle: StockDTheme.labelSmall,
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 15, color: StockDTheme.textMuted),
                    filled: true,
                    fillColor: StockDTheme.surface,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: StockDTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: StockDTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: StockDTheme.gold),
                    ),
                  ),
                  onSubmitted: (val) {
                    final t = val.trim().toUpperCase();
                    if (t.isNotEmpty && t != _ticker) {
                      setState(() {
                        _ticker = t;
                        _feedback = null;
                      });
                      _loadChart(t);
                    }
                    _searchController.clear();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPrice > 0
                        ? '\$${_currentPrice.toStringAsFixed(2)}'
                        : '--',
                    style: StockDTheme.headingLarge,
                  ),
                  if (_currentPrice > 0 && _chartData.length >= 2)
                    Text(
                      '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%  1Y',
                      style: StockDTheme.bodyMono.copyWith(
                        fontSize: 11,
                        color:
                            isPositive ? StockDTheme.sage : StockDTheme.danger,
                      ),
                    ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          // Chart
          _chartLoading
              ? Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: StockDTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StockDTheme.border),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(StockDTheme.sage),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : StockChart(
                  data: _chartData,
                  title: _ticker,
                  height: 220,
                ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Trade panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StockDTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StockDTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buy / Sell toggle + holding info
                Row(
                  children: [
                    _TradeToggle(
                      label: 'BUY',
                      active: _isBuying,
                      color: StockDTheme.sage,
                      onTap: () => setState(() {
                        _isBuying = true;
                        _feedback = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _TradeToggle(
                      label: 'SELL',
                      active: !_isBuying,
                      color: StockDTheme.danger,
                      onTap: () => setState(() {
                        _isBuying = false;
                        _feedback = null;
                      }),
                    ),
                    const Spacer(),
                    if (position != null)
                      Text(
                        'Holding: ${position.shares} shares',
                        style: StockDTheme.labelSmall,
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Quantity + estimated total
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        style: StockDTheme.bodyMono,
                        decoration: InputDecoration(
                          labelText: 'SHARES',
                          labelStyle: StockDTheme.labelSmall,
                          filled: true,
                          fillColor: StockDTheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: StockDTheme.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: StockDTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: StockDTheme.sage),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('EST. TOTAL', style: StockDTheme.labelSmall),
                        const SizedBox(height: 3),
                        Text(
                          () {
                            final qty = int.tryParse(_qtyController.text) ?? 0;
                            return '\$${(qty * _currentPrice).toStringAsFixed(2)}';
                          }(),
                          style: StockDTheme.bodyMono,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Submit button
                _SubmitButton(
                  isBuying: _isBuying,
                  ticker: _ticker,
                  onTap: _submitTrade,
                ),

                // Feedback
                if (_feedback != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _feedback!,
                    style: StockDTheme.bodyLarge.copyWith(
                      fontSize: 12,
                      color: _feedbackIsError
                          ? StockDTheme.danger
                          : StockDTheme.sage,
                    ),
                  ).animate().fadeIn(duration: 200.ms),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
        ],
      ),
    );
  }

  // ── Right Panel ───────────────────────────────────────────────────────────

  Widget _buildRightPanel(TradingState trading) {
    final value = trading.portfolioValue(_prices);
    final pnl = value - kTradingStartCash;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PORTFOLIO', style: StockDTheme.labelSmall),
          const SizedBox(height: 10),
          _PortfolioSummary(
            cash: trading.cash,
            totalValue: value,
            pnl: pnl,
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          Text('HOLDINGS', style: StockDTheme.labelSmall),
          const SizedBox(height: 8),
          if (trading.positions.isEmpty)
            Text(
              'No open positions',
              style: StockDTheme.bodyLarge.copyWith(fontSize: 12),
            )
          else
            ...trading.positions.entries.map(
              (e) => _HoldingRow(
                position: e.value,
                currentPrice: _prices[e.key] ?? e.value.avgCost,
              ).animate().fadeIn(duration: 300.ms),
            ),
          const SizedBox(height: 20),
          Text('RECENT TRADES', style: StockDTheme.labelSmall),
          const SizedBox(height: 8),
          if (trading.history.isEmpty)
            Text(
              'No trades yet',
              style: StockDTheme.bodyLarge.copyWith(fontSize: 12),
            )
          else
            ...trading.history.take(10).map(
                  (r) =>
                      _TradeRow(record: r).animate().fadeIn(duration: 250.ms),
                ),
        ],
      ),
    );
  }
}

// ── Trade Toggle ──────────────────────────────────────────────────────────────

class _TradeToggle extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _TradeToggle({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : StockDTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.6) : StockDTheme.border,
          ),
        ),
        child: Text(
          label,
          style: StockDTheme.labelSmall.copyWith(
            color: active ? color : StockDTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

// ── Submit Button ─────────────────────────────────────────────────────────────

class _SubmitButton extends StatefulWidget {
  final bool isBuying;
  final String ticker;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isBuying,
    required this.ticker,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isBuying ? StockDTheme.sage : StockDTheme.danger;
    final label =
        widget.isBuying ? 'BUY ${widget.ticker}' : 'SELL ${widget.ticker}';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: _hovered ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Center(
            child: Text(
              label,
              style: StockDTheme.labelSmall.copyWith(
                color: _hovered ? StockDTheme.bg : color,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Portfolio Summary ─────────────────────────────────────────────────────────

class _PortfolioSummary extends StatelessWidget {
  final double cash;
  final double totalValue;
  final double pnl;

  const _PortfolioSummary({
    required this.cash,
    required this.totalValue,
    required this.pnl,
  });

  @override
  Widget build(BuildContext context) {
    final pnlPositive = pnl >= 0;
    final pnlColor = pnlPositive ? StockDTheme.sage : StockDTheme.danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StockDTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'CASH',
            value: '\$${cash.toStringAsFixed(2)}',
            color: StockDTheme.textPrimary,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'TOTAL VALUE',
            value: '\$${totalValue.toStringAsFixed(2)}',
            color: StockDTheme.textPrimary,
          ),
          const Divider(height: 16, color: StockDTheme.border),
          _SummaryRow(
            label: 'TOTAL P&L',
            value: '${pnlPositive ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
            color: pnlColor,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: StockDTheme.labelSmall),
        Text(
          value,
          style: StockDTheme.bodyMono.copyWith(fontSize: 12, color: color),
        ),
      ],
    );
  }
}

// ── Holding Row ───────────────────────────────────────────────────────────────

class _HoldingRow extends StatelessWidget {
  final TradingPosition position;
  final double currentPrice;

  const _HoldingRow({
    required this.position,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final pnl = position.pnl(currentPrice);
    final pnlPct = position.pnlPercent(currentPrice);
    final isPositive = pnl >= 0;
    final color = isPositive ? StockDTheme.sage : StockDTheme.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: StockDTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(position.ticker, style: StockDTheme.headingMedium),
                Text(
                  '${position.shares} shares  avg \$${position.avgCost.toStringAsFixed(2)}',
                  style: StockDTheme.bodyLarge.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${position.marketValue(currentPrice).toStringAsFixed(2)}',
                style: StockDTheme.bodyMono.copyWith(fontSize: 12),
              ),
              Text(
                '${isPositive ? '+' : ''}\$${pnl.toStringAsFixed(2)} '
                '(${pnlPct.toStringAsFixed(1)}%)',
                style: StockDTheme.labelSmall.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Trade Row ─────────────────────────────────────────────────────────────────

class _TradeRow extends StatelessWidget {
  final TradeRecord record;

  const _TradeRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = record.isBuy ? StockDTheme.sage : StockDTheme.danger;
    final label = record.isBuy ? 'BUY' : 'SELL';
    final dt = record.timestamp;
    final timeStr =
        '${dt.month}/${dt.day}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: StockDTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StockDTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: StockDTheme.labelSmall.copyWith(color: color),
            ),
          ),
          const SizedBox(width: 8),
          Text(record.ticker,
              style: StockDTheme.headingMedium.copyWith(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            '${record.shares} @ \$${record.price.toStringAsFixed(2)}',
            style: StockDTheme.bodyLarge.copyWith(fontSize: 11),
          ),
          const Spacer(),
          Text(timeStr, style: StockDTheme.labelSmall),
        ],
      ),
    );
  }
}
