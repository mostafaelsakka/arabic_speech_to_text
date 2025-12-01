import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class EnhancedAnimatedBackground extends StatefulWidget {
  const EnhancedAnimatedBackground({Key? key}) : super(key: key);

  @override
  _EnhancedAnimatedBackgroundState createState() =>
      _EnhancedAnimatedBackgroundState();
}

class _EnhancedAnimatedBackgroundState extends State<EnhancedAnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late AnimationController _controller4;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _controller4 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0B0A10),
                Color(0xFF1A1726),
                Color(0xFF0F0E17),
                Color(0xFF1C1B29),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedGradientOrb(
                animationValue: _controller1.value,
                color: const Color(0xFFF72585),
                offsetX: 0.15,
                offsetY: 0.25,
                size: 220,
              ),
              size: Size.infinite,
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedGradientOrb(
                animationValue: _controller2.value,
                color: const Color(0xFF7209B7),
                offsetX: 0.75,
                offsetY: 0.55,
                size: 200,
              ),
              size: Size.infinite,
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller3,
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedGradientOrb(
                animationValue: _controller3.value,
                color: const Color(0xFF06D6A0),
                offsetX: 0.5,
                offsetY: 0.8,
                size: 180,
              ),
              size: Size.infinite,
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller4,
          builder: (context, child) {
            return CustomPaint(
              painter: EnhancedGradientOrb(
                animationValue: _controller4.value,
                color: const Color(0xFF118AB2),
                offsetX: 0.3,
                offsetY: 0.6,
                size: 160,
              ),
              size: Size.infinite,
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class EnhancedGradientOrb extends CustomPainter {
  final double animationValue;
  final Color color;
  final double offsetX;
  final double offsetY;
  final double size;

  EnhancedGradientOrb({
    required this.animationValue,
    required this.color,
    required this.offsetX,
    required this.offsetY,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withOpacity(0.5),
              color.withOpacity(0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                canvasSize.width * offsetX +
                    math.cos(animationValue * 2 * math.pi) * 100,
                canvasSize.height * offsetY +
                    math.sin(animationValue * 2 * math.pi) * 100,
              ),
              radius: size,
            ),
          );

    canvas.drawCircle(
      Offset(
        canvasSize.width * offsetX +
            math.cos(animationValue * 2 * math.pi) * 100,
        canvasSize.height * offsetY +
            math.sin(animationValue * 2 * math.pi) * 100,
      ),
      size,
      paint,
    );
  }

  @override
  bool shouldRepaint(EnhancedGradientOrb oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
