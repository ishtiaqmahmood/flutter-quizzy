# Quizzy - Fully Offline Flutter Quiz App

A feature-rich, fully offline quiz application built with Flutter. No internet connection required!

## ✨ Features Implemented

### 📝 Multiple Question Types
- **Multiple Choice**: Select from 4 options
- **True/False**: Binary choice questions
- **Fill in the Blank**: Type your answer

### 📚 Quiz Categories (5 Categories)
- **Science** - Chemistry, Physics, Biology
- **History** - World History, Historical Events
- **Sports** - Various Sports Knowledge
- **Geography** - Countries, Capitals, Landmarks
- **Literature** - Books, Authors, Literary Works

### ⏱️ Timer System
- 30-second countdown per question
- Visual timer with color changes (Green → Orange → Red)
- Auto-advance when time runs out

### 📊 Score Tracking
- **Points System**: Base points based on difficulty
  - Easy: 10 points
  - Medium: 20 points
  - Hard: 30 points
- **Streak Bonus**: +2 points per consecutive correct answer
- **Total Score**: Accumulated across all quizzes
- **Best Streak**: Track your longest streak

### 🎯 Difficulty Levels
- **Easy**: Basic questions, 10 points
- **Medium**: Intermediate questions, 20 points
- **Hard**: Advanced questions, 30 points

### 💾 Offline Storage (Question Bank)
- **Hive Database**: Fast, lightweight NoSQL storage
- **Pre-loaded Questions**: 15 questions per category (45 total)
- **Persistent Stats**: Your progress saved locally
- **Quiz History**: All past quiz results stored

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point & routing
├── models/
│   ├── question.dart        # Question model with types
│   └── quiz_result.dart     # QuizResult & UserStats models
├── screens/
│   ├── home_screen.dart     # Home dashboard
│   ├── quiz_setup_screen.dart  # Category/difficulty selection
│   ├── quiz_screen.dart     # Active quiz with timer
│   └── result_screen.dart   # Quiz results display
├── services/
│   ├── question_bank_service.dart  # Load questions from assets
│   ├── quiz_session.dart    # Manage quiz state & scoring
│   └── storage_service.dart # Hive database operations
└── widgets/
    ├── category_card.dart   # Category selection card
    ├── difficulty_chip.dart # Difficulty selector
    └── question_widget.dart # Question display component

assets/
└── questions/
    ├── science_questions.json
    ├── history_questions.json
    └── sports_questions.json
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.12.2 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   cd /workspace
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 How to Use

### Starting a Quiz
1. Launch the app
2. Tap "START QUIZ" button or select a category
3. Choose your category (Science, History, Sports, etc.)
4. Select difficulty level (Easy, Medium, Hard)
5. Adjust number of questions (5-20)
6. Tap "START QUIZ"

### During the Quiz
- Read the question carefully
- Select or type your answer
- Watch the timer (30 seconds per question)
- Submit your answer
- See immediate feedback
- Build your streak for bonus points!

### After the Quiz
- View your score and percentage
- See detailed statistics
- Check your best streak
- Play again or return home

## 🎮 Game Mechanics

### Scoring System
```dart
// Base Points by Difficulty
Easy:   10 points
Medium: 20 points
Hard:   30 points

// Streak Bonus
Bonus = (currentStreak - 1) * 2 points

// Example: 3-question streak on Medium difficulty
Question 1: 20 points (no bonus)
Question 2: 20 + 2 = 22 points (streak bonus)
Question 3: 20 + 4 = 24 points (streak bonus)
Total: 66 points
```

### Timer Behavior
- **Green** (30-21s): Normal pace
- **Orange** (20-11s): Hurry up!
- **Red** (10-0s): Time is running out!
- **Time's Up**: Auto-submits as incorrect

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive: ^2.2.3           # Local database
  hive_flutter: ^1.1.0   # Hive Flutter integration
  path_provider: ^2.1.1  # File system paths

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
  flutter_lints: ^6.0.0
```

## 🔧 Adding More Questions

To add more questions to any category:

1. Open the corresponding JSON file in `assets/questions/`
2. Add a new question object following this format:

```json
{
  "id": "unique_id",
  "questionText": "Your question here?",
  "type": 0,  // 0=multiple choice, 1=true/false, 2=fill in blank
  "difficulty": 0,  // 0=easy, 1=medium, 2=hard
  "category": 0,  // 0=science, 1=history, 2=sports, 3=geography, 4=literature
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctAnswer": "Correct answer",
  "points": 10
}
```

3. Save the file
4. Hot reload or restart the app

## 🎨 UI Features

- **Material Design 3**: Modern, clean interface
- **Responsive Layout**: Works on phones and tablets
- **Color-Coded Elements**: 
  - Categories have unique colors
  - Difficulty levels visually distinct
  - Timer changes color based on urgency
- **Progress Indicators**: Linear progress bar during quiz
- **Stats Dashboard**: Visual representation of performance
- **Result Cards**: Detailed breakdown after each quiz

## 📊 Data Persistence

All data is stored locally using Hive:

- **UserStats**: Total score, best streak, quizzes completed
- **QuizResults**: Individual quiz history with details
- **No Internet Required**: Everything works offline

## 🔮 Future Enhancements

Potential features to add:
- [ ] Daily challenges with special rewards
- [ ] Achievements and badges system
- [ ] Leaderboards (local)
- [ ] More question categories
- [ ] Custom quiz creation
- [ ] Hint system (50/50, skip)
- [ ] Sound effects and animations
- [ ] Dark mode toggle
- [ ] Multiplayer local mode
- [ ] Question review mode

## 📄 License

This project is open source and available for educational purposes.

## 👨‍💻 Author

Built with ❤️ using Flutter

---

**Enjoy learning with Quizzy! 🎓📱**
