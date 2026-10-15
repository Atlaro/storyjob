// lib/features/match/widgets/match_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class MatchCard extends StatefulWidget {
  final String displayName;
  final String role;
  final String location;
  final double matchScore;
  final List<String> interests;
  final List<String> sharedValues;
  final List<String> sharedCommunities;
  final String? resonanceReason;
  final String? audioSnippetUrl;
  final String? audioSnippetDuration;
  final VoidCallback onConnectPressed;

  const MatchCard({
    super.key,
    required this.displayName,
    required this.role,
    required this.location,
    required this.matchScore,
    required this.interests,
    this.sharedValues = const [],
    this.sharedCommunities = const [],
    this.resonanceReason,
    this.audioSnippetUrl,
    this.audioSnippetDuration,
    required this.onConnectPressed,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _isPlayingAudio = false;

  Future<void> _toggleAudio() async {
    HapticFeedback.lightImpact();
    if (_isPlayingAudio) {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlayingAudio = false);
    } else {
      if (widget.audioSnippetUrl != null && widget.audioSnippetUrl!.isNotEmpty) {
        await AudioService.playAudio(widget.audioSnippetUrl!);
      }
      if (mounted) setState(() => _isPlayingAudio = true);
    }
  }

  @override
  void dispose() {
    if (_isPlayingAudio) {
      AudioService.stopAudio();
    }
    super.dispose();
  }

  String _getResonanceLabel(double score) {
    if (score >= 88) return 'Hohe Resonanz ✨';
    if (score >= 70) return 'Starke Wellenlänge';
    return 'Werte-Einklang';
  }

  @override
  Widget build(BuildContext context) {
    final resonanceLabel = _getResonanceLabel(widget.matchScore);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isPlayingAudio
              ? StoryJobTheme.cyanAccent.withValues(alpha: 0.45)
              : StoryJobTheme.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Avatar & Resonanz-Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.18),
                        border: Border.all(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.40),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.displayName.isNotEmpty
                            ? widget.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: StoryJobTheme.primaryViolet,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.displayName,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.role} • ${widget.location}',
                            style: const TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  resonanceLabel,
                  style: const TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),

          // Resonanz-Begründung
          if (widget.resonanceReason != null && widget.resonanceReason!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: StoryJobTheme.primaryViolet,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.resonanceReason!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StoryJobTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Audio Spark Schnell-Player (optional)
          if (widget.audioSnippetUrl != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _toggleAudio,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: _isPlayingAudio
                      ? StoryJobTheme.cyanAccent.withValues(alpha: 0.12)
                      : StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isPlayingAudio
                        ? StoryJobTheme.cyanAccent.withValues(alpha: 0.40)
                        : StoryJobTheme.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isPlayingAudio ? 'Audio-Spark läuft...' : 'Audio-DNA anhören',
                        style: TextStyle(
                          color: _isPlayingAudio ? StoryJobTheme.cyanAccent : StoryJobTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      widget.audioSnippetDuration ?? '0:30',
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Geteilte Werte, Initiativen & Interessen Pills
          if (widget.sharedValues.isNotEmpty ||
              widget.sharedCommunities.isNotEmpty ||
              widget.interests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...widget.sharedValues.map((val) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.champagneGold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: StoryJobTheme.champagneGold.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, size: 12, color: StoryJobTheme.champagneGold),
                          const SizedBox(width: 4),
                          Text(
                            val,
                            style: const TextStyle(
                              fontSize: 11,
                              color: StoryJobTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                ...widget.sharedCommunities.map((comm) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.emeraldGreen.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: StoryJobTheme.emeraldGreen.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.volunteer_activism_rounded, size: 11, color: StoryJobTheme.emeraldGreen),
                          const SizedBox(width: 4),
                          Text(
                            comm,
                            style: const TextStyle(
                              fontSize: 11,
                              color: StoryJobTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                ...widget.interests.map((interest) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(fontSize: 11, color: StoryJobTheme.textSecondary),
                      ),
                    )),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Pill CTA Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryJobTheme.primaryViolet,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onConnectPressed();
              },
              icon: const Icon(Icons.forum_rounded, size: 16),
              label: const Text(
                'Dialog starten ✨',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}