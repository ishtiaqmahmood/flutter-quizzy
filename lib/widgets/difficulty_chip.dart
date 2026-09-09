import 'package:flutter/material.dart';
import '../models/question.dart';

class DifficultyChip extends StatelessWidget {
  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const DifficultyChip({
    super.key,
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  String _getDifficultyName() {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  Color _getDifficultyColor() {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? _getDifficultyColor() : _getDifficultyColor().withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getDifficultyColor(),
            width: 2,
          ),
        ),
        child: Text(
          _getDifficultyName(),
          style: TextStyle(
            color: isSelected ? Colors.white : _getDifficultyColor(),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
