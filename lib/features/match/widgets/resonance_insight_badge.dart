// lib/features/match/widgets/resonance_insight_badge.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class ResonanceInsightBadge extends StatelessWidget {
  final String matchPercentage;
  final Map<String, dynamic> storyJobDnaData; // Greift auf die StoryJob DNA zu
  final bool isForRecruiter;
  final bool showArcGraphic; // Neu: Schaltet den großen Leucht-Bogen aus den Mockups ein

  const ResonanceInsightBadge({
    super.key,
    required this.matchPercentage,
    required this.storyJobDnaData,
    this.isForRecruiter = false,
    this.showArcGraphic = true,
  });

  double _parsePercentage(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(clean) ?? 94.0;
    return val.clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isForRecruiter ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;
    final double numericPercentage = _parsePercentage(matchPercentage);

    // Resonanz-Begründung
    final String insightText = storyJobDnaData['resonanceInsight'] ??
        storyJobDnaData['resonanceReason'] ??
        'Eure StoryJob DNA zeigt starke Schnittmengen bei gelebten Werten und Teamkultur.';

    // Optionale geteilte Werte für direkte visuelle Untermauerung
    final List<String> sharedValues = (storyJobDnaData['sharedValues'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final String displayBadge = matchPercentage.contains('%')
        ? '$matchPercentage Resonanz'
        : '$matchPercentage ✨';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (showArcGraphic)
            BoxShadow(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header-Zeile mit Titel und Pill-Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accentColor, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'StoryJob DNA Resonanz',
                    style: TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  displayBadge,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Der leuchtende Resonanz-Bogen aus den Mockups
          if (showArcGraphic) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: 130,
              height: 70,
              child: CustomPaint(
                painter: _NeonArcPainter(progress: numericPercentage / 100.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "${numericPercentage.toInt()}%",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "mit Firmen-DNA",
              style: TextStyle(
                fontSize: 11.5,
                color: StoryJobTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Resonanz-Erklärungstext
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              insightText,
              style: const TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),

          // Geteilte Werte-Chips
          if (sharedValues.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sharedValues.map((val) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 12, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          val,
                          style: const TextStyle(
                            fontSize: 11,
                            color: StoryJobTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// CustomPainter für den fließenden Neon-Bogen (Cyan -> Violett -> Pink)
class _NeonArcPainter extends CustomPainter {
  final double progress;
  _NeonArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.5;

    // Hintergrund-Bogen (abgedunkelt)
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Neon-Verlaufsbogen
    final sweepGradient = const SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: [
        StoryJobTheme.cyanAccent,
        StoryJobTheme.primaryViolet,
        StoryJobTheme.pinkMagenta,
      ],
    );

    final activePaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * progress.clamp(0.0, 1.0),
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonArcPainter oldDelegate) => oldDelegate.progress != progress;
}