import 'package:flutter/material.dart';
import '../models/game_card.dart';
import '../models/difficulty_level.dart';
import 'game_card_widget.dart';

class GameBoard extends StatelessWidget {
  final List<GameCard> cards;
  final DifficultyLevel difficulty;
  final Function(int) onCardTap;

  const GameBoard({
    Key? key,
    required this.cards,
    required this.difficulty,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardSize = _calculateCardSize(constraints);
        
        return Center(
          child: SizedBox(
            width: difficulty.columns * cardSize + (difficulty.columns - 1) * 8,
            height: difficulty.rows * cardSize + (difficulty.rows - 1) * 8,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: difficulty.columns,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GameCardWidget(
                  card: cards[index],
                  onTap: () => onCardTap(index),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _calculateCardSize(BoxConstraints constraints) {
    final double maxWidth = constraints.maxWidth;
    final double maxHeight = constraints.maxHeight;
    
    final double widthPerCard = (maxWidth - (difficulty.columns - 1) * 8) / difficulty.columns;
    final double heightPerCard = (maxHeight - (difficulty.rows - 1) * 8) / difficulty.rows;
    
    return (widthPerCard < heightPerCard ? widthPerCard : heightPerCard).clamp(60.0, 120.0);
  }
} 