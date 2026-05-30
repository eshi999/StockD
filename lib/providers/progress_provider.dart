import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class ProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() {
    _loadSaved();
    return UserProgress(); // default while loading
  }

  Future<void> _loadSaved() async {
    final storage = StorageService();
    final saved = await storage.loadProgress();
    state = saved;
  }

  void recordAnswer({required bool correct}) {
    state = UserProgress(
      xp: state.xp + (correct ? 10 : 0),
      streak: state.streak,
      hearts: correct ? state.hearts : (state.hearts - 1).clamp(0, 5),
      totalCorrect: state.totalCorrect + (correct ? 1 : 0),
      totalAnswered: state.totalAnswered + 1,
    );
    _save();
  }

  void completeLevel({required int score}) {
    final bonus = score >= 20
        ? 150
        : score >= 16
            ? 100
            : score >= 12
                ? 50
                : 0;
    state = UserProgress(
      xp: state.xp + bonus,
      streak: state.streak,
      hearts: state.hearts,
      totalCorrect: state.totalCorrect,
      totalAnswered: state.totalAnswered,
    );
    _save();
  }

  void refillHearts() {
    state = UserProgress(
      xp: state.xp,
      streak: state.streak,
      hearts: 5,
      totalCorrect: state.totalCorrect,
      totalAnswered: state.totalAnswered,
    );
    _save();
  }

  Future<void> _save() async {
    await StorageService().saveProgress(state);
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, UserProgress>(
  ProgressNotifier.new,
);
