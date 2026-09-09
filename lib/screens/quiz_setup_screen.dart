import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/storage_service.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  Category? _selectedCategory;
  Difficulty? _selectedDifficulty;
  int _questionCount = 10;
  Map<Category, int> _categoryScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryScores();
  }

  Future<void> _loadCategoryScores() async {
    final storageService = StorageService();
    final stats = await storageService.getUserStats();
    setState(() {
      _categoryScores = stats.categoryScores;
      _isLoading = false;
    });
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
        title: const Text('New Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selection
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: Category.values.length,
              itemBuilder: (context, index) {
                final category = Category.values[index];
                final count = _categoryScores[category] ?? 0;
                
                return _buildCategoryCard(category, count);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Difficulty Selection
            const Text(
              'Select Difficulty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              children: Difficulty.values.map((difficulty) {
                return _buildDifficultyChip(difficulty);
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Question Count Slider
            const Text(
              'Number of Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Questions:', style: TextStyle(fontSize: 16)),
                        Text(
                          '$_questionCount',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _questionCount.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 3,
                      label: '$_questionCount',
                      onChanged: (value) {
                        setState(() {
                          _questionCount = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedCategory != null && _selectedDifficulty != null
                    ? () => _startQuiz()
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START QUIZ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int score) {
    bool isSelected = _selectedCategory == category;
    
    String name;
    IconData icon;
    Color color;
    
    switch (category) {
      case Category.science:
        name = 'Science';
        icon = Icons.science;
        color = Colors.blue;
        break;
      case Category.history:
        name = 'History';
        icon = Icons.history_edu;
        color = Colors.amber;
        break;
      case Category.sports:
        name = 'Sports';
        icon = Icons.sports;
        color = Colors.green;
        break;
      case Category.geography:
        name = 'Geography';
        icon = Icons.public;
        color = Colors.teal;
        break;
      case Category.literature:
        name = 'Literature';
        icon = Icons.menu_book;
        color = Colors.purple;
        break;
      case Category.technology:
        name = 'Technology';
        icon = Icons.computer;
        color = Colors.indigo;
        break;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isSelected ? Colors.white : color),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (score > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$score pts',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty difficulty) {
    bool isSelected = _selectedDifficulty == difficulty;
    
    String name;
    Color color;
    
    switch (difficulty) {
      case Difficulty.easy:
        name = 'Easy';
        color = Colors.green;
        break;
      case Difficulty.medium:
        name = 'Medium';
        color = Colors.orange;
        break;
      case Difficulty.hard:
        name = 'Hard';
        color = Colors.red;
        break;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  void _startQuiz() {
    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: {
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'questionCount': _questionCount,
      },
    );
  }
}
