import 'package:equatable/equatable.dart';

class GameStats extends Equatable {
  final int moves;
  final int seconds;
  final bool isCompleted;
  final DateTime? completedAt;

  const GameStats({
    this.moves = 0,
    this.seconds = 0,
    this.isCompleted = false,
    this.completedAt,
  });

  GameStats copyWith({
    int? moves,
    int? seconds,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GameStats(
      moves: moves ?? this.moves,
      seconds: seconds ?? this.seconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  int get score => isCompleted ? (1000 - (moves * 2) - seconds).clamp(0, 1000) : 0;

  @override
  List<Object?> get props => [moves, seconds, isCompleted, completedAt];
} 