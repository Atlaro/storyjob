// lib/features/match/widgets/story_resonance_match_bridge.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class StoryResonanceMatchBridge extends StatelessWidget {
  final String userName;
  final String companyName;
  final String matchScore;
  final Color userColor;
  final Color companyColor;
  final VoidCallback? onBridgeTap;

  const StoryResonanceMatchBridge({
    super.key,
    this.userName = 'Du',
    required this.companyName,
    this.matchScore = 'Hohe Resonanz ✨',
    this.userColor = StoryJobTheme.cyanAccent,
    this.companyColor = StoryJobTheme.primaryViolet,
    this.onBridgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayScore = matchScore.contains('%') || matchScore.contains('✨')
        ? matchScore
        : '$matchScore Wellenlänge';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. EIGENER POL (LINKS)
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        userColor.withValues(alpha: 0.25),
                        userColor.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: userColor, width: 1.6),
                    boxShadow: [
                      BoxShadow(
                        color: userColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'D',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'StoryJob DNA™',
                        style: TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. MITTLERE RESONANZ-BRÜCKE
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (onBridgeTap != null) {
                HapticFeedback.lightImpact();
                onBridgeTap!();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StoryJobTheme.backgroundBase,
                      border: Border.all(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/branding/app_icon_dark.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.graphic_eq_rounded,
                        color: StoryJobTheme.cyanAccent,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      displayScore,
                      style: const TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. TEAM- / PARTNER-POL (RECHTS)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                      const Text(
                        'Team & Kultur',
                        style: TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: companyColor.withValues(alpha: 0.18),
                    border: Border.all(color: companyColor, width: 1.6),
                    boxShadow: [
                      BoxShadow(
                        color: companyColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.groups_rounded, color: companyColor, size: 21),
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