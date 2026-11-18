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
            child: GlowOrb(color: StoryJobTheme.cyanAccent, size: 260),
          ),
          const Positioned(
            bottom: -60,
            left: -40,
            child: GlowOrb(color: StoryJobTheme.primaryViolet, size: 260),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Wähle deinen Weg',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Bist du als Talent auf der Suche nach echten Chancen oder repräsentierst du ein Team / Unternehmen?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: StoryJobTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Talent-Button Card
                      _buildRoleCard(
                        context,
                        title: 'Talent / Member',
                        subtitle: 'Deine StoryDNA, Werte & persönliche Chancen.',
                        assetPath: 'assets/images/Auth/DNA.png',
                        accentColor: StoryJobTheme.cyanAccent,
                        roleKey: 'talent',
                      ),
                      const SizedBox(height: 20),

                      // Team-Button Card
                      _buildRoleCard(
                        context,
                        title: 'StoryTeam / Business',
                        subtitle: 'Gemeinsame Werte, Projekte & Unternehmenskultur.',
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

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String assetPath,
    required Color accentColor,
    required String roleKey,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DnaAuthScreen(selectedRole: roleKey),
          ),
        );
      },
      borderRadius: BorderRadius.circular(28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  assetPath,
                  width: 54,
                  height: 54,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 18),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: StoryJobTheme.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}