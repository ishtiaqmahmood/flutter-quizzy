import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_setup_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'services/storage_service.dart';
import 'models/question.dart';
import 'models/quiz_result.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite for offline storage
  await StorageService().database;
  
  runApp(const QuizzyApp());
}

class QuizzyApp extends StatelessWidget {
  const QuizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/setup': (context) => const QuizSetupScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/quiz':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => QuizScreen(
                category: args['category'],
                difficulty: args['difficulty'],
                questionCount: args['questionCount'],
              ),
            );
          case '/result':
            final result = settings.arguments as QuizResult;
            return MaterialPageRoute(
              builder: (context) => ResultScreen(result: result),
            );
          default:
            return null;
        }
      },
    );
  }
}
