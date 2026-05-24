import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const double kTradingStartCash = 10000.0;

// ── State ─────────────────────────────────────────────────────────────────────

class TradingState {
  final double cash;
  final Map<String, TradingPosition> positions;
  final List<TradeRecord> history;

  const TradingState({
    required this.cash,
    required this.positions,
    required this.history,
  });

  factory TradingState.initial() => const TradingState(
        cash: kTradingStartCash,
        positions: {},
        history: [],
      );

  // Portfolio value uses last known prices; falls back to avg cost when unknown.
  double portfolioValue(Map<String, double> prices) {
    double total = cash;
    for (final entry in positions.entries) {
      final price = prices[entry.key] ?? entry.value.avgCost;
      total += entry.value.marketValue(price);
    }
    return total;
  }

  TradingState copyWith({
    double? cash,
    Map<String, TradingPosition>? positions,
    List<TradeRecord>? history,
  }) =>
      TradingState(
        cash: cash ?? this.cash,
        positions: positions ?? this.positions,
        history: history ?? this.history,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class TradingNotifier extends Notifier<TradingState> {
  @override
  TradingState build() {
    _load();
    return TradingState.initial();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final cash = prefs.getDouble('trading_cash') ?? kTradingStartCash;

    Map<String, TradingPosition> positions = {};
    final posJson = prefs.getString('trading_positions');
    if (posJson != null) {
      final raw = jsonDecode(posJson) as Map<String, dynamic>;
      positions = raw.map((k, v) {
        final m = v as Map<String, dynamic>;
        return MapEntry(
          k,
          TradingPosition(
            ticker: k,
            shares: m['shares'] as int,
            avgCost: (m['avgCost'] as num).toDouble(),
          ),
        );
      });
    }

    List<TradeRecord> history = [];
    final histJson = prefs.getString('trading_history');
    if (histJson != null) {
      final raw = jsonDecode(histJson) as List<dynamic>;
      history = raw.map((e) {
        final m = e as Map<String, dynamic>;
        return TradeRecord(
          ticker: m['ticker'] as String,
          shares: m['shares'] as int,
          price: (m['price'] as num).toDouble(),
          isBuy: m['isBuy'] as bool,
          timestamp: DateTime.parse(m['timestamp'] as String),
        );
      }).toList();
    }

    state = TradingState(cash: cash, positions: positions, history: history);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('trading_cash', state.cash);

    final posMap = state.positions
        .map((k, v) => MapEntry(k, {'shares': v.shares, 'avgCost': v.avgCost}));
    await prefs.setString('trading_positions', jsonEncode(posMap));

    final histList = state.history
        .take(50)
        .map((r) => {
              'ticker': r.ticker,
              'shares': r.shares,
              'price': r.price,
              'isBuy': r.isBuy,
              'timestamp': r.timestamp.toIso8601String(),
            })
        .toList();
    await prefs.setString('trading_history', jsonEncode(histList));
  }

  // Returns null on success, or an error string on failure.
  String? buy(String ticker, int shares, double price) {
    if (shares <= 0) return 'Enter a valid quantity';
    final cost = shares * price;
    if (cost > state.cash) {
      return 'Insufficient funds — need \$${cost.toStringAsFixed(2)}';
    }

    final existing = state.positions[ticker];
    final newShares = (existing?.shares ?? 0) + shares;
    final newAvgCost = existing == null
        ? price
        : ((existing.avgCost * existing.shares) + cost) / newShares;

    final newPositions = Map<String, TradingPosition>.from(state.positions)
      ..[ticker] = TradingPosition(
        ticker: ticker,
        shares: newShares,
        avgCost: newAvgCost,
      );

    state = state.copyWith(
      cash: state.cash - cost,
      positions: newPositions,
      history: [
        TradeRecord(
          ticker: ticker,
          shares: shares,
          price: price,
          isBuy: true,
          timestamp: DateTime.now(),
        ),
        ...state.history,
      ],
    );
    _save();
    return null;
  }

  // Returns null on success, or an error string on failure.
  String? sell(String ticker, int shares, double price) {
    if (shares <= 0) return 'Enter a valid quantity';
    final existing = state.positions[ticker];
    if (existing == null || existing.shares < shares) {
      return 'Not enough shares — holding ${existing?.shares ?? 0}';
    }

    final newPositions = Map<String, TradingPosition>.from(state.positions);
    if (existing.shares == shares) {
      newPositions.remove(ticker);
    } else {
      newPositions[ticker] = TradingPosition(
        ticker: ticker,
        shares: existing.shares - shares,
        avgCost: existing.avgCost,
      );
    }

    state = state.copyWith(
      cash: state.cash + (shares * price),
      positions: newPositions,
      history: [
        TradeRecord(
          ticker: ticker,
          shares: shares,
          price: price,
          isBuy: false,
          timestamp: DateTime.now(),
        ),
        ...state.history,
      ],
    );
    _save();
    return null;
  }

  void reset() {
    state = TradingState.initial();
    _save();
  }
}

final tradingProvider = NotifierProvider<TradingNotifier, TradingState>(
  TradingNotifier.new,
);
