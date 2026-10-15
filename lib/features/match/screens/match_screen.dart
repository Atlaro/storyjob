// lib/features/match/screens/match_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class StoryMatchDetailScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const StoryMatchDetailScreen({
    super.key,
    required this.matchData,
  });

  @override
  State<StoryMatchDetailScreen> createState() => _StoryMatchDetailScreenState();
}

class _StoryMatchDetailScreenState extends State<StoryMatchDetailScreen> {
  bool _isPlaying = false;
  bool _isBookmarked = false;

  Future<void> _toggleAudio() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      final audioUrl = widget.matchData['audioUrl'] as String?;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await AudioService.playAudio(audioUrl);
      }
      if (mounted) setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    AudioService.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final company = widget.matchData['company'] as String? ?? 'Team / Initiative';
    final role = widget.matchData['role'] as String? ?? 'Wirkungsfeld';
    final resonanceLevel = widget.matchData['matchScore'] != null
        ? 'Hohe Werte-Resonanz ✨'
        : 'Starke Wellenlänge';
    final resonanceReason = widget.matchData['resonanceReason'] as String? ??
        'Geteilte Grundhaltungen, Verlässlichkeit und ein Miteinander auf Augenhöhe.';
    final resonancePillars = widget.matchData['resonancePillars'] as List<String>? ?? [];
    final cultureAudioSnippet = widget.matchData['cultureAudioSnippet'] as String? ??
        '„Hör dir unseren Gründer-Impuls zu Vertrauen & Freiraum an...“';
    final cultureAudioDuration = widget.matchData['cultureAudioDuration'] as String? ?? '0:35';
    final benefits = widget.matchData['benefits'] as List<String>? ?? [];
    final location = widget.matchData['location'] as String? ?? 'Region';
    final isRemote = widget.matchData['isRemote'] as bool? ?? false;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          company,
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: _isBookmarked ? StoryJobTheme.champagneGold : StoryJobTheme.textMuted,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isBookmarked = !_isBookmarked);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header-Kachel mit Resonanz-Badge & Rolle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.40),
                            ),
                          ),
                          child: Text(
                            resonanceLevel,
                            style: const TextStyle(
                              color: StoryJobTheme.primaryViolet,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isRemote)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: StoryJobTheme.cardBorder),
                            ),
                            child: const Text(
                              'Flexibel / Vor Ort',
                              style: TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: StoryJobTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$company  •  $location',
                      style: const TextStyle(
                        fontSize: 13,
                        color: StoryJobTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Resonanz & Kultur-Begründung
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: StoryJobTheme.primaryViolet,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'WARUM ES MENSCHLICH PASST',
                          style: TextStyle(
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.95),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      resonanceReason,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: StoryJobTheme.textPrimary,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (resonancePillars.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: resonancePillars.map((pillar) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: StoryJobTheme.cyanAccent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  pillar,
                                  style: const TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Audio-Pitch & Team-Kultur
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _isPlaying
                        ? StoryJobTheme.cyanAccent.withValues(alpha: 0.45)
                        : StoryJobTheme.cardBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.graphic_eq_rounded,
                              size: 15,
                              color: StoryJobTheme.cyanAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TEAM-AUDIO SPARK',
                              style: TextStyle(
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.95),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          cultureAudioDuration,
                          style: const TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _toggleAudio,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isPlaying
                              ? StoryJobTheme.cyanAccent.withValues(alpha: 0.12)
                              : StoryJobTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isPlaying
                                ? StoryJobTheme.cyanAccent.withValues(alpha: 0.4)
                                : StoryJobTheme.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: StoryJobTheme.cyanAccent,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cultureAudioSnippet,
                                style: TextStyle(
                                  color: _isPlaying
                                      ? StoryJobTheme.cyanAccent
                                      : StoryJobTheme.textPrimary,
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Rahmenbedingungen & Werte
              if (benefits.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: StoryJobTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rahmenbedingungen & Werte',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: StoryJobTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: benefits.map((benefit) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: StoryJobTheme.cardBorder),
                            ),
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: StoryJobTheme.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // 5. Primäre Aktion: Dialog starten
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final cleanChatId =
                        'chat_${company.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_')}';

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryDialogScreen(
                          chatId: cleanChatId,
                          targetName: company,
                          roleContext: role,
                          matchScore: '92%',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.forum_rounded, size: 16),
                  label: const Text(
                    'Dialog starten & Kennenlernen',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}