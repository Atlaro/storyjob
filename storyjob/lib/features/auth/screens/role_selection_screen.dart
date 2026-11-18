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
            top: -60,
            right: -40,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent,
              size: 260,
            ),
          ),
          const Positioned(
            bottom: -60,
            left: -40,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet,
              size: 260,
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/splash/Branding.png',
                          width: 280, // Hier von 210 auf 280 vergrößert
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Nutze dein Potenzial!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Finde, was zu dir passt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: StoryJobTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _RoleCard(
                        title: 'StoryJob™ DNA',
                        subtitle: 'Zeig dein Potenzial. Entdecke, was dich ausmacht.',
                        assetPath: 'assets/images/Auth/DNA.png',
                        accentColor: StoryJobTheme.cyanAccent,
                        roleKey: 'talent',
                      ),

                      const SizedBox(height: 16),

                      _RoleCard(
                        title: 'StoryJob™ Teams',
                        subtitle: 'Zeigt, was euch als Unternehmen ausmacht. Präsentiert Kultur, Werte und Benefits.',
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
    required this.subtitle,
    required this.assetPath,
    required this.accentColor,
    required this.roleKey,
  });

  final String title;
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
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.38),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: StoryJobTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: accentColor,
                    size: 17,
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