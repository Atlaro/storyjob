import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/dna_auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          const Positioned(
            top: -70,
            right: -40,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent,
              size: 260,
            ),
          ),
          const Positioned(
            bottom: -70,
            left: -40,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet,
              size: 260,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/splash/Branding.png',
                          width: 265,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nutze dein Potenzial!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Finde, was zu dir passt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: StoryJobTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 1. Talent / StoryDNA
                      const _RoleCard(
                        title: 'Zeig, was dich ausmacht',
                        ctaLabel: 'StoryDNA erstellen',
                        subtitle:
                            'Mach deine Persönlichkeit, Werte und Stärken für passende Jobs sichtbar.',
                        assetPath: 'assets/images/Auth/DNA.png',
                        accentColor: StoryJobTheme.cyanAccent,
                        roleKey: 'talent',
                      ),

                      const SizedBox(height: 14),

                      // 2. Teams / StoryTeam
                      const _RoleCard(
                        title: 'Zeig, was euch ausmacht',
                        ctaLabel: 'StoryTeam erstellen',
                        subtitle:
                            'Präsentiert eure Kultur und begeistert passende Talente für euer Team oder Unternehmen.',
                        assetPath: 'assets/images/Auth/Team.png',
                        accentColor: StoryJobTheme.primaryViolet,
                        roleKey: 'team',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.ctaLabel,
    required this.subtitle,
    required this.assetPath,
    required this.accentColor,
    required this.roleKey,
  });

  final String title;
  final String ctaLabel;
  final String subtitle;
  final String assetPath;
  final Color accentColor;
  final String roleKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DnaAuthScreen(selectedRole: roleKey),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.30),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: StoryJobTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: StoryJobTheme.textSecondary,
                                height: 1.38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ctaLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}