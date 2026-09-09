import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionBankService {
  static final QuestionBankService _instance = QuestionBankService._internal();
  factory QuestionBankService() => _instance;
  QuestionBankService._internal();

  final Map<Category, List<Question>> _questionBank = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadQuestionsFromAssets();
    _isInitialized = true;
  }

  Future<void> _loadQuestionsFromAssets() async {
    // Load questions for each category
    for (var category in Category.values) {
      try {
        final String fileName = '${category.name}_questions.json';
        final String jsonString = await rootBundle.loadString('assets/questions/$fileName');
        final List<dynamic> jsonData = json.decode(jsonString);
        
        _questionBank[category] = jsonData.map((q) => Question.fromJson(q)).toList();
      } catch (e) {
        print('Error loading questions for ${category.name}: $e');
        _questionBank[category] = [];
      }
    }
  }

  List<Question> getQuestions({
    Category? category,
    Difficulty? difficulty,
    int limit = 10,
  }) {
    List<Question> questions = [];

    if (category != null) {
      questions = _questionBank[category] ?? [];
    } else {
      // Get all questions from all categories
      for (var catQuestions in _questionBank.values) {
        questions.addAll(catQuestions);
      }
    }

    // Filter by difficulty if specified
    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    // Shuffle and limit
    questions.shuffle();
    return questions.take(limit).toList();
  }

  List<Category> getAvailableCategories() {
    return _questionBank.keys.where((cat) => (_questionBank[cat]?.isNotEmpty ?? false)).toList();
  }

  int getQuestionCount({Category? category, Difficulty? difficulty}) {
    List<Question> questions = [];

    if (category != null) {
      questions = _questionBank[category] ?? [];
    } else {
      for (var catQuestions in _questionBank.values) {
        questions.addAll(catQuestions);
      }
    }

    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    return questions.length;
  }
}
