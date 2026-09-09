import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_bank_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserStats _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final storageService = StorageService();
    setState(() {
      _userStats = storageService.getUserStats();
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
        title: const Text('Quizzy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              
              const SizedBox(height: 24),
              
              // Stats Overview
              const Text(
                'Your Statistics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStatsGrid(),
              
              const SizedBox(height: 24),
              
              // Quick Start
              const Text(
                'Quick Start',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildQuickStartButtons(),
              
              const SizedBox(height: 24),
              
              // Categories Preview
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCategoriesPreview(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/setup');
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('START QUIZ'),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Score: ${_userStats.totalScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quizzes Completed: ${_userStats.quizzesCompleted}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatItem(
          'Total Score',
          '${_userStats.totalScore}',
          Icons.star,
          Colors.amber,
        ),
        _buildStatItem(
          'Best Streak',
          '${_userStats.bestStreak}🔥',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatItem(
          'Quizzes',
          '${_userStats.quizzesCompleted}',
          Icons.quiz,
          Colors.blue,
        ),
        _buildStatItem(
          'Avg Score',
          _userStats.quizzesCompleted > 0
              ? '${(_userStats.totalScore / _userStats.quizzesCompleted).round()}'
              : '0',
          Icons.trending_up,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartButtons() {
    return Column(
      children: [
        _buildQuickStartButton(
          'Random Quiz',
          'Get a random mix of questions',
          Icons.shuffle,
          Colors.blue,
          () => _startRandomQuiz(),
        ),
        const SizedBox(height: 12),
        _buildQuickStartButton(
          'Daily Challenge',
          'Complete today\'s special quiz',
          Icons.calendar_today,
          Colors.orange,
          () => _startDailyChallenge(),
        ),
      ],
    );
  }

  Widget _buildQuickStartButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCategoriesPreview() {
    final questionBank = QuestionBankService();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: Category.values.length,
      itemBuilder: (context, index) {
        final category = Category.values[index];
        final count = questionBank.getQuestionCount(category: category);
        
        return _buildCategoryTile(category, count);
      },
    );
  }

  Widget _buildCategoryTile(Category category, int count) {
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
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/setup',
            arguments: {'initialCategory': category},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count questions',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRandomQuiz() {
    Navigator.pushNamed(
      context,
      '/setup',
      arguments: {'random': true},
    );
  }

  void _startDailyChallenge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily Challenge coming soon!')),
    );
  }
}
