import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final int questionNumber;
  final String? selectedAnswer;
  final bool showResult;
  final Function(String)? onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    this.selectedAnswer,
    this.showResult = false,
    this.onAnswerSelected,
  });

  Widget _buildMultipleChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: question.options.map((option) {
        bool isSelected = selectedAnswer == option;
        bool isCorrect = option == question.correctAnswer;
        
        Color borderColor;
        Color backgroundColor;
        
        if (showResult) {
          if (isCorrect) {
            borderColor = Colors.green;
            backgroundColor = Colors.green.withOpacity(0.2);
          } else if (isSelected && !isCorrect) {
            borderColor = Colors.red;
            backgroundColor = Colors.red.withOpacity(0.2);
          } else {
            borderColor = Colors.grey;
            backgroundColor = Colors.grey.withOpacity(0.1);
          }
        } else {
          borderColor = isSelected ? Theme.of(context).primaryColor : Colors.grey;
          backgroundColor = isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.1);
        }

        return GestureDetector(
          onTap: showResult ? null : () => onAnswerSelected?.call(option),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (showResult && isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (showResult && isSelected && !isCorrect)
                  const Icon(Icons.cancel, color: Colors.red)
                else if (isSelected)
                  const Icon(Icons.radio_button_checked, color: Colors.blue)
                else
                  const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header with number and type badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$questionNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Difficulty and points badge
            Row(
              children: [
                _buildDifficultyBadge(),
                const SizedBox(width: 8),
                _buildPointsBadge(),
                const Spacer(),
                _buildTypeBadge(),
              ],
            ),
            const SizedBox(height: 24),
            
            // Answer options
            if (question.type == QuestionType.multipleChoice || 
                question.type == QuestionType.trueFalse)
              _buildMultipleChoice()
            else if (question.type == QuestionType.fillInTheBlank)
              _buildFillInTheBlank(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    String text;
    
    switch (question.difficulty) {
      case Difficulty.easy:
        color = Colors.green;
        text = 'Easy';
        break;
      case Difficulty.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case Difficulty.hard:
        color = Colors.red;
        text = 'Hard';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${question.points} pts',
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    String text;
    IconData icon;
    
    switch (question.type) {
      case QuestionType.multipleChoice:
        text = 'Multiple Choice';
        icon = Icons.list;
        break;
      case QuestionType.trueFalse:
        text = 'True/False';
        icon = Icons.toggle_on;
        break;
      case QuestionType.fillInTheBlank:
        text = 'Fill in Blank';
        icon = Icons.edit;
        break;
    }
    
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFillInTheBlank() {
    if (showResult) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            enabled: false,
            controller: TextEditingController(text: selectedAnswer ?? ''),
            decoration: InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: selectedAnswer?.toLowerCase() == question.correctAnswer.toLowerCase()
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Correct Answer: ${question.correctAnswer}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return TextField(
        onChanged: onAnswerSelected,
        decoration: InputDecoration(
          labelText: 'Type your answer',
          hintText: 'Enter your answer here...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.edit),
        ),
      );
    }
  }
}
