// lib/features/navigation/widgets/birthday_pop_up_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';

class BirthdayPopUpDialog extends StatelessWidget {
  final String userName;

  const BirthdayPopUpDialog({
    super.key,
    required this.userName,
  });

  static Future<void> show(BuildContext context, {required String userName}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (BuildContext dialogContext) => BirthdayPopUpDialog(userName: userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    const champagneAccent = StoryJobTheme.champagneGold;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390),
        decoration: BoxDecoration(
          color: StoryJobTheme.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: champagneAccent.withValues(alpha: 0.45),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.28),
              blurRadius: 32,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: StoryJobTheme.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🎉',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Alles Gute zum Geburtstag,\n$userName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: champagneAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Wir wünschen dir ein erfülltes neues Lebensjahr, echte Resonanz und Raum für deine persönliche Entfaltung.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: champagneAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: champagneAccent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'Deine StoryJob DNA™',
                              style: TextStyle(
                                color: StoryJobTheme.cyanAccent,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'KEIN LEBENSLAUF.  •  KEINE NOTEN.\nNUR DEINE HALTUNG & WERTE.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: champagneAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🌱 Begegnungen auf Augenhöhe.\nEchter Impact & Zusammenhalt.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Danke & Story beginnen ✨',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: StoryJobTheme.textSecondary,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}