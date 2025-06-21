import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/difficulty_level.dart';
import '../models/game_stats.dart';

class StorageService {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      if (kDebugMode) {
        print('StorageService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize StorageService: $e');
      }
      _isInitialized = false;
    }
  }

  bool get isInitialized => _isInitialized;

  Future<int> getBestScore(DifficultyLevel difficulty) async {
    if (!_isInitialized) return 0;

    try {
      final key = 'best_score_${difficulty.name}';
      return _prefs.getInt(key) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting best score: $e');
      }
      return 0;
    }
  }

  Future<void> saveBestScore(DifficultyLevel difficulty, int score) async {
    if (!_isInitialized) return;

    try {
      final key = 'best_score_${difficulty.name}';
      await _prefs.setInt(key, score);
      if (kDebugMode) {
        print('Best score saved: $score for ${difficulty.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving best score: $e');
      }
    }
  }

  Future<void> saveGameHistory(DifficultyLevel difficulty, GameStats stats) async {
    if (!_isInitialized) return;

    try {
      final key = 'game_history_${difficulty.name}';
      final List<String> history = _prefs.getStringList(key) ?? [];

      final gameData = {
        'score': stats.score,
        'moves': stats.moves,
        'seconds': stats.seconds,
        'completed_at': stats.completedAt?.toIso8601String(),
      };

      history.add(jsonEncode(gameData));

      // Keep only last 20 games for better statistics
      if (history.length > 20) {
        history.removeAt(0);
      }

      await _prefs.setStringList(key, history);

      // Update total games played
      await _incrementTotalGamesPlayed(difficulty);

      if (kDebugMode) {
        print('Game history saved for ${difficulty.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving game history: $e');
      }
    }
  }

  Future<List<GameStats>> getGameHistory(DifficultyLevel difficulty) async {
    if (!_isInitialized) return [];

    try {
      final key = 'game_history_${difficulty.name}';
      final List<String> history = _prefs.getStringList(key) ?? [];

      return history.map((gameString) {
        final gameData = jsonDecode(gameString);
        return GameStats(
          moves: gameData['moves'],
          seconds: gameData['seconds'],
          isCompleted: true,
          completedAt: gameData['completed_at'] != null
              ? DateTime.parse(gameData['completed_at'])
              : null,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting game history: $e');
      }
      return [];
    }
  }

  // Additional statistics methods
  Future<int> getTotalGamesPlayed(DifficultyLevel difficulty) async {
    if (!_isInitialized) return 0;

    try {
      final key = 'total_games_${difficulty.name}';
      return _prefs.getInt(key) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting total games played: $e');
      }
      return 0;
    }
  }

  Future<void> _incrementTotalGamesPlayed(DifficultyLevel difficulty) async {
    if (!_isInitialized) return;

    try {
      final key = 'total_games_${difficulty.name}';
      final current = _prefs.getInt(key) ?? 0;
      await _prefs.setInt(key, current + 1);
    } catch (e) {
      if (kDebugMode) {
        print('Error incrementing total games played: $e');
      }
    }
  }

  Future<double> getAverageCompletionTime(DifficultyLevel difficulty) async {
    final history = await getGameHistory(difficulty);
    if (history.isEmpty) return 0.0;

    final totalSeconds = history.fold<int>(0, (sum, game) => sum + game.seconds);
    return totalSeconds / history.length;
  }

  Future<double> getAverageMoves(DifficultyLevel difficulty) async {
    final history = await getGameHistory(difficulty);
    if (history.isEmpty) return 0.0;

    final totalMoves = history.fold<int>(0, (sum, game) => sum + game.moves);
    return totalMoves / history.length;
  }

  Future<void> clearAllData() async {
    if (!_isInitialized) return;

    try {
      await _prefs.clear();
      if (kDebugMode) {
        print('All storage data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing storage data: $e');
      }
    }
  }
}