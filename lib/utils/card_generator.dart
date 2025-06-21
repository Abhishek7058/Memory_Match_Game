import 'dart:math';
import '../models/game_card.dart';
import '../models/difficulty_level.dart';

class CardGenerator {
  static const List<String> _cardValues = [
    '🎮', '🎯', '🎲', '🎪', '🎨', '🎭', '🎪', '🎯',
    '🚀', '🌟', '⭐', '🌙', '☀️', '🌈', '🔥', '💎',
    '🎸', '🎺', '🥁', '🎹', '🎤', '🎧', '🎵', '🎶',
  ];

  static List<GameCard> generateCards(DifficultyLevel difficulty) {
    final random = Random();
    final totalPairs = difficulty.totalPairs;
    
    // Select random card values for this game
    final selectedValues = List<String>.from(_cardValues);
    selectedValues.shuffle(random);
    final gameValues = selectedValues.take(totalPairs).toList();
    
    // Create pairs
    final List<String> cardPairs = [];
    for (final value in gameValues) {
      cardPairs.add(value);
      cardPairs.add(value);
    }
    
    // Shuffle the pairs
    cardPairs.shuffle(random);
    
    // Create GameCard objects
    return cardPairs.asMap().entries.map((entry) {
      return GameCard(
        id: entry.key,
        value: entry.value,
      );
    }).toList();
  }
} 