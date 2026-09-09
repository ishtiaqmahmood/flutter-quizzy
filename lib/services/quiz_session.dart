import 'dart:async';
import '../models/question.dart';
import '../models/quiz_result.dart';

class QuizSession {
  final String id;
  final Category category;
  final Difficulty difficulty;
  final List<Question> questions;
  final int timeLimitSeconds;

  int _currentIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _streak = 0;
  int _maxStreak = 0;
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isCompleted = false;

  QuizSession({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.questions,
    this.timeLimitSeconds = 60,
  }) : _timeRemaining = timeLimitSeconds;

  Question get currentQuestion => questions[_currentIndex];
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  int get streak => _streak;
  int get maxStreak => _maxStreak;
  int get timeRemaining => _timeRemaining;
  bool get isCompleted => _isCompleted;
  int get totalQuestions => questions.length;
  bool get hasMoreQuestions => _currentIndex < questions.length - 1;

  void startTimer(Function(int) onTick, Function() onTimeUp) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        onTick(_timeRemaining);
      } else {
        _timer?.cancel();
        onTimeUp();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  bool answerQuestion(String userAnswer) {
    if (_isCompleted) return false;

    final question = questions[_currentIndex];
    bool isCorrect = false;

    // Check answer based on question type
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        isCorrect = userAnswer == question.correctAnswer;
        break;
      case QuestionType.fillInTheBlank:
        isCorrect = userAnswer.trim().toLowerCase() == 
                    question.correctAnswer.trim().toLowerCase();
        break;
    }

    if (isCorrect) {
      _correctAnswers++;
      _streak++;
      if (_streak > _maxStreak) {
        _maxStreak = _streak;
      }
      // Calculate points: base points + streak bonus
      int basePoints = question.points;
      int streakBonus = (_streak - 1) * 2; // 2 bonus points per consecutive correct answer
      _score += basePoints + streakBonus;
    } else {
      _streak = 0;
    }

    return isCorrect;
  }

  void nextQuestion() {
    if (_currentIndex < questions.length - 1) {
      _currentIndex++;
      _timeRemaining = timeLimitSeconds;
    }
  }

  QuizResult finishQuiz() {
    _isCompleted = true;
    _timer?.cancel();
    
    return QuizResult(
      id: id,
      category: category,
      difficulty: difficulty,
      score: _score,
      totalQuestions: questions.length,
      correctAnswers: _correctAnswers,
      streak: _maxStreak,
      completedAt: DateTime.now(),
    );
  }

  void dispose() {
    _timer?.cancel();
  }
}
