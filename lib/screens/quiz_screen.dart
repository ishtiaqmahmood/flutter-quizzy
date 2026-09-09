import 'package:flutter/material.dart';
import 'dart:async';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/question_bank_service.dart';
import '../services/quiz_session.dart';
import '../services/storage_service.dart';
import '../widgets/question_widget.dart';

class QuizScreen extends StatefulWidget {
  final Category category;
  final Difficulty difficulty;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.category,
    required this.difficulty,
    required this.questionCount,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizSession _session;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isAnswered = false;
  Timer? _timer;
  int _timeRemaining = 30;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    final questionBank = QuestionBankService();
    await questionBank.initialize();

    final questions = questionBank.getQuestions(
      category: widget.category,
      difficulty: widget.difficulty,
      limit: widget.questionCount,
    );

    setState(() {
      _session = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: widget.category,
        difficulty: widget.difficulty,
        questions: questions,
        timeLimitSeconds: 30,
      );
      _timeRemaining = 30;
      _isLoading = false;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && !_showResult) {
        setState(() {
          _timeRemaining--;
        });
      } else if (_timeRemaining == 0 && !_isAnswered) {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    if (!_isAnswered) {
      setState(() {
        _isAnswered = true;
        _showResult = true;
        _selectedAnswer = null;
      });
      
      // Auto-advance after showing result
      Future.delayed(const Duration(seconds: 2), () {
        if (_session.hasMoreQuestions) {
          _nextQuestion();
        } else {
          _finishQuiz();
        }
      });
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _isAnswered) return;

    final isCorrect = _session.answerQuestion(_selectedAnswer!);
    
    setState(() {
      _isAnswered = true;
      _showResult = true;
    });

    // Auto-advance after showing result
    Future.delayed(const Duration(seconds: 2), () {
      if (_session.hasMoreQuestions) {
        _nextQuestion();
      } else {
        _finishQuiz();
      }
    });
  }

  void _nextQuestion() {
    _session.nextQuestion();
    setState(() {
      _selectedAnswer = null;
      _showResult = false;
      _isAnswered = false;
      _timeRemaining = 30;
    });
  }

  void _finishQuiz() {
    _timer?.cancel();
    final result = _session.finishQuiz();
    StorageService().saveQuizResult(result);
    
    Navigator.pushReplacementNamed(
      context,
      '/result',
      arguments: result,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_session.currentIndex + 1}/${_session.totalQuestions}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _buildTimerWidget(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_session.currentIndex + 1) / _session.totalQuestions,
            minHeight: 6,
          ),
          
          // Score and streak info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Score', _session.score.toString(), Icons.star, Colors.amber),
                _buildStatCard('Streak', '${_session.streak}🔥', Icons.local_fire_department, Colors.orange),
                _buildStatCard('Correct', '${_session.correctAnswers}', Icons.check_circle, Colors.green),
              ],
            ),
          ),
          
          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: QuestionWidget(
                question: _session.currentQuestion,
                questionNumber: _session.currentIndex + 1,
                selectedAnswer: _selectedAnswer,
                showResult: _showResult,
                onAnswerSelected: (answer) {
                  if (!_isAnswered) {
                    setState(() {
                      _selectedAnswer = answer;
                    });
                  }
                },
              ),
            ),
          ),
          
          // Submit button
          if (!_showResult)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAnswered ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT ANSWER',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget() {
    Color timerColor;
    if (_timeRemaining > 20) {
      timerColor = Colors.green;
    } else if (_timeRemaining > 10) {
      timerColor = Colors.orange;
    } else {
      timerColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: timerColor, size: 20),
          const SizedBox(width: 4),
          Text(
            '$_timeRemaining',
            style: TextStyle(
              color: timerColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
