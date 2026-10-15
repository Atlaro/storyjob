// lib/core/widgets/glow_orb.dart
import 'package:flutter/material.dart';

class GlowOrb extends StatefulWidget {
  final Color color;
  final double size;
  final double opacity;
  final bool enablePulse;
  final Duration pulseDuration;

  const GlowOrb({
    super.key,
    required this.color,
    this.size = 200,
    this.opacity = 0.35,
    this.enablePulse = true,
    this.pulseDuration = const Duration(seconds: 4),
  });

  @override
  State<GlowOrb> createState() => _GlowOrbState();
}

class _GlowOrbState extends State<GlowOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.06,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacity * 0.75,
      end: widget.opacity * 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    if (widget.enablePulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GlowOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulse != oldWidget.enablePulse) {
      if (widget.enablePulse) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final currentScale = widget.enablePulse ? _scaleAnimation.value : 1.0;
            final currentOpacity = (widget.enablePulse
                    ? _opacityAnimation.value
                    : widget.opacity)
                .clamp(0.0, 1.0);

            return Transform.scale(
              scale: currentScale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: currentOpacity),
                      widget.color.withValues(alpha: currentOpacity * 0.35),
                      widget.color.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}