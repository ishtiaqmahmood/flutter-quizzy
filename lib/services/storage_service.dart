import 'package:hive_flutter/hive_flutter.dart';
import '../models/quiz_result.dart';
import '../models/question.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<Map<String, dynamic>> _userStatsBox;
  late Box<Map<String, dynamic>> _quizResultsBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    _userStatsBox = await Hive.openBox<Map<String, dynamic>>('userStats');
    _quizResultsBox = await Hive.openBox<Map<String, dynamic>>('quizResults');
    
    // Initialize user stats if not exists
    if (!_userStatsBox.containsKey('current')) {
      await saveUserStats(UserStats());
    }
  }

  // User Stats
  Future<void> saveUserStats(UserStats stats) async {
    await _userStatsBox.put('current', stats.toJson());
  }

  UserStats getUserStats() {
    final data = _userStatsBox.get('current');
    if (data == null) return UserStats();
    return UserStats.fromJson(data);
  }

  // Quiz Results
  Future<void> saveQuizResult(QuizResult result) async {
    await _quizResultsBox.put(result.id, result.toJson());
    
    // Update user stats
    final stats = getUserStats();
    stats.totalScore += result.score;
    stats.quizzesCompleted++;
    if (result.streak > stats.bestStreak) {
      stats.bestStreak = result.streak;
    }
    
    // Update category scores
    stats.categoryScores[result.category] = 
        (stats.categoryScores[result.category] ?? 0) + result.score;
    
    // Update difficulty scores
    stats.difficultyScores[result.difficulty] = 
        (stats.difficultyScores[result.difficulty] ?? 0) + result.score;
    
    await saveUserStats(stats);
  }

  List<QuizResult> getQuizResults({
    Category? category,
    Difficulty? difficulty,
    int limit = 10,
  }) {
    var results = _quizResultsBox.values
        .map((data) => QuizResult.fromJson(data))
        .toList();

    if (category != null) {
      results = results.where((r) => r.category == category).toList();
    }

    if (difficulty != null) {
      results = results.where((r) => r.difficulty == difficulty).toList();
    }

    // Sort by date descending
    results.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (limit > 0 && results.length > limit) {
      results = results.sublist(0, limit);
    }

    return results;
  }

  Future<void> clearAllData() async {
    await _userStatsBox.clear();
    await _quizResultsBox.clear();
    await saveUserStats(UserStats());
  }
}
