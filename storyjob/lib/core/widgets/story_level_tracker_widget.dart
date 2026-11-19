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
        return 'Werte-Passung-Magnet';
      case StoryDnaTier.praesenz:
        return 'Volle Präsenz';
    }
  }

  String get stageBadge {
    switch (this) {
      case StoryDnaTier.starter:
        return 'Stimme';
      case StoryDnaTier.resonanz:
        return 'Werte';
      case StoryDnaTier.magnet:
        return 'Vertiefung';
      case StoryDnaTier.praesenz:
        return 'Präsenz';
    }
  }

  String get description {
    switch (this) {
      case StoryDnaTier.starter:
        return 'Deine Basis steht. Ergänze Sprach-Storys, damit Menschen deine Haltung spüren.';
      case StoryDnaTier.resonanz:
        return 'Deine Werte sind sichtbar. Teams mit ähnlicher Wellenlänge entdecken dein Profil.';
      case StoryDnaTier.magnet:
        return 'Starke Ausstrahlung. Teams und Macher erleben sofort ein klares Bild deiner Persönlichkeit.';
      case StoryDnaTier.praesenz:
        return 'Breite Entfaltung. Deine Story inspiriert und verbindet dich direkt auf Augenhöhe.';
    }
  }

  String get perkDescription {
    switch (this) {
      case StoryDnaTier.starter:
        return 'Erste Wahrnehmung im Wertefeld';
      case StoryDnaTier.resonanz:
        return 'Sichtbar für Werte-Gemeinschaften';
      case StoryDnaTier.magnet:
        return 'Klare Verbindung zu passenden Teams';
      case StoryDnaTier.praesenz:
        return 'Vollständige Entfaltung auf Augenhöhe';
    }
  }

  Color get color {
    switch (this) {
      case StoryDnaTier.starter:
        return const Color(0xFFB47854);
      case StoryDnaTier.resonanz:
        return StoryJobTheme.primaryViolet;
      case StoryDnaTier.magnet:
        return StoryJobTheme.champagneGold;
      case StoryDnaTier.praesenz:
        return StoryJobTheme.cyanAccent;
    }
  }
}

class StoryLevelTrackerWidget extends StatelessWidget {
  final int dnaCompleteness;
  final int storiesRecorded;
  final int activeValuesCount;
  final VoidCallback? onDeepenStory;

  const StoryLevelTrackerWidget({
    super.key,
    this.dnaCompleteness = 78,
    this.storiesRecorded = 3,
    this.activeValuesCount = 4,
    this.onDeepenStory,
  });

  int get _tierRank {
    final clamped = dnaCompleteness.clamp(0, 100);
    if (clamped >= 90) return 3;
    if (clamped >= 70) return 2;
    if (clamped >= 35) return 1;
    return 0;
  }

  StoryDnaTier get _currentTier {
    switch (_tierRank) {
      case 3:
        return StoryDnaTier.praesenz;
      case 2:
        return StoryDnaTier.magnet;
      case 1:
        return StoryDnaTier.resonanz;
      default:
        return StoryDnaTier.starter;
    }
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

  double get _radialVisualProgress {
    final next = _nextTier;
    if (next == null) return 1.0;
    final clamped = dnaCompleteness.clamp(0, 100);
    final double normalized = (clamped % 35) / 35.0;
    return normalized.clamp(0.18, 0.92);
  }

  @override
  Widget build(BuildContext context) {
    final tier = _currentTier;
    final next = _nextTier;
    final double radialProgress = _radialVisualProgress;

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tier.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tier.color.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'In Entfaltung',
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

          // 2. ENTFALTUNGS-LEITER (OHNE SCHWELLENWERTE / SCORES)
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
                  rank: 0,
                ),
                const Divider(color: StoryJobTheme.cardBorder, height: 16),
                _buildTierRow(
                  tierItem: StoryDnaTier.resonanz,
                  rank: 1,
                ),
                const Divider(color: StoryJobTheme.cardBorder, height: 16),
                _buildTierRow(
                  tierItem: StoryDnaTier.magnet,
                  rank: 2,
                ),
                const Divider(color: StoryJobTheme.cardBorder, height: 16),
                _buildTierRow(
                  tierItem: StoryDnaTier.praesenz,
                  rank: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. MENSCHLICHER NÄCHSTER SCHRITT
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
                        'Nächster Schritt für deine Geschichte:',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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
    required int rank,
  }) {
    final bool isActive = _tierRank == rank;
    final bool isPassed = _tierRank > rank;

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
            isPassed
                ? Icons.check_rounded
                : (isActive
                    ? Icons.play_arrow_rounded
                    : Icons.lock_outline_rounded),
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
                : (isPassed
                    ? StoryJobTheme.textSecondary
                    : StoryJobTheme.textMuted),
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
            tierItem.stageBadge,
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