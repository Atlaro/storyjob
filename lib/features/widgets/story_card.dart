import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';
import '../models/story_model.dart';

class StoryCard extends StatefulWidget {
  final StoryModel story;
  const StoryCard({super.key, required this.story});

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  late final AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
          isLoading = state == PlayerState.paused || state == PlayerState.stopped ? false : isLoading;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => isLoading = true);
        await _audioPlayer.play(UrlSource(widget.story.audioUrl));
        setState(() => isLoading = false);
        
        // Play-Counter in Firestore erhöhen
        AppServices.incrementPlays(widget.story.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler bei der Audio-Wiedergabe.')),
        );
      }
    }
  }

  @ValueOfLikeButton()
  void _handleLike() {
    AppServices.incrementLikes(widget.story.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: StoryJobTheme.primaryViolet,
                backgroundImage: widget.story.userAvatarUrl.isNotEmpty
                    ? NetworkImage(widget.story.userAvatarUrl)
                    : null,
                child: widget.story.userAvatarUrl.isEmpty
                    ? Text(widget.story.userName[0], style: const TextStyle(color: Colors.white))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.userName,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.story.category,
                      style: const TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: StoryJobTheme.textSecondary),
                onPressed: _handleLike,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Audio Player Control Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: isLoading ? null : _togglePlay,
                  icon: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: StoryJobTheme.cyanAccent),
                        )
                      : Icon(
                          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: StoryJobTheme.cyanAccent,
                          size: 36,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isPlaying ? 'Wiedergabe läuft...' : 'Audio-Story anhören (${widget.story.durationSeconds}s)',
                    style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                  ),
                ),
                Text(
                  '${widget.story.playsCount} Plays',
                  style: const TextStyle(color: StoryJobTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy Annotation Marker helper
class ValueOfLikeButton extends Metadata {
  const ValueOfLikeButton();
}