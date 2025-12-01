import 'package:flutter/material.dart';
import 'dart:ui';
import '../painters/gradient_circular_progress_painter.dart';

class UploadingCard extends StatelessWidget {
  final String? fileName;
  final int countdownSeconds;
  final String Function(int) formatDuration;
  final AnimationController progressController;
  final VoidCallback onCancel;

  const UploadingCard({
    Key? key,
    required this.fileName,
    required this.countdownSeconds,
    required this.formatDuration,
    required this.progressController,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildNeumorphicGlassContainer(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: progressController,
                      child: CustomPaint(
                        size: const Size(60, 60),
                        painter: GradientCircularProgressPainter(
                          progress: 1.0,
                          strokeWidth: 5,
                          gradient: const SweepGradient(
                            colors: [
                              Color(0xFF06D6A0),
                              Color(0xFF118AB2),
                              Color(0xFF06D6A0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'ملف صوتي',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'جاري المعالجة...',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFA7A9BE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06D6A0), Color(0xFF118AB2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06D6A0).withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  formatDuration(countdownSeconds),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEB3678).withOpacity(0.25),
                  const Color(0xFFFB773C).withOpacity(0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEB3678).withOpacity(0.6),
                width: 2.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(20),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded, color: Colors.white, size: 26),
                      SizedBox(width: 14),
                      Text(
                        'إلغاء العملية',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
