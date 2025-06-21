import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/game_header.dart';
import '../widgets/victory_celebration.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        final gameBloc = context.read<GameBloc>();
        final currentState = gameBloc.state;

        if (currentState is GameInProgress) {
          // Show confirmation dialog when game is in progress
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit) {
            gameBloc.add(ResetGame());
            Navigator.of(context).pop();
            return false;
          }
          return false;
        } else {
          // Allow normal back navigation for other states
          Navigator.of(context).pop();
          return false;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            // Only show app bar with controls during gameplay
            if (state is GameInProgress) {
              return AppBar(
              title: const Text('Memory Match'),
              backgroundColor: Colors.transparent,
              elevation: 0,
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
                  margin: const EdgeInsets.only(right: 8),
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
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      context.read<GameBloc>().add(ResetGame());
                    },
                    tooltip: 'Reset Game',
                  ),
                ),
              ],
            );
          } else {
            // Clean app bar for other states (home screen, victory screen)
            return AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0, // Hide the app bar completely
            );
          }
        },
        ),
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: AppTheme.getGameBackgroundGradient(
                themeService.isDarkMode ||
                (themeService.isSystemMode && Theme.of(context).brightness == Brightness.dark)
              ),
            ),
            child: BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                if (state is GameLoading) {
                  return _buildLoadingView(context);
                } else if (state is GameInProgress) {
                  return _buildGameView(context, state);
                } else if (state is GameCompleted) {
                  return _buildCompletedView(context, state);
                }
                // If game is in initial state, navigate back to home
                if (state is GameInitial) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pop();
                  });
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Exit Game?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Your current progress will be lost. Are you sure you want to return to home?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continue Playing',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Return to Home'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildLoadingView(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Preparing Game...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildGameView(BuildContext context, GameInProgress state) {
    return SafeArea(
      child: Column(
        children: [
          // Game Header with enhanced styling
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: GameHeader(
              moves: state.stats.moves,
              seconds: state.stats.seconds,
              bestScore: state.bestScore,
            ),
          ),

          // Game Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GameBoard(
                cards: state.cards,
                difficulty: state.difficulty,
                onCardTap: (index) {
                  context.read<GameBloc>().add(FlipCard(index));
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context, GameCompleted state) {
    return VictoryCelebration(
      isNewBestScore: state.isNewBestScore,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Victory Animation Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: state.isNewBestScore
                      ? AppTheme.successGradient
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: (state.isNewBestScore
                          ? AppTheme.success
                          : AppTheme.primaryBlue).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Victory Title
              Text(
                state.isNewBestScore ? '🎉 New Best Score!' : '🎊 Congratulations!',
                textAlign: TextAlign.center,
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

              const SizedBox(height: 24),

              // Stats Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Game Statistics',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatRow('Score', '${state.stats.score}'),
                    _buildStatRow('Moves', '${state.stats.moves}'),
                    _buildStatRow('Time', '${state.stats.seconds}s'),
                    _buildStatRow('Difficulty', state.difficulty.displayName),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Immediate feedback - start new game instantly
                        context.read<GameBloc>().add(StartNewGame(state.difficulty));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                        shadowColor: Colors.white.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Play Again',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<GameBloc>().add(ResetGame());
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Change Difficulty',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        context.read<GameBloc>().add(ResetGame());
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      )
    );
    
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 