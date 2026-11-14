// lib/features/record/widgets/story_format_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/record/screens/story_recording_screen.dart';
import 'package:storyjob/features/record/screens/video_recording_screen.dart';
import 'package:storyjob/features/record/widgets/audio_consent_dialog.dart';

class StoryFormatModal extends StatelessWidget {
  const StoryFormatModal({super.key});

  Future<void> _handleVoiceSelect(BuildContext context) async {
    HapticFeedback.lightImpact();
    Navigator.pop(context);

    // DSGVO-Einwilligung vor Aufnahmebeginn sicherstellen
    final bool hasConsent = await showAudioConsentDialog(context);
    if (!hasConsent || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoryRecordingScreen()),
    );
  }

  Future<void> _handleVideoSelect(BuildContext context) async {
    HapticFeedback.lightImpact();
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideoRecordingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: const Border(
              top: BorderSide(color: StoryJobTheme.cardBorder, width: 1.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                'Wähle dein Format',
                style: TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Teile deine Haltung und Story per Audio oder Video',
                style: TextStyle(
                  color: StoryJobTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Voice Story Button
              _SeamlessGlowActionButton(
                title: 'Audio-Story',
                subtitle: 'Echte Stimme & Wellenlänge spürbar machen.',
                assetPath: 'assets/branding/MIC_transparent.webp',
                glowColor: StoryJobTheme.cyanAccent,
                fallbackIcon: Icons.mic_rounded,
                onTap: () => _handleVoiceSelect(context),
              ),

              const SizedBox(height: 12),

              // 2. Video Story Button
              _SeamlessGlowActionButton(
                title: 'Video-Impuls',
                subtitle: 'Persönlichkeit, Werte & Miteinander zeigen.',
                assetPath: 'assets/branding/Design ohne Titel.png',
                glowColor: StoryJobTheme.primaryViolet,
                fallbackIcon: Icons.videocam_rounded,
                onTap: () => _handleVideoSelect(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeamlessGlowActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color glowColor;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _SeamlessGlowActionButton({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.glowColor,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: glowColor.withValues(alpha: 0.14),
        highlightColor: glowColor.withValues(alpha: 0.06),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: glowColor.withValues(alpha: 0.30),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            glowColor.withValues(alpha: 0.35),
                            glowColor.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          fallbackIcon,
                          color: glowColor,
                          size: 36,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: StoryJobTheme.textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}