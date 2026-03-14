import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class SageService {
  static const String _baseUrl = 'http://localhost:8000';
  final http.Client _client = http.Client();

  // ── Health check ──────────────────────────────────────────────────────────
  Future<bool> isBackendAlive() async {
    try {
      final res = await _client
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── SAGE explanation on wrong answer ──────────────────────────────────────
  Future<SageExplanation> explainQuestion({
    required StockQuestion question,
    required int userAnswerIndex,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_baseUrl/sage/explain'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'question_id': question.id,
              'concept': question.concept,
              'prompt': question.sagePrompt,
              'user_answer': question.options[userAnswerIndex],
              'correct_answer': question.options[question.correctIndex],
              'chart_symbol': question.chartSymbol,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return SageExplanation(
          questionId: question.id,
          explanation: data['explanation'] as String,
          chartTitle: data['chart_title'] as String?,
          chartData: _parseChartData(data['chart_data']),
        );
      }
    } catch (_) {}
    return _fallback(question);
  }

  // ── SAGE Chat ─────────────────────────────────────────────────────────────
  Future<String> chat({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_baseUrl/sage/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'history': history,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['response'] as String;
      }
    } catch (_) {}
    return _chatFallback(message);
  }

  // ── Historical price data ─────────────────────────────────────────────────
  Future<List<ChartPoint>> getHistoricalData(
    String symbol, {
    String timeframe = '1Y',
  }) async {
    try {
      final res = await _client
          .get(Uri.parse('$_baseUrl/history/$symbol?timeframe=$timeframe'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final dates = data['dates'] as List;
        final closes = data['closes'] as List;
        return List.generate(
            dates.length,
            (i) => ChartPoint(
                  date: DateTime.parse(dates[i] as String),
                  close: (closes[i] as num).toDouble(),
                ));
      }
    } catch (_) {}
    return _mockChartData();
  }

  // ── Market snapshot ───────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getMarketSnapshot() async {
    try {
      final res = await _client
          .get(Uri.parse('$_baseUrl/market/snapshot'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  List<ChartPoint>? _parseChartData(dynamic raw) {
    if (raw == null) return null;
    try {
      return (raw as List).map((item) {
        final m = item as Map<String, dynamic>;
        return ChartPoint(
          date: DateTime.parse(m['date'] as String),
          close: (m['close'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  SageExplanation _fallback(StockQuestion question) {
    return SageExplanation(
      questionId: question.id,
      explanation: '${question.briefExplanation}\n\n'
          'Correct answer: ${question.options[question.correctIndex]}\n\n'
          'Start the Python backend for full AI explanations:\n'
          'cd ML && python3.12 -m uvicorn main:app --port 8000 --reload',
      chartData: _mockChartData(),
      chartTitle: 'S&P 500 — Demo Data',
    );
  }

  String _chatFallback(String message) {
    return 'SAGE is currently offline.\n\n'
        'Start the backend to enable chat:\n'
        'cd ML && python3.12 -m uvicorn main:app --port 8000 --reload\n\n'
        '⚠️ Educational information only, not financial advice.';
  }

  List<ChartPoint> _mockChartData() {
    final now = DateTime.now();
    double price = 4500;
    return List.generate(30, (i) {
      price += (price * 0.005) * (i % 3 == 0 ? -1 : 1);
      return ChartPoint(
        date: now.subtract(Duration(days: 30 - i)),
        close: price,
      );
    });
  }
}

final sageServiceProvider = Provider<SageService>(
  (ref) => SageService(),
);
