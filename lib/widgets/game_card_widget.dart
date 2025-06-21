import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_card.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';

class GameCardWidget extends StatefulWidget {
  final GameCard card;
  final VoidCallback onTap;

  const GameCardWidget({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150), // Further reduced for instant feel
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 50), // Much faster scale animation
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic, // Smoother curve
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(GameCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped ||
        widget.card.isMatched != oldWidget.card.isMatched) {
      if (widget.card.isFlipped || widget.card.isMatched) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _scaleAnimation]),
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * 3.14159),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: _getCardColors(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    if (widget.card.isMatched)
                      BoxShadow(
                        color: AppTheme.success.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                  border: Border.all(
                    color: widget.card.isMatched
                        ? AppTheme.success.withOpacity(0.6)
                        : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getCardColors(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: isShowingFront
                          ? _buildCardBack()
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildCardFront(),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.cardGradients[0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: CardBackgroundPainter(),
            ),
          ),
          // Center icon
          const Center(
            child: Icon(
              Icons.psychology,
              size: 36,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          widget.card.value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
            shadows: const [
              Shadow(
                color: Colors.black12,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCardColors() {
    final themeService = context.read<ThemeService>();
    final isDark = themeService.isDarkMode ||
                  (themeService.isSystemMode && Theme.of(context).brightness == Brightness.dark);
    final gradients = AppTheme.getCardGradients(isDark);

    if (widget.card.isMatched) {
      return gradients[3]; // Green gradient
    } else if (widget.card.isFlipped) {
      return isDark
          ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)] // Dark front
          : [Colors.white, Colors.white]; // Light front
    } else {
      // Use different gradients based on card ID for variety
      final gradientIndex = widget.card.id % gradients.length;
      return gradients[gradientIndex];
    }
  }

  Color _getTextColor() {
    final themeService = context.read<ThemeService>();
    final isDark = themeService.isDarkMode ||
                  (themeService.isSystemMode && Theme.of(context).brightness == Brightness.dark);

    if (widget.card.isMatched) {
      return AppTheme.success;
    }
    return isDark ? Colors.white : AppTheme.primaryBlue;
  }
}

// Custom painter for card back pattern
class CardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines pattern
    const spacing = 20.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 