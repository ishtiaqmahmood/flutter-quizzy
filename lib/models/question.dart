enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInTheBlank,
}

enum Difficulty {
  easy,
  medium,
  hard,
}

enum Category {
  science,
  history,
  sports,
  geography,
  literature,
}

class Question {
  final String id;
  final String questionText;
  final QuestionType type;
  final Difficulty difficulty;
  final Category category;
  final List<String> options; // For multiple choice and true/false
  final String correctAnswer;
  final int points;

  Question({
    required this.id,
    required this.questionText,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.index,
      'difficulty': difficulty.index,
      'category': category.index,
      'options': options,
      'correctAnswer': correctAnswer,
      'points': points,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'],
      type: QuestionType.values[json['type']],
      difficulty: Difficulty.values[json['difficulty']],
      category: Category.values[json['category']],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      points: json['points'],
    );
  }
}
