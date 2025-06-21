enum DifficultyLevel {
  easy(3, 4, 'Easy (3x4)'),
  medium(4, 4, 'Medium (4x4)'),
  hard(4, 6, 'Hard (4x6)');

  const DifficultyLevel(this.rows, this.columns, this.displayName);

  final int rows;
  final int columns;
  final String displayName;

  int get totalCards => rows * columns;
  int get totalPairs => totalCards ~/ 2;
} 