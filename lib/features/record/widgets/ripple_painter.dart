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
        return Container(
          width: radius * progress * 2,
          height: radius * progress * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0)),
              width: 2.0,
            ),
          ),
        );
      },
    );
  }
}