import 'package:equatable/equatable.dart';
import '../models/difficulty_level.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class StartNewGame extends GameEvent {
  final DifficultyLevel difficulty;

  const StartNewGame(this.difficulty);

  @override
  List<Object?> get props => [difficulty];
}

class FlipCard extends GameEvent {
  final int cardIndex;

  const FlipCard(this.cardIndex);

  @override
  List<Object?> get props => [cardIndex];
}

class ResetGame extends GameEvent {}

class TimerTick extends GameEvent {}

class CheckMatch extends GameEvent {}

class LoadBestScore extends GameEvent {} 