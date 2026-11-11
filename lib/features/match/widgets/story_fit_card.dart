// lib/features/match/widgets/story_resonance_mirror_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class ResonanceDimension {
  final String label;
  final double score; // 0.0 bis 1.0
  final IconData icon;

  const ResonanceDimension({
    required this.label,
    required this.score,
    required this.icon,
  });

  String get qualitativeLabel {
    if (score >= 0.88) return 'Starke Resonanz ✨';
    if (score >= 0.70) return 'Gleiche Wellenlänge';
    return 'Harmonisch';
  }
}

class StoryResonanceMirrorCard extends StatelessWidget {
  final String partnerName;
  final String roleOrCompany;
  final String overallMatchScore; // z. B. "Hohe Resonanz ✨" oder "94%"
  final String coreReasonQuote;
  final List<ResonanceDimension> dimensions;
  final List<String> sharedValues;
  final VoidCallback onStartDialog;

  const StoryResonanceMirrorCard({
    super.key,
    required this.partnerName,
    required this.roleOrCompany,
    required this.overallMatchScore,
    required this.coreReasonQuote,
    required this.dimensions,
    required this.sharedValues,
    required this.onStartDialog,
  });

  @override
  Widget build(BuildContext context) {
    final String displayScore = overallMatchScore.contains('%')
        ? '$overallMatchScore Wellenlänge'
        : overallMatchScore;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Partner & Resonanz-Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleOrCompany,
                      style: TextStyle(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.95),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      partnerName,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.40),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: StoryJobTheme.cyanAccent),
                    const SizedBox(width: 4),
                    Text(
                      displayScore,
                      style: const TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Resonanz-Spiegel: Die Begründung
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.primaryViolet, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'WARUM ES MENSCHLICH PASST',
                      style: TextStyle(
                        color: StoryJobTheme.primaryViolet,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  coreReasonQuote,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Resonanz-Achsen (Schwingungs-Balken)
          const Text(
            'Gemeinsame Resonanz-Ebenen:',
            style: TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...dimensions.map((dim) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(dim.icon, size: 14, color: StoryJobTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          dim.label,
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dim.qualitativeLabel,
                          style: TextStyle(
                            color: dim.score > 0.85
                                ? StoryJobTheme.cyanAccent
                                : StoryJobTheme.champagneGold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: dim.score,
                        minHeight: 5,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          dim.score > 0.85
                              ? StoryJobTheme.cyanAccent
                              : StoryJobTheme.primaryViolet,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),

          // 4. Schnittmengen-Tags (Werte & Initiativen)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sharedValues.map((val) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 12, color: StoryJobTheme.cyanAccent),
                    const SizedBox(width: 4),
                    Text(
                      val,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 5. Direkter Übergang in den Dialog (Pill-Button)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryJobTheme.primaryViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                onStartDialog();
              },
              icon: const Icon(Icons.forum_rounded, size: 17),
              label: const Text(
                'StoryDialog auf dieser Basis starten',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}