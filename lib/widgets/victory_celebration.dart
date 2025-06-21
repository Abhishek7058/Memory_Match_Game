import 'dart:math';
import 'package:flutter/material.dart';

class VictoryCelebration extends StatefulWidget {
  final bool isNewBestScore;
  final Widget child;

  const VictoryCelebration({
    Key? key,
    required this.isNewBestScore,
    required this.child,
  }) : super(key: key);

  @override
  State<VictoryCelebration> createState() => _VictoryCelebrationState();
}

class _VictoryCelebrationState extends State<VictoryCelebration>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600), // Faster pulse animation
      vsync: this,
    );

    _generateParticles();
    _startCelebration();
  }

  void _generateParticles() {
    final random = Random();
    _particles = List.generate(50, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1,
        color: _getRandomColor(),
        size: random.nextDouble() * 8 + 4,
        velocity: random.nextDouble() * 2 + 1,
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  void _startCelebration() {
    _confettiController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Confetti animation
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        
        // Pulsing glow effect for new best score
        if (widget.isNewBestScore)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0 + _pulseController.value * 0.5,
                    colors: [
                      Colors.yellow.withOpacity(0.1 * (1 - _pulseController.value)),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double velocity;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double progress) {
    y += velocity * progress * 0.02;
    rotation += rotationSpeed;
    
    // Add some horizontal drift
    x += sin(progress * 4 + y * 10) * 0.001;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Update particle position
      particle.update(progress);
      
      // Skip particles that have fallen off screen
      if (particle.y > 1.2) continue;
      
      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress * 0.3)
        ..style = PaintingStyle.fill;

      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw confetti as rotated rectangles
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation);
      
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Fireworks effect for extra celebration
class FireworksEffect extends StatefulWidget {
  final Widget child;

  const FireworksEffect({Key? key, required this.child}) : super(key: key);

  @override
  State<FireworksEffect> createState() => _FireworksEffectState();
}

class _FireworksEffectState extends State<FireworksEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<FireworkParticle> _fireworks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _generateFireworks();
    _controller.forward();
  }

  void _generateFireworks() {
    final random = Random();
    _fireworks = List.generate(3, (index) {
      return FireworkParticle(
        x: 0.2 + random.nextDouble() * 0.6,
        y: 0.3 + random.nextDouble() * 0.4,
        color: _getRandomColor(),
        delay: index * 0.3,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: FireworksPainter(
                fireworks: _fireworks,
                progress: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

class FireworkParticle {
  final double x;
  final double y;
  final Color color;
  final double delay;

  FireworkParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.delay,
  });
}

class FireworksPainter extends CustomPainter {
  final List<FireworkParticle> fireworks;
  final double progress;

  FireworksPainter({
    required this.fireworks,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final firework in fireworks) {
      final adjustedProgress = (progress - firework.delay).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final center = Offset(
        firework.x * size.width,
        firework.y * size.height,
      );

      final paint = Paint()
        ..color = firework.color.withOpacity(1.0 - adjustedProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw expanding circle
      final radius = adjustedProgress * 100;
      canvas.drawCircle(center, radius, paint);

      // Draw radiating lines
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * pi / 180;
        final startRadius = radius * 0.8;
        final endRadius = radius * 1.2;
        
        final start = Offset(
          center.dx + cos(angle) * startRadius,
          center.dy + sin(angle) * startRadius,
        );
        
        final end = Offset(
          center.dx + cos(angle) * endRadius,
          center.dy + sin(angle) * endRadius,
        );
        
        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
