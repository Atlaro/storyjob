// lib/features/record/screens/story_success_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';
import 'package:storyjob/features/record/services/audio_upload_service.dart';

class StorySuccessScreen extends StatefulWidget {
  final String? userId;
  final String audioFilePath;
  final int durationSeconds;
  final bool isVideo;

  const StorySuccessScreen({
    super.key,
    this.userId,
    String? audioPath,
    String audioFilePath = '',
    this.durationSeconds = 45,
    this.isVideo = false,
  }) : audioFilePath = audioPath ?? audioFilePath;

  @override
  State<StorySuccessScreen> createState() => _StorySuccessScreenState();
}

class _StorySuccessScreenState extends State<StorySuccessScreen> {
  bool _isPublishing = false;

  String get _effectiveUserId =>
      widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  Future<void> _publishAndActivateMatch() async {
    setState(() => _isPublishing = true);
    HapticFeedback.lightImpact();

    bool success = true;
    if (widget.audioFilePath.isNotEmpty && File(widget.audioFilePath).existsSync()) {
      success = await AudioUploadService.publishVoiceStory(
        userId: _effectiveUserId,
        mediaFilePath: widget.audioFilePath,
        durationSeconds: widget.durationSeconds,
        isVideo: widget.isVideo,
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) return;

    setState(() => _isPublishing = false);

    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const TalentNavigationScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isVideo
                ? 'Fehler beim Hochladen des Videos. Bitte erneut versuchen.'
                : 'Fehler beim Aktivieren der Audio-Story. Bitte erneut versuchen.',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: StoryJobTheme.textPrimary),
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
  }

  void _returnHome() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const TalentNavigationScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color activeAccent = widget.isVideo ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;
    final String assetImage = widget.isVideo
        ? 'assets/branding/Design ohne Titel.png'
        : 'assets/branding/MIC_transparent.webp';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon / Visual
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StoryJobTheme.cardSurfaceElevated,
                      border: Border.all(
                        color: activeAccent.withValues(alpha: 0.40),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: activeAccent.withValues(alpha: 0.20),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        assetImage,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          widget.isVideo ? Icons.videocam_rounded : Icons.mic_rounded,
                          size: 38,
                          color: activeAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Headline & Beschreibung
                  Text(
                    widget.isVideo ? 'Video aufgenommen' : 'Audio-Story bereit',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.isVideo
                        ? 'Dein Video zeigt deine authentische Persönlichkeit. Aktiviere es jetzt für passende Teams und Projekte.'
                        : 'Deine Stimme macht den Unterschied. Aktiviere deine Story, um den wertebasierten Resonanzabgleich auf deiner Wellenlänge zu starten.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: StoryJobTheme.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Statuskarte
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: StoryJobTheme.cardBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeAccent.withValues(alpha: 0.14),
                          ),
                          child: Icon(Icons.verified_rounded, size: 18, color: activeAccent),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Bereit für Werte-Resonanz',
                                style: TextStyle(
                                  color: StoryJobTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Wird direkt für Begegnungen auf Augenhöhe freigeschaltet.',
                                style: TextStyle(
                                  color: StoryJobTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Haupt-Action Button (Pill)
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
                      onPressed: _isPublishing ? null : _publishAndActivateMatch,
                      child: _isPublishing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Story aktivieren & Resonanz starten ✨',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Überspringen
                  TextButton(
                    onPressed: _returnHome,
                    child: const Text(
                      'Später aktivieren',
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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