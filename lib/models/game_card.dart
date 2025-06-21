import 'package:equatable/equatable.dart';

class GameCard extends Equatable {
  final int id;
  final String value;
  final bool isFlipped;
  final bool isMatched;
  final bool isVisible;

  const GameCard({
    required this.id,
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
    this.isVisible = true,
  });

  GameCard copyWith({
    int? id,
    String? value,
    bool? isFlipped,
    bool? isMatched,
    bool? isVisible,
  }) {
    return GameCard(
      id: id ?? this.id,
      value: value ?? this.value,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  List<Object?> get props => [id, value, isFlipped, isMatched, isVisible];
} 