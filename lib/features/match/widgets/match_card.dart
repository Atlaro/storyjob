import 'package:flutter/material.dart';
import '../../../../core/theme/storyjob_theme.dart';
import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onConnectPressed;

  const MatchCard({
    super.key,
    required this.match,
    required this.onConnectPressed,
  });

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
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    child: Text(
                      match.displayName.isNotEmpty ? match.displayName[0] : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.displayName,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${match.role} • ${match.location}',
                        style: const TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: StoryJobTheme.emeraldGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${match.matchScore.toInt()}% Match',
                  style: const TextStyle(
                    color: StoryJobTheme.emeraldGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: match.interests.map((interest) {
              return Chip(
                label: Text(interest, style: const TextStyle(fontSize: 11, color: StoryJobTheme.textSecondary)),
                backgroundColor: StoryJobTheme.cardSurfaceLight,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryJobTheme.primaryViolet,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onConnectPressed,
              child: const Text('Anfragen / Chat starten', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}