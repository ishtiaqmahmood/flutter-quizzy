import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quiz_result.dart';
import '../models/question.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'quizzy.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User stats table
    await db.execute('''
      CREATE TABLE user_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_score INTEGER DEFAULT 0,
        best_streak INTEGER DEFAULT 0,
        quizzes_completed INTEGER DEFAULT 0
      )
    ''');

    // Category scores table
    await db.execute('''
      CREATE TABLE category_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category INTEGER NOT NULL,
        score INTEGER DEFAULT 0
      )
    ''');

    // Difficulty scores table
    await db.execute('''
      CREATE TABLE difficulty_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        difficulty INTEGER NOT NULL,
        score INTEGER DEFAULT 0
      )
    ''');

    // Quiz results table
    await db.execute('''
      CREATE TABLE quiz_results (
        id TEXT PRIMARY KEY,
        category INTEGER NOT NULL,
        difficulty INTEGER NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        streak INTEGER NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    // Initialize default user stats
    await db.insert('user_stats', {'total_score': 0, 'best_streak': 0, 'quizzes_completed': 0});
  }

  // User Stats
  Future<void> saveUserStats(UserStats stats) async {
    final db = await database;
    
    // Update main stats
    await db.update(
      'user_stats',
      {
        'total_score': stats.totalScore,
        'best_streak': stats.bestStreak,
        'quizzes_completed': stats.quizzesCompleted,
      },
      where: 'id = ?',
      whereArgs: [1],
    );

    // Update category scores
    await db.delete('category_scores');
    for (var entry in stats.categoryScores.entries) {
      await db.insert('category_scores', {
        'category': entry.key.index,
        'score': entry.value,
      });
    }

    // Update difficulty scores
    await db.delete('difficulty_scores');
    for (var entry in stats.difficultyScores.entries) {
      await db.insert('difficulty_scores', {
        'difficulty': entry.key.index,
        'score': entry.value,
      });
    }
  }

  Future<UserStats> getUserStats() async {
    final db = await database;
    
    final userStatsData = await db.query('user_stats', limit: 1);
    if (userStatsData.isEmpty) {
      return UserStats();
    }

    final data = userStatsData.first;
    final stats = UserStats(
      totalScore: data['total_score'] as int? ?? 0,
      bestStreak: data['best_streak'] as int? ?? 0,
      quizzesCompleted: data['quizzes_completed'] as int? ?? 0,
    );

    // Load category scores
    final categoryScoresData = await db.query('category_scores');
    for (var row in categoryScoresData) {
      final category = Category.values[row['category'] as int];
      final score = row['score'] as int;
      stats.categoryScores[category] = score;
    }

    // Load difficulty scores
    final difficultyScoresData = await db.query('difficulty_scores');
    for (var row in difficultyScoresData) {
      final difficulty = Difficulty.values[row['difficulty'] as int];
      final score = row['score'] as int;
      stats.difficultyScores[difficulty] = score;
    }

    return stats;
  }

  // Quiz Results
  Future<void> saveQuizResult(QuizResult result) async {
    final db = await database;

    await db.insert(
      'quiz_results',
      {
        'id': result.id,
        'category': result.category.index,
        'difficulty': result.difficulty.index,
        'score': result.score,
        'total_questions': result.totalQuestions,
        'correct_answers': result.correctAnswers,
        'streak': result.streak,
        'completed_at': result.completedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update user stats
    final stats = await getUserStats();
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

  Future<List<QuizResult>> getQuizResults({
    Category? category,
    Difficulty? difficulty,
    int limit = 10,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereClause += 'category = ?';
      whereArgs.add(category.index);
    }

    if (difficulty != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'difficulty = ?';
      whereArgs.add(difficulty.index);
    }

    var results = await db.query(
      'quiz_results',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'completed_at DESC',
      limit: limit > 0 ? limit : null,
    );

    return results.map((data) => QuizResult.fromJson({
      'id': data['id'],
      'category': data['category'],
      'difficulty': data['difficulty'],
      'score': data['score'],
      'totalQuestions': data['total_questions'],
      'correctAnswers': data['correct_answers'],
      'streak': data['streak'],
      'completedAt': data['completed_at'],
    })).toList();
  }

  Future<void> clearAllData() async {
    final db = await database;
    
    await db.delete('quiz_results');
    await db.delete('category_scores');
    await db.delete('difficulty_scores');
    await db.update('user_stats', {
      'total_score': 0,
      'best_streak': 0,
      'quizzes_completed': 0,
    }, where: 'id = ?', whereArgs: [1]);
  }
}
