// lib/core/widgets/storyjob_brand_header.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class StoryJobBrandHeader extends StatelessWidget {
  final bool isRecruiter;
  final String? customTitle;
  final String? customSubtitle;
  final Widget? trailing;

  const StoryJobBrandHeader({
    super.key,
    this.isRecruiter = false,
    this.customTitle,
    this.customSubtitle,
    this.trailing,
  });

  String _getUserGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    String userName = isRecruiter ? 'Unternehmen' : 'Talent';
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      userName = user.displayName!.trim().split(' ').first;
    }

    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Guten Morgen, $userName 👋';
    } else if (hour >= 12 && hour < 18) {
      return 'Guten Tag, $userName 👋';
    } else {
      return 'Guten Abend, $userName 🌙';
    }
  }

  String _getDefaultSubtitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return isRecruiter
          ? 'Bereit, heute echte Macher zu entdecken?'
          : 'Starte mit StoryJob™ in deinen Tag.';
    } else if (hour >= 12 && hour < 18) {
      return isRecruiter
          ? 'Finde heute die perfekten Werte-Matches für dein Team.'
          : 'Zeig der Arbeitswelt, was wirklich in dir steckt.';
    } else {
      return isRecruiter
          ? 'Lass den Tag mit neuen Resonanz-Pitches ausklingen.'
          : 'Entdecke neue Chancen auf Augenhöhe für morgen.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: StoryJobTheme.voiceGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'StoryJob™',
              style: TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 18),

        // Begrüßung / Custom Title
        Text(
          customTitle ?? _getUserGreeting(),
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle / Impuls
        Text(
          customSubtitle ?? _getDefaultSubtitle(),
          style: const TextStyle(
            color: StoryJobTheme.textSecondary,
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}