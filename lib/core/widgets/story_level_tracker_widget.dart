// lib/core/widgets/story_level_tracker_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

enum StoryDnaTier {
  starter,
  resonanz,
  magnet,
  praesenz,
}

extension StoryDnaTierExtension on StoryDnaTier {
  String get title {
    switch (this) {
      case StoryDnaTier.starter:
        return 'Eigener Klang';
      case StoryDnaTier.resonanz:
        return 'Werte-Fokus';
      case StoryDnaTier.magnet:
        return 'Resonanz-Magnet';
      case StoryDnaTier.praesenz:
        return 'Volle Präsenz';
    }
  }

  String get description {
    switch (this) {
      case StoryDnaTier.starter:
        return 'Deine Basis steht. Ergänze Sprach-Storys, damit Menschen deine Haltung spüren.';
      case StoryDnaTier.resonanz:
        return 'Deine Werte sind sichtbar. Teams mit ähnlicher Wellenlänge entdecken dein Profil.';
      case StoryDnaTier.magnet:
        return 'Hohe Resonanz. Teams und Macher erleben sofort ein klares Bild deiner Persönlichkeit.';
      case StoryDnaTier.praesenz:
        return 'Maximale Entfaltung. Deine Story inspiriert und verbindet dich direkt auf Augenhöhe.';
    }
  }

  String get perkDescription {
    switch (this) {
      case StoryDnaTier.starter:
        return 'Erste Wahrnehmung im Resonanzfeld';
      case StoryDnaTier.resonanz:
        return 'Sichtbar für Werte-Gemeinschaften';
      case StoryDnaTier.magnet:
        return 'Hohe Resonanz bei passenden Teams';
      case StoryDnaTier.praesenz:
        return 'Vollständige Entfaltung auf Augenhöhe';
    }
  }

  Color get color {
    switch (this) {
      case StoryDnaTier.starter:
        return const Color(0xFFB47854); // Edles Warmbronze
      case StoryDnaTier.resonanz:
        return StoryJobTheme.primaryViolet; // Violett: Werte & Resonanz
      case StoryDnaTier.magnet:
        return StoryJobTheme.champagneGold; // Gold: Magnetismus
      case StoryDnaTier.praesenz:
        return StoryJobTheme.cyanAccent; // Cyan: Volle Präsenz & Klarheit
    }
  }

  int get threshold {
    switch (this) {
      case StoryDnaTier.starter:
        return 0;
      case StoryDnaTier.resonanz:
        return 35;
      case StoryDnaTier.magnet:
        return 70;
      case StoryDnaTier.praesenz:
        return 90;
    }
  }
}

class StoryLevelTrackerWidget extends StatelessWidget {
  final int dnaCompleteness; // z.B. 78 (%)
  final int storiesRecorded; // z.B. 3
  final int activeValuesCount; // z.B. 4 (ausgewählte Werte)
  final VoidCallback? onDeepenStory;

  const StoryLevelTrackerWidget({
    super.key,
    this.dnaCompleteness = 78,
    this.storiesRecorded = 3,
    this.activeValuesCount = 4,
    this.onDeepenStory,
  });

  StoryDnaTier get _currentTier {
    final clamped = dnaCompleteness.clamp(0, 100);
    if (clamped >= StoryDnaTier.praesenz.threshold) {
      return StoryDnaTier.praesenz;
    } else if (clamped >= StoryDnaTier.magnet.threshold) {
      return StoryDnaTier.magnet;
    } else if (clamped >= StoryDnaTier.resonanz.threshold) {
      return StoryDnaTier.resonanz;
    }
    return StoryDnaTier.starter;
  }

  StoryDnaTier? get _nextTier {
    switch (_currentTier) {
      case StoryDnaTier.starter:
        return StoryDnaTier.resonanz;
      case StoryDnaTier.resonanz:
        return StoryDnaTier.magnet;
      case StoryDnaTier.magnet:
        return StoryDnaTier.praesenz;
      case StoryDnaTier.praesenz:
        return null;
    }
  }

  double get _progressToNextTier {
    final next = _nextTier;
    if (next == null) return 1.0;
    final currentMin = _currentTier.threshold;
    final nextTarget = next.threshold;
    final range = nextTarget - currentMin;
    final progressIntoRange = dnaCompleteness.clamp(0, 100) - currentMin;
    return (progressIntoRange / range).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final tier = _currentTier;
    final next = _nextTier;
    final int clampedValue = dnaCompleteness.clamp(0, 100);
    final double radialProgress = _progressToNextTier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tier.color.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: tier.color.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER MIT RADIALEM FORTSCHRITTSRING
          Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(66, 66),
                      painter: _RadialProgressPainter(
                        progress: radialProgress,
                        progressColor: tier.color,
                        trackColor: Colors.white.withValues(alpha: 0.06),
                        strokeWidth: 5.5,
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tier.color.withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: tier.color,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'STORYJOB DNA™',
                          style: TextStyle(
                            color: tier.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tier.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tier.color.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$clampedValue% entfaltet',
                            style: TextStyle(
                              color: tier.color,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: tier.title,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (next != null) ...[
                            const TextSpan(
                              text: '  ›  ',
                              style: TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: next.title,
                              style: const TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.description,
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. ENTFALTUNGS-LEITER (DIE 4 STUFEN OHNE RATING-DRUCK)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: StoryJobTheme.backgroundBase.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: Column(
              children: [
                _buildTierRow(
                  tierItem: StoryDnaTier.starter,
                  currentTier: tier,
                  clampedValue: clampedValue,
                ),
                const Divider(color: StoryJobTheme.cardBorder, height: 16),
                _buildTierRow(
                  tierItem: StoryDnaTier.resonanz,
                  currentTier: tier,
                  clampedValue: clampedValue,
                ),
                const Divider(color: StoryJobTheme.cardBorder, height: 16),
                _buildTierRow(
                  tierItem: StoryDnaTier.magnet,
                  currentTier: tier,
                  clampedValue: clampedValue,
                ),
                const Divider(color: StoryJobTheme.cardBorder, height: 16),
                _buildTierRow(
                  tierItem: StoryDnaTier.praesenz,
                  currentTier: tier,
                  clampedValue: clampedValue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. MENSCHLICHER NÄCHSTER SCHRITT (PILL-BUTTON STATT "BOOST")
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StoryJobTheme.backgroundBase.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nächster Resonanz-Schritt:',
                        style: TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        storiesRecorded < 2
                            ? '🎙️ Nimm eine 30s Sprach-Story auf'
                            : (activeValuesCount < 5
                                ? '🤝 Werteprofil weiter schärfen'
                                : '✨ Täglichen Audio-Spark einsprechen'),
                        style: TextStyle(
                          color: tier.color,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tier.color.withValues(alpha: 0.18),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: tier.color.withValues(alpha: 0.45)),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDeepenStory?.call();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text(
                    'Vertiefen',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow({
    required StoryDnaTier tierItem,
    required StoryDnaTier currentTier,
    required int clampedValue,
  }) {
    final bool isActive = currentTier == tierItem;
    final bool isPassed = clampedValue >= (tierItem == StoryDnaTier.starter ? 35 : tierItem.threshold);

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tierItem.color.withValues(alpha: isActive ? 0.25 : 0.10),
            border: Border.all(
              color: tierItem.color.withValues(alpha: isActive ? 1.0 : 0.4),
              width: 1.2,
            ),
          ),
          child: Icon(
            isPassed && !isActive
                ? Icons.check_rounded
                : (isActive ? Icons.play_arrow_rounded : Icons.lock_outline_rounded),
            color: tierItem.color,
            size: 13,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          tierItem.title,
          style: TextStyle(
            color: isActive
                ? StoryJobTheme.textPrimary
                : (isPassed ? StoryJobTheme.textSecondary : StoryJobTheme.textMuted),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: tierItem.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'ab ${tierItem.threshold}%',
            style: TextStyle(
              color: tierItem.color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tierItem.perkDescription,
          style: TextStyle(
            color: isActive
                ? tierItem.color
                : StoryJobTheme.textSecondary.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _RadialProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}