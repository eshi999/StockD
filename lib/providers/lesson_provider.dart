import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

enum AnswerState { unanswered, correct, wrong }

class LessonState {
  final List<StockQuestion> questions;
  final int currentIndex;
  final int score;
  final AnswerState answerState;
  final int? selectedIndex;
  final bool isComplete;

  const LessonState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.answerState = AnswerState.unanswered,
    this.selectedIndex,
    this.isComplete = false,
  });

  StockQuestion get currentQuestion => questions[currentIndex];
  double get progress => (currentIndex + 1) / questions.length;
  bool get isLastQuestion => currentIndex == questions.length - 1;

  LessonState copyWith({
    int? currentIndex,
    int? score,
    AnswerState? answerState,
    int? selectedIndex,
    bool? isComplete,
  }) =>
      LessonState(
        questions: questions,
        currentIndex: currentIndex ?? this.currentIndex,
        score: score ?? this.score,
        answerState: answerState ?? this.answerState,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isComplete: isComplete ?? this.isComplete,
      );
}

class LessonNotifier extends Notifier<LessonState?> {
  @override
  LessonState? build() => null;

  void startLesson(List<StockQuestion> questions) {
    state = LessonState(questions: questions);
  }

  void answer(int selectedIndex) {
    if (state == null || state!.answerState != AnswerState.unanswered) return;
    final correct = selectedIndex == state!.currentQuestion.correctIndex;
    state = state!.copyWith(
      selectedIndex: selectedIndex,
      answerState: correct ? AnswerState.correct : AnswerState.wrong,
      score: correct ? state!.score + 1 : state!.score,
    );
  }

  void next() {
    if (state == null) return;
    if (state!.isLastQuestion) {
      state = state!.copyWith(isComplete: true);
      return;
    }
    state = state!.copyWith(
      currentIndex: state!.currentIndex + 1,
      answerState: AnswerState.unanswered,
      selectedIndex: null,
    );
  }

  void reset() => state = null;
}

final lessonProvider = NotifierProvider<LessonNotifier, LessonState?>(
  LessonNotifier.new,
);
