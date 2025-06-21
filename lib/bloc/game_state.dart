import 'package:equatable/equatable.dart';
import '../models/game_card.dart';
import '../models/game_stats.dart';
import '../models/difficulty_level.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameInProgress extends GameState {
  final List<GameCard> cards;
  final GameStats stats;
  final DifficultyLevel difficulty;
  final List<int> flippedCardIndices;
  final bool canFlip;
  final int bestScore;

  const GameInProgress({
    required this.cards,
    required this.stats,
    required this.difficulty,
    this.flippedCardIndices = const [],
    this.canFlip = true,
    this.bestScore = 0,
  });

  GameInProgress copyWith({
    List<GameCard>? cards,
    GameStats? stats,
    DifficultyLevel? difficulty,
    List<int>? flippedCardIndices,
    bool? canFlip,
    int? bestScore,
  }) {
    return GameInProgress(
      cards: cards ?? this.cards,
      stats: stats ?? this.stats,
      difficulty: difficulty ?? this.difficulty,
      flippedCardIndices: flippedCardIndices ?? this.flippedCardIndices,
      canFlip: canFlip ?? this.canFlip,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  @override
  List<Object?> get props => [
        cards,
        stats,
        difficulty,
        flippedCardIndices,
        canFlip,
        bestScore,
      ];
}

class GameCompleted extends GameState {
  final GameStats stats;
  final DifficultyLevel difficulty;
  final bool isNewBestScore;

  const GameCompleted({
    required this.stats,
    required this.difficulty,
    this.isNewBestScore = false,
  });

  @override
  List<Object?> get props => [stats, difficulty, isNewBestScore];
} 