// lib/features/auth/screens/role_selection_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/auth/screens/register_screen.dart';

enum StoryRole { talent, recruiter }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  StoryRole _selectedRole = StoryRole.talent;

  void _proceed() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          initialRole: _selectedRole == StoryRole.talent ? 'talent' : 'recruiter',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color storyBg = StoryJobTheme.backgroundBase;
    const Color storyCyan = StoryJobTheme.cyanAccent;
    const Color storyViolet = StoryJobTheme.primaryViolet;

    return Scaffold(
      backgroundColor: storyBg,
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: GlowOrb(
              color: storyViolet.withValues(alpha: 0.35),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: GlowOrb(
              color: storyCyan.withValues(alpha: 0.25),
              size: 280,
            ),
          ),

          SafeArea(
            top: true,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -4),
                        child: Image.asset(
                          'assets/onboarding/StoryJob-Logo-weiss.png',
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text(
                            'StoryJob',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),

                  const Text(
                    'Zeig bei StoryJob, wer du wirklich bist.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      'Keine Bewerbung. Kein Lebenslauf. Keine Noten.\nNur deine Story zählt.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildGlassRoleCard(
                            role: StoryRole.talent,
                            badgeText: 'FÜR TALENTE & SUCHENDE',
                            badgeColor: storyCyan,
                            icon: Icons.all_inclusive_rounded,
                            title: 'Gesehen werden',
                            subtitle: 'Zeig deine Identität und Motivation im 30-Sekunden-Format.',
                            features: const [
                              'Kein Lebenslauf-Zwang, keine starren Anschreiben',
                              'Präsentiere deine StoryJob DNA per Voice oder Video',
                              'Finde Chancen durch echten Team-Fit',
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _buildGlassRoleCard(
                            role: StoryRole.recruiter,
                            badgeText: 'FÜR UNTERNEHMEN & TEAMS',
                            badgeColor: storyViolet,
                            icon: Icons.business_center_rounded,
                            title: 'Kultur zeigen',
                            subtitle: 'Stellt euch mit einem authentischen Image-Pitch vor.',
                            features: const [
                              'Keine leeren Floskeln in Textanzeigen',
                              'Team, Spirit und Alltag vorab erlebbar machen',
                              'Menschen statt PDFs: Potenziale direkt erkennen',
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  GlassButton(
                    label: _selectedRole == StoryRole.talent
                        ? 'Als Talent starten 🚀'
                        : 'Als Unternehmen starten 🚀',
                    isPrimaryGlow: true,
                    height: 52,
                    borderRadius: 26,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _proceed,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassRoleCard({
    required StoryRole role,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> features,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedRole = role);
      },
      child: GlassCard(
        borderRadius: 20,
        borderGradient: isSelected ? StoryJobTheme.dnaCardBorder : null,
        borderColor: isSelected ? badgeColor : StoryJobTheme.cardBorder,
        hasNeonGlow: isSelected,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Icon(icon, color: badgeColor, size: 18),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? badgeColor : StoryJobTheme.textMuted,
                  size: 22,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            Column(
              children: features.map(
                (feat) => Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.check_rounded, color: badgeColor, size: 13),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          feat,
                          style: const TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}