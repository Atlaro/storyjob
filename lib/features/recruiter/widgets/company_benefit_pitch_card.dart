// lib/features/recruiter/widgets/company_benefit_pitch_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/services/audio_service.dart';

class CompanyBenefitPitchCard extends StatefulWidget {
  final String companyName;
  final String culturalPitchTitle;
  final String audioDuration;
  final String? audioPitchUrl;
  final List<String> benefits;

  const CompanyBenefitPitchCard({
    super.key,
    required this.companyName,
    required this.culturalPitchTitle,
    required this.audioDuration,
    this.audioPitchUrl,
    required this.benefits,
  });

  @override
  State<CompanyBenefitPitchCard> createState() => _CompanyBenefitPitchCardState();
}

class _CompanyBenefitPitchCardState extends State<CompanyBenefitPitchCard> {
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
      setState(() => _isPlaying = false);
    } else {
      if (widget.audioPitchUrl != null && widget.audioPitchUrl!.isNotEmpty) {
        await AudioService.playAudio(widget.audioPitchUrl!);
        setState(() => _isPlaying = true);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Keine Audio-Story für dieses Team hinterlegt.',
              style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StoryJobTheme.cardSurfaceElevated,
            StoryJobTheme.primaryViolet.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isPlaying
              ? StoryJobTheme.cyanAccent.withValues(alpha: 0.65)
              : StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Unternehmen & Audio-Vibe Indikator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.companyName.toUpperCase(),
                style: const TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPlaying ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.audioDuration,
                      style: const TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kultureller Story Titel
          Text(
            widget.culturalPitchTitle,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Play/Pause Pill Button
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying
                    ? StoryJobTheme.cardSurface
                    : StoryJobTheme.primaryViolet,
                foregroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(
                  color: _isPlaying
                      ? StoryJobTheme.cyanAccent
                      : StoryJobTheme.primaryViolet,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: _toggleAudio,
              icon: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: _isPlaying ? StoryJobTheme.cyanAccent : Colors.white,
                size: 20,
              ),
              label: Text(
                _isPlaying ? 'Story pausieren' : 'Kultur & Werte erleben ✨',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _isPlaying ? StoryJobTheme.cyanAccent : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Gelebte Mehrwerte & Kultur
          const Text(
            'GELEBTE WERTE & MEHRWERTE:',
            style: TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.benefits.map((benefit) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: StoryJobTheme.emeraldGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      benefit,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}