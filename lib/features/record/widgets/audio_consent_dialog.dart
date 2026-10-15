// lib/features/record/widgets/audio_consent_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

Future<bool> showAudioConsentDialog(BuildContext context) async {
  bool isAgreed = false;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                width: 1.1,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Einwilligung & Schutz',
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Damit deine persönliche Audio-Story von passenden Teams und Partnern im wertebasierten Resonanzabgleich gehört werden kann, verarbeiten wir deine Aufnahme verschlüsselt nach strengen DSGVO-Vorgaben.',
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StoryJobTheme.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: isAgreed,
                          activeColor: StoryJobTheme.cyanAccent,
                          checkColor: StoryJobTheme.backgroundBase,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: const BorderSide(color: StoryJobTheme.cardBorder, width: 1.4),
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              isAgreed = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ich stimme der Aufzeichnung und Speicherung meiner Stimme zu. Ich kann diese Freigabe jederzeit in meinen Einstellungen widerrufen und die Audioaufnahme unwiderruflich löschen.',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAgreed ? StoryJobTheme.primaryViolet : StoryJobTheme.cardSurface,
                  foregroundColor: isAgreed ? Colors.white : StoryJobTheme.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isAgreed
                          ? StoryJobTheme.primaryViolet
                          : StoryJobTheme.cardBorder,
                    ),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: isAgreed
                    ? () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(dialogContext).pop(true);
                      }
                    : null,
                child: const Text(
                  'Zustimmen ✨',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
              ),
            ],
          );
        },
      );
    },
  ) ?? false;
}