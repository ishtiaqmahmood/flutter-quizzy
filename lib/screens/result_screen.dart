import 'package:flutter/material.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final percentage = (result.correctAnswers / result.totalQuestions * 100).round();
    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = 'Excellent!';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (percentage >= 60) {
      message = 'Good Job!';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 40) {
      message = 'Keep Practicing!';
      icon = Icons.sentiment_satisfied;
      color = Colors.orange;
    } else {
      message = 'Don\'t Give Up!';
      icon = Icons.sentiment_dissatisfied;
      color = Colors.red;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              
              // Result Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: color,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'You scored $percentage%',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Score Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildScoreRow('Total Score', '${result.score}', Icons.star, Colors.amber),
                      const Divider(),
                      _buildScoreRow('Correct Answers', '${result.correctAnswers}/${result.totalQuestions}', Icons.check_circle, Colors.green),
                      const Divider(),
                      _buildScoreRow('Best Streak', '${result.streak}🔥', Icons.local_fire_department, Colors.orange),
                      const Divider(),
                      _buildScoreRow('Category', _getCategoryName(result.category), Icons.category, Colors.blue),
                      const Divider(),
                      _buildScoreRow('Difficulty', _getDifficultyName(result.difficulty), Icons.trending_up, Colors.purple),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/setup',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'PLAY AGAIN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'BACK TO HOME',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(Category category) {
    switch (category) {
      case Category.science:
        return 'Science';
      case Category.history:
        return 'History';
      case Category.sports:
        return 'Sports';
      case Category.geography:
        return 'Geography';
      case Category.literature:
        return 'Literature';
    }
  }

  String _getDifficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
