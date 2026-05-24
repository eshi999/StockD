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

  // ── Apply saved results to all worlds + propagate world unlocks ──────────
  Future<void> applyToWorlds(List<World> worlds) async {
    // Load level progress for every world
    for (final world in worlds) {
      await applyToLevels(world.levels);
    }
    // World 0 is always unlocked
    worlds[0].isUnlocked = true;
    // Unlock world N+1 only when world N's last level is completed
    for (int i = 1; i < worlds.length; i++) {
      if (worlds[i - 1].levels.last.isCompleted) {
        worlds[i].isUnlocked = true;
      }
    }
  }

  // ── Apply saved results to curriculum ────────────────────────────────────
  Future<void> applyToLevels(List<Level> levels) async {
    for (int i = 0; i < levels.length; i++) {
      final result = await loadLevelResult(levels[i].id);
      levels[i].stars = result.stars;
      levels[i].bestScore = result.score;
      if (result.stars > 0) {
        levels[i].isUnlocked = true;
        if (i + 1 < levels.length) {
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
