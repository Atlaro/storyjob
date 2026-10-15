// lib/features/profile/widgets/security_trust_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class SecurityTrustWidget extends StatelessWidget {
  const SecurityTrustWidget({super.key});

  /// Öffnet den vollständigen Dialog "Gesicherter Bereich"
  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header mit Trust-Badge
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cardSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Center(
                          child: ShaderMask(
                            shaderCallback: _gradientShader,
                            child: Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Vertraulicher Raum',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Einleitungstext
                  const Text(
                    'Bei StoryJob stehen Menschlichkeit und Datensouveränität an erster Stelle. '
                    'Deine Sprachaufnahmen, Werte und persönlichen Dialoge bleiben strikt geschützt '
                    'und dienen einzig dem Kennenlernen auf Augenhöhe.',
                    style: TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Divider(color: StoryJobTheme.cardBorder, height: 1),
                  const SizedBox(height: 16),

                  // Die beiden Sicherheits-Kacheln
                  const SecurityTrustWidget(),
                  const SizedBox(height: 22),

                  // Pill Button
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Verstanden & Sicher fühlen ✨',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Shader _gradientShader(Rect bounds) {
    return const LinearGradient(
      colors: [StoryJobTheme.cyanAccent, StoryJobTheme.primaryViolet],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureCard(
          icon: Icons.lock_outline_rounded,
          iconColor: StoryJobTheme.emeraldGreen,
          title: 'Geprüfte Datensicherheit',
          subtitle: 'End-to-End verschlüsselte Voice- und Dialogkanäle',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.shield_outlined,
          iconColor: StoryJobTheme.cyanAccent,
          title: 'DSGVO & Vertraulichkeit',
          subtitle: 'Keine Profilweitergabe ohne dein Einverständnis',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StoryJobTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}