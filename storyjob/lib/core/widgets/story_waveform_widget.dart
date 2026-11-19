// lib/core/widgets/story_waveform_widget.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class StoryWaveformWidget extends StatefulWidget {
  final bool isRecording;
  final bool isPlaying;
  final double progress; // 0.0 bis 1.0 beim Abhören
  final bool interactiveSeek;
  final ValueChanged<double>? onSeek;
  final int barCount;
  final double maxHeight;
  final Color? activeColor;
  final Color? inactiveColor;
  final Gradient? gradient;

  const StoryWaveformWidget({
    super.key,
    this.isRecording = false,
    this.isPlaying = false,
    this.progress = 0.0,
    this.interactiveSeek = false,
    this.onSeek,
    this.barCount = 22,
    this.maxHeight = 28.0,
    this.activeColor,
    this.inactiveColor,
    this.gradient,
  });

  @override
  State<StoryWaveformWidget> createState() => _StoryWaveformWidgetState();
}

class _StoryWaveformWidgetState extends State<StoryWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<double> _basePattern = [
    0.32, 0.55, 0.82, 0.45, 0.95, 0.60, 0.38, 0.68, 0.88, 0.52, 1.0,
    0.66, 0.44, 0.75, 0.92, 0.50, 0.80, 0.58, 0.36, 0.65, 0.46, 0.30,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _syncAnimationState();
  }

  @override
  void didUpdateWidget(covariant StoryWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording ||
        oldWidget.isPlaying != widget.isPlaying) {
      _syncAnimationState();
    }
  }

  void _syncAnimationState() {
    if (widget.isRecording || widget.isPlaying) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSeek(Offset localPosition, double totalWidth) {
    if (!widget.interactiveSeek || widget.onSeek == null || totalWidth <= 0) {
      return;
    }
    final ratio = (localPosition.dx / totalWidth).clamp(0.0, 1.0);
    widget.onSeek!(ratio);
  }

  @override
  Widget build(BuildContext context) {
    final activeCol = widget.activeColor ?? StoryJobTheme.cyanAccent;
    final inactiveCol = widget.inactiveColor ??
        StoryJobTheme.primaryViolet.withValues(alpha: 0.60);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 160.0;

        Widget bars = AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final phase = _controller.value * math.pi * 2;

            return SizedBox(
              height: widget.maxHeight,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(widget.barCount, (index) {
                  final base = _basePattern[index % _basePattern.length];
                  double scale = base;

                  if (widget.isRecording) {
                    final wave = 0.5 + 0.5 * math.sin(phase + index * 0.65);
                    final secondary =
                        0.5 + 0.5 * math.cos(phase * 1.4 - index * 0.4);
                    scale = (0.22 + (0.78 * base * (0.45 + 0.55 * wave))) *
                        (0.75 + 0.25 * secondary);
                  } else if (widget.isPlaying) {
                    final pulse = 0.88 + 0.12 * math.sin(phase + index * 0.5);
                    scale = base * pulse;
                  }

                  final barHeight = (widget.maxHeight * scale.clamp(0.18, 1.0))
                      .clamp(4.0, widget.maxHeight);

                  final barRatio =
                      widget.barCount > 1 ? index / (widget.barCount - 1) : 0.0;
                  final isReached =
                      widget.isRecording || barRatio <= widget.progress.clamp(0.0, 1.0);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    curve: Curves.easeOut,
                    width: 2.6,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: widget.gradient != null
                          ? Colors.white
                          : (isReached ? activeCol : inactiveCol),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            );
          },
        );

        if (widget.gradient != null) {
          bars = ShaderMask(
            shaderCallback: (bounds) => widget.gradient!.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: bars,
          );
        }

        if (!widget.interactiveSeek) {
          return bars;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleSeek(details.localPosition, width),
          onHorizontalDragUpdate: (details) =>
              _handleSeek(details.localPosition, width),
          child: bars,
        );
      },
    );
  }
}