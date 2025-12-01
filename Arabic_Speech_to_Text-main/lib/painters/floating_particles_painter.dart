import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingParticlesPainter extends CustomPainter {
  final double animationValue;

  FloatingParticlesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15);

    for (int i = 0; i < 20; i++) {
      final x = (size.width * 0.1 * i) % size.width;
      final y =
          ((size.height * 0.5 +
              math.sin(animationValue * 2 * math.pi + i) * 100 +
              i * 50) %
          size.height);
      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(animationValue * math.pi + i) * 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FloatingParticlesPainter oldDelegate) => true;
}
