// lib/features/profile/widgets/story_dna_web_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class StoryDnaWebView extends StatelessWidget {
  final String profileId;

  const StoryDnaWebView({
    super.key,
    required this.profileId,
  });

  void _shareProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    final cleanHandle = profileId.replaceAll('@', '');
    final url = 'https://storyjob.de/@$cleanHandle';

    Clipboard.setData(ClipboardData(text: url));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profil-Link $url in Zwischenablage kopiert ✨',
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: StoryJobTheme.cardBorder),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanHandle = profileId.replaceAll('@', '');
    final profileUrl = 'https://storyjob.de/@$cleanHandle';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '@$cleanHandle • StoryJob DNA™',
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: StoryJobTheme.cyanAccent),
            tooltip: 'Profil teilen',
            onPressed: () => _shareProfile(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: StoryJobTheme.brandGradient,
                    boxShadow: [
                      BoxShadow(
                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Öffentliche StoryJob DNA™ von @$cleanHandle',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profileUrl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Dieses Profil ist öffentlich abrufbar. Teams, Initiativen und Gleichgesinnte können deine Audio-Story und Wertebasis direkt im Browser erleben – ohne Lebenslauf und ohne Barrieren.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryJobTheme.primaryViolet,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => _shareProfile(context),
                    icon: const Icon(Icons.copy_rounded, size: 17),
                    label: const Text(
                      'Profil-Link kopieren ✨',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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