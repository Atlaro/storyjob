// lib/features/record/widgets/ripple_circle.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RippleCircle extends StatelessWidget {
  final Animation<double> animation;
  final double radius;
  final Color color;
  final double delay;

  const RippleCircle({
    super.key,
    required this.animation,
    required this.radius,
    required this.color,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = (animation.value + delay) % 1.0;
        final curvedProgress = Curves.easeOut.transform(progress);
        final currentDiameter = math.max(4.0, radius * curvedProgress * 2);
        final opacity = ((1.0 - progress) * 0.75).clamp(0.0, 1.0);

        return Container(
          width: currentDiameter,
          height: currentDiameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: opacity),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: opacity * 0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}