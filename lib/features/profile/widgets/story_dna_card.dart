// lib/features/profile/widgets/story_dna_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/identity/screens/story_dna_circles_screen.dart';

class StoryDnaCard extends StatelessWidget {
  final String userId;
  final String audioDuration;
  final int matchesCount;
  final VoidCallback? onTap;
  final bool isProtected; // Optional: Zwei-Stufen-Sichtbarkeit
  final VoidCallback? onUnlock;

  const StoryDnaCard({
    super.key,
    required this.userId,
    required this.audioDuration,
    required this.matchesCount,
    this.onTap,
    this.isProtected = false,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      borderGradient: StoryJobTheme.dnaCardBorder,
      hasNeonGlow: true,
      padding: const EdgeInsets.all(18),
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StoryDnaCirclesScreen(),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header-Zeile mit DNA-Badge & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isProtected ? Icons.shield_rounded : Icons.fingerprint_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isProtected ? 'GESCHÜTZTE STORYJOB DNA' : 'STORYJOB DNA',
                    style: const TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: StoryJobTheme.primaryViolet,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$matchesCount Resonanzen',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hauptüberschrift & Beschreibung
          Text(
            isProtected ? 'Profil vor fremden Blicken geschützt' : 'Resonanz-Ebenen & Werte-Kreise',
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isProtected
              ? 'Werte & Talente schwingen im Hintergrund. Volle Identität nur nach Freigabe.'
              : 'Verbindet dich über Haltung, Fähigkeiten und Interessen mit passenden Teams.',
            style: const TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          // Integrierte Neon-Audiowelle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.graphic_eq_rounded,
                  color: StoryJobTheme.cyanAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(24, (index) {
                        const heights = [8, 14, 20, 12, 22, 16, 10, 24, 18, 12, 16, 20, 10, 14, 22, 16, 12, 8, 18, 14, 10, 16, 8, 12];
                        return Container(
                          width: 2.5,
                          height: heights[index % heights.length].toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  audioDuration,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: StoryJobTheme.cyanAccent,
                  size: 13,
                ),
              ],
            ),
          ),

          // Entsperren-Button bei geschütztem Modus
          if (isProtected) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text('Profil freigeben'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                  foregroundColor: StoryJobTheme.cyanAccent,
                  side: const BorderSide(color: StoryJobTheme.cyanAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}