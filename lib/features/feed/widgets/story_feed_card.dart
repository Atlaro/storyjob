// lib/features/feed/widgets/story_feed_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';

class StoryFeedCard extends StatefulWidget {
  final String name;
  final String roleContext;
  final String voiceDuration;
  final String? audioUrl;
  final List<String> highlights;
  final Color avatarColor;
  final String? avatarUrl;
  final int playsCount;
  final int likesCount;
  final VoidCallback onResonanceTap;

  const StoryFeedCard({
    super.key,
    required this.name,
    required this.roleContext,
    required this.voiceDuration,
    this.audioUrl,
    required this.highlights,
    required this.avatarColor,
    this.avatarUrl,
    this.playsCount = 0,
    this.likesCount = 0,
    required this.onResonanceTap,
  });

  @override
  State<StoryFeedCard> createState() => _StoryFeedCardState();
}

class _StoryFeedCardState extends State<StoryFeedCard> {
  bool _isPlaying = false;

  @override
  void dispose() {
    if (_isPlaying) {
      AudioService.stopAudio();
    }
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
        await AudioService.playAudio(widget.audioUrl!);
        if (mounted) setState(() => _isPlaying = true);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Audio-Vorschau für ${widget.name} wird geladen...',
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 12.5,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      borderGradient: StoryJobTheme.dnaCardBorder,
      hasNeonGlow: _isPlaying,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil-Header: Avatar, Name & Rolle
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.avatarColor.withValues(alpha: 0.16),
                  border: Border.all(
                    color: widget.avatarColor.withValues(alpha: 0.55),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.avatarColor.withValues(alpha: 0.20),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
                        ),
                      )
                    : _buildFallbackAvatar(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StoryJobTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.roleContext,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StoryJobTheme.cyanAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.likesCount > 0 ? '${widget.likesCount} Impulse' : 'Werte-Fit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: StoryJobTheme.cyanAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Audio-Story Kapsel mit Soundwave
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _toggleAudio,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: _isPlaying
                    ? StoryJobTheme.cyanAccent.withValues(alpha: 0.12)
                    : StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPlaying
                      ? StoryJobTheme.cyanAccent.withValues(alpha: 0.55)
                      : StoryJobTheme.cardBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying
                          ? StoryJobTheme.cyanAccent
                          : StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: _isPlaying ? Colors.black : StoryJobTheme.cyanAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          StoryJobTheme.soundWaveGradient.createShader(bounds),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(18, (index) {
                          const heights = [
                            8, 14, 22, 12, 26, 18, 10, 24, 16, 20, 12, 18, 24, 14, 10, 16, 12, 8
                          ];
                          final double h = _isPlaying
                              ? heights[index % heights.length].toDouble()
                              : (heights[index % heights.length] * 0.65).toDouble();
                          return Container(
                            width: 2.5,
                            height: h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isPlaying ? 'Läuft...' : widget.voiceDuration,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _isPlaying
                          ? StoryJobTheme.cyanAccent
                          : StoryJobTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Werte-Highlights / Tags
          if (widget.highlights.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.highlights.map((highlight) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    highlight,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: StoryJobTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Dialog-Aktion (Pill-Button)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onResonanceTap();
              },
              icon: const Icon(
                Icons.forum_rounded,
                size: 15,
                color: Colors.white,
              ),
              label: const Text(
                'Story vertiefen & Dialog starten ✨',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryJobTheme.primaryViolet,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Center(
      child: Text(
        widget.name.isNotEmpty ? widget.name.substring(0, 1).toUpperCase() : 'S',
        style: TextStyle(
          color: widget.avatarColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}