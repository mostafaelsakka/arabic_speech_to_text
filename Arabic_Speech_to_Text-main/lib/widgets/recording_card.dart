import 'package:flutter/material.dart';
import 'dart:ui';

class RecordingCard extends StatelessWidget {
  final int recordingDuration;
  final String Function(int) formatDuration;
  final Animation<double> pulseAnimation;
  final AnimationController rippleController;

  const RecordingCard({
    Key? key,
    required this.recordingDuration,
    required this.formatDuration,
    required this.pulseAnimation,
    required this.rippleController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildNeumorphicGlassContainer(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect 1
              AnimatedBuilder(
                animation: rippleController,
                builder: (context, child) {
                  return Container(
                    width: 90 + (rippleController.value * 40),
                    height: 90 + (rippleController.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFFEB3678,
                        ).withOpacity(1 - rippleController.value),
                        width: 3,
                      ),
                    ),
                  );
                },
              ),
              // Ripple effect 2
              AnimatedBuilder(
                animation: rippleController,
                builder: (context, child) {
                  final delayedValue = ((rippleController.value + 0.5) % 1.0);
                  return Container(
                    width: 90 + (delayedValue * 40),
                    height: 90 + (delayedValue * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFFFB773C,
                        ).withOpacity(1 - delayedValue),
                        width: 3,
                      ),
                    ),
                  );
                },
              ),
              ScaleTransition(
                scale: pulseAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEB3678), Color(0xFFFB773C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEB3678).withOpacity(0.7),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 40),
                ),
              ),
            ],
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'جاري التسجيل...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${formatDuration(recordingDuration)} / 05:00',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicGlassContainer({
    Key? key,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24),
  }) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
