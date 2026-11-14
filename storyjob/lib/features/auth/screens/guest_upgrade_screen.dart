// lib/features/auth/screens/guest_upgrade_screen.dart
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/mystic_scaffold.dart';
import 'package:storyjob/core/widgets/optimized_glass_card.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/features/auth/screens/register_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';

class GuestUpgradeScreen extends StatelessWidget {
  const GuestUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MysticScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: StoryJobTheme.textPrimary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.15),
                      border: Border.all(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 52,
                      color: StoryJobTheme.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Sichere deine Storys',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: StoryJobTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Erstelle jetzt deinen Account, um deine Sprachaufnahmen dauerhaft zu speichern und alle Matches freizuschalten.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: StoryJobTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 36),
                GlassButton(
                  label: 'Konto jetzt erstellen',
                  isPrimaryGlow: true,
                  height: 54,
                  borderRadius: 16,
                  icon: Icons.person_add_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const TalentNavigationScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Weiterhin als Gast nutzen',
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}