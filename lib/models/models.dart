import 'package:flutter/material.dart';

enum Difficulty { beginner, intermediate, advanced }

enum QuestionType { multipleChoice, trueFalse, chartRead }

// Question
class StockQuestion {
  final String id;
  final String prompt;
  final QuestionType type;
  final List<String> options;
  final int correctIndex;
  final String concept;
  final String? chartSymbol;
  final String briefExplanation;
  final String sagePrompt;

  const StockQuestion(
      {required this.id,
      required this.prompt,
      required this.type,
      required this.options,
      required this.correctIndex,
      required this.concept,
      this.chartSymbol,
      required this.briefExplanation,
      required this.sagePrompt});
}

// Level
class Level {
  final String id;
  final String title;
  final String subtitle;
  final int worldIndex;
  final int levelIndex;
  final List<StockQuestion> questions;
  bool isUnlocked;
  int stars;
  int bestScore;

  Level({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.worldIndex,
    required this.levelIndex,
    required this.questions,
    this.isUnlocked = false,
    this.stars = 0,
    this.bestScore = 0,
  });

  bool get isCompleted => stars > 0;
}

// World
class World {
  final int index;
  final String title;
  final String subtitle;
  final Difficulty difficulty;
  final String imagePath;
  final List<Level> levels;
  final Color accentColor;

  World({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.levels,
    required this.accentColor,
    required this.imagePath,
  });

  bool get isUnlocked => index == 0 || levels.any((level) => level.isCompleted);
  int get completedLevels => levels.where((level) => level.isCompleted).length;
  double get progress => completedLevels / levels.length;
}

// User Progress
class UserProgress {
  int xp;
  int streak;
  int hearts;
  int totalCorrect;
  int totalAnswered;

  UserProgress({
    this.xp = 0,
    this.streak = 0,
    this.hearts = 5,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
  });

  double get accuracy => totalAnswered > 0 ? totalCorrect / totalAnswered : 0.0;

  String get xpLabel {
    if (xp < 500) return 'Beginner';
    if (xp < 1000) return 'Intermediate';
    if (xp < 3000) return 'Advanced';
    return 'Fund Manager';
  }
}

// Sage Explanation
class SageExplanation {
  final String explanation;
  final String questionId;
  final List<ChartPoint>? chartData;
  final String? chartTitle;
  final bool isLoading;
  final String? error;

  const SageExplanation({
    required this.explanation,
    required this.questionId,
    this.chartData,
    this.chartTitle,
    this.isLoading = false,
    this.error,
  });

  factory SageExplanation.loading(String qid) => SageExplanation(
        explanation: '',
        questionId: qid,
        isLoading: true,
      );

  factory SageExplanation.error(String qid, String error) => SageExplanation(
        explanation: '',
        questionId: qid,
        isLoading: false,
        error: error,
      );
}

// Chart Point
class ChartPoint {
  final DateTime date;
  final double close;
  const ChartPoint({
    required this.date,
    required this.close,
  });
}
