import 'package:flutter/material.dart';
import '../models/question.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final int questionCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.questionCount,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (category) {
      case Category.science:
        return Icons.science;
      case Category.history:
        return Icons.history_edu;
      case Category.sports:
        return Icons.sports;
      case Category.geography:
        return Icons.public;
      case Category.literature:
        return Icons.menu_book;
    }
  }

  Color _getCategoryColor() {
    switch (category) {
      case Category.science:
        return Colors.blue;
      case Category.history:
        return Colors.amber;
      case Category.sports:
        return Colors.green;
      case Category.geography:
        return Colors.teal;
      case Category.literature:
        return Colors.purple;
    }
  }

  String _getCategoryName() {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [_getCategoryColor(), _getCategoryColor().withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(),
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                _getCategoryName(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$questionCount Questions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
