# Memory Match Game 🧠🎮

A **professional, commercial-quality** Flutter memory matching game featuring stunning visual design, smooth animations, multiple difficulty levels, and robust BLoC state management. Experience the ultimate memory challenge with a polished, mobile-game-quality interface!

## 🎯 Features

### 🎨 Professional Visual Design
- **Material Design 3**: Modern, professional color palette with gradient backgrounds
- **Professional Splash Screen**: Animated loading screen with smooth transitions
- **Premium Card Design**: Beautiful cards with shadows, rounded corners, and gradient effects
- **Responsive UI**: Adaptive layouts that work perfectly on all screen sizes
- **Commercial-Quality Animations**: 60 FPS smooth animations and visual feedback

### 🎮 Core Gameplay
- **Multiple Difficulty Levels**: Choose from Easy (3x4), Medium (4x4), or Hard (4x6) grid layouts
- **Professional Game Flow**: Intuitive navigation with polished user experience
- **Score Tracking**: Advanced scoring system with moves, time, and performance metrics
- **Best Score System**: Persistent storage of best scores for each difficulty level
- **Enhanced Statistics**: Comprehensive game analytics and progress tracking

### 🛠️ Technical Excellence
- **BLoC State Management**: Clean architecture with reactive state management
- **Enhanced Storage**: Robust SharedPreferences implementation with error handling
- **Audio System**: Professional sound effects with toggle controls (configurable)
- **Performance Optimized**: Memory-efficient rendering and smooth gameplay
- **Cross-Platform**: Runs flawlessly on Android, iOS, Web, Windows, macOS, and Linux

## 🏗️ Architecture

This project follows clean architecture principles with clear separation of concerns:

```
lib/
├── bloc/           # BLoC state management
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic services
├── utils/          # Utility functions
└── widgets/        # Reusable UI components
```

### Key Components

- **GameBloc**: Manages game state, card flipping logic, and match detection
- **StorageService**: Handles persistent data storage for scores and game history
- **AudioService**: Manages sound effects and audio feedback
- **CardGenerator**: Utility for generating randomized card layouts

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd memory_match_game
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🎮 How to Play

1. **Select Difficulty**: Choose your preferred difficulty level from the main menu
2. **Flip Cards**: Tap on cards to flip them and reveal their symbols
3. **Find Matches**: Try to find matching pairs by remembering card positions
4. **Complete the Game**: Match all pairs to complete the level
5. **Beat Your Score**: Try to complete the game with fewer moves and less time

### Scoring System

- **Base Score**: 1000 points
- **Move Penalty**: -10 points per move
- **Time Bonus**: Bonus points for quick completion
- **Difficulty Multiplier**: Higher difficulties provide score multipliers

## 🛠️ Dependencies

### Core Dependencies
- `flutter_bloc: ^8.1.3` - State management
- `shared_preferences: ^2.2.2` - Local data persistence
- `equatable: ^2.0.5` - Value equality comparisons
- `audioplayers: ^5.2.1` - Audio playback support

### Development Dependencies
- `flutter_test` - Testing framework
- `flutter_lints: ^3.0.0` - Linting rules

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎨 Customization

### Adding Sound Effects

1. Add your sound files to `assets/sounds/`
2. Update `pubspec.yaml` to include the sound files
3. Uncomment and modify the audio playback code in `AudioService`

Example sound files you can add:
- `flip.mp3` - Card flip sound
- `match.mp3` - Successful match sound
- `victory.mp3` - Game completion sound

### Customizing Difficulty Levels

Modify the `DifficultyLevel` enum in `lib/models/difficulty_level.dart`:

```dart
enum DifficultyLevel {
  easy(3, 4, 'Easy (3x4)'),
  medium(4, 4, 'Medium (4x4)'),
  hard(4, 6, 'Hard (4x6)'),
  expert(6, 6, 'Expert (6x6)'), // Add new difficulty
}
```

### Theming

The app uses Material Design 3 theming. You can customize colors and themes in `main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
),
```


**Enjoy playing Memory Match Game! 🎉**"# Memory_Match_Game" 
