class QuizResult {
  final String id;
  final Category category;
  final Difficulty difficulty;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int streak;
  final DateTime completedAt;

  QuizResult({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.streak,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.index,
      'difficulty': difficulty.index,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'streak': streak,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      category: Category.values[json['category']],
      difficulty: Difficulty.values[json['difficulty']],
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      streak: json['streak'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}

class UserStats {
  int totalScore;
  int bestStreak;
  int quizzesCompleted;
  Map<Category, int> categoryScores;
  Map<Difficulty, int> difficultyScores;

  UserStats({
    this.totalScore = 0,
    this.bestStreak = 0,
    this.quizzesCompleted = 0,
    Map<Category, int>? categoryScores,
    Map<Difficulty, int>? difficultyScores,
  })  : categoryScores = categoryScores ?? {},
        difficultyScores = difficultyScores ?? {};

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'bestStreak': bestStreak,
      'quizzesCompleted': quizzesCompleted,
      'categoryScores': {
        for (var entry in categoryScores.entries) entry.key.index: entry.value,
      },
      'difficultyScores': {
        for (var entry in difficultyScores.entries) entry.key.index: entry.value,
      },
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final stats = UserStats(
      totalScore: json['totalScore'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      quizzesCompleted: json['quizzesCompleted'] ?? 0,
    );
    
    if (json['categoryScores'] != null) {
      stats.categoryScores = {
        for (var entry in (json['categoryScores'] as Map).entries)
          Category.values[entry.key]: entry.value,
      };
    }
    
    if (json['difficultyScores'] != null) {
      stats.difficultyScores = {
        for (var entry in (json['difficultyScores'] as Map).entries)
          Difficulty.values[entry.key]: entry.value,
      };
    }
    
    return stats;
  }
}
