import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../models/difficulty_level.dart';
import '../widgets/difficulty_selector.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                context.read<GameBloc>().audioService.isEnabled
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.white,
              ),
              onPressed: () {
                context.read<GameBloc>().audioService.toggleSound();
                // Trigger a rebuild to update the icon
                context.read<GameBloc>().add(LoadBestScore());
              },
              tooltip: context.read<GameBloc>().audioService.isEnabled
                  ? 'Mute Sound'
                  : 'Enable Sound',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return IconButton(
                  icon: Icon(
                    themeService.currentThemeIcon,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    themeService.toggleTheme();
                  },
                  tooltip: 'Theme: ${themeService.currentThemeName}',
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Game Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.extension,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              // Game Title
              Text(
                'Memory Match',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Challenge your memory and find all matching pairs!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
              ),

              const SizedBox(height: 60),

              // Difficulty Selector
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Choose Difficulty',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    DifficultySelector(
                      onDifficultySelected: (difficulty) {
                        _startGame(context, difficulty);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, DifficultyLevel difficulty) {
    // Start the game and navigate to game screen
    context.read<GameBloc>().add(StartNewGame(difficulty));
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }
}
