// lib/features/recruiter/widgets/early_access_talent_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/recruiter/widgets/recruiter_upgrade_modal.dart';

class EarlyAccessTalentCard extends StatelessWidget {
  final String matchScore;
  final String roleFocus;
  final String timeRemaining;
  final VoidCallback? onUpgrade;

  const EarlyAccessTalentCard({
    super.key,
    this.matchScore = '96%',
    this.roleFocus = 'Vertriebsleitung & Hands-on Führung',
    this.timeRemaining = '19:42 Std.',
    this.onUpgrade,
  });

  void _triggerUpgrade(BuildContext context) {
    HapticFeedback.heavyImpact();
    if (onUpgrade != null) {
      onUpgrade!();
    } else {
      RecruiterUpgradeModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: StoryJobTheme.champagneGold.withValues(alpha: 0.45),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: StoryJobTheme.champagneGold.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // 1. Ausgegrauter / Verschwommener Dummy-Hintergrund
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StoryJobTheme.cardSurface,
                          border: Border.all(
                            color: StoryJobTheme.champagneGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: StoryJobTheme.champagneGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hohe Werte-Resonanz',
                              style: TextStyle(
                                color: StoryJobTheme.textPrimary.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              roleFocus,
                              style: TextStyle(
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.champagneGold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: StoryJobTheme.champagneGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          matchScore,
                          style: const TextStyle(
                            color: StoryJobTheme.champagneGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Frost-Glass-Overlay mit Prioritäts-CTA
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.5, sigmaY: 5.5),
                child: Container(
                  color: StoryJobTheme.backgroundBase.withValues(alpha: 0.72),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.champagneGold, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Priorisierter Zugang aktiv',
                            style: TextStyle(
                              color: StoryJobTheme.champagneGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Freischaltung für Basis-Accounts in $timeRemaining',
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryJobTheme.primaryViolet,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          onPressed: () => _triggerUpgrade(context),
                          icon: const Icon(Icons.workspace_premium_rounded, size: 18, color: StoryJobTheme.champagneGold),
                          label: const Text(
                            'Resonanz-Story vorab entdecken ✨',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}