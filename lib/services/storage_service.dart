import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const _keyXP = 'user_xp';
  static const _keyStreak = 'user_streak';
  static const _keyHearts = 'user_hearts';
  static const _keyTotalCorrect = 'user_total_correct';
  static const _keyTotalAnswered = 'user_total_answered';
  static const _keyLevelStars = 'level_stars_';
  static const _keyLevelScores = 'level_scores_';

  // ── Save / Load Progress ──────────────────────────────────────────────────
  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXP, progress.xp);
    await prefs.setInt(_keyStreak, progress.streak);
    await prefs.setInt(_keyHearts, progress.hearts);
    await prefs.setInt(_keyTotalCorrect, progress.totalCorrect);
    await prefs.setInt(_keyTotalAnswered, progress.totalAnswered);
  }

  Future<UserProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProgress(
      xp: prefs.getInt(_keyXP) ?? 0,
      streak: prefs.getInt(_keyStreak) ?? 0,
      hearts: prefs.getInt(_keyHearts) ?? 5,
      totalCorrect: prefs.getInt(_keyTotalCorrect) ?? 0,
      totalAnswered: prefs.getInt(_keyTotalAnswered) ?? 0,
    );
  }

  // ── Save / Load Level Results ─────────────────────────────────────────────
  Future<void> saveLevelResult(String levelId, int stars, int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyLevelStars$levelId', stars);
    await prefs.setInt('$_keyLevelScores$levelId', score);
  }

  Future<({int stars, int score})> loadLevelResult(String levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return (
      stars: prefs.getInt('$_keyLevelStars$levelId') ?? 0,
      score: prefs.getInt('$_keyLevelScores$levelId') ?? 0,
    );
  }

  // ── Apply saved results to curriculum ────────────────────────────────────
  Future<void> applyToLevels(List<Level> levels) async {
    for (int i = 0; i < levels.length; i++) {  // ✅ index-based loop
      final result = await loadLevelResult(levels[i].id);
      levels[i].stars = result.stars;
      levels[i].bestScore = result.score;
      if (result.stars > 0) {
        levels[i].isUnlocked = true;
        if (i + 1 < levels.length) {            // ✅ also unlocks next level
          levels[i + 1].isUnlocked = true;
        }
      }
    }
  }

  // ── Clear all data ────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
