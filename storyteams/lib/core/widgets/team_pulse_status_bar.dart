// lib/core/widgets/team_pulse_status_bar.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';

class TeamPulseStatusBar extends StatelessWidget {
  final VoidCallback onAddPulseTap;

  const TeamPulseStatusBar({
    super.key,
    required this.onAddPulseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            '24H TEAM- & DNA-PULSE LIVE',
            style: TextStyle(
              color: StoryJobTheme.cyanAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
        ),
        SizedBox(
          height: 86,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pulse_statuses')
                .orderBy('createdAt', descending: true)
                .limit(12)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddPulseCircle();
                  }
                  final raw = docs[index - 1].data();
                  final data = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
                  return _buildPulseItem(context, data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPulseCircle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onAddPulseTap();
      },
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StoryJobTheme.cardSurfaceElevated,
                    border: Border.all(
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 25,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cyanAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: StoryJobTheme.backgroundBase, width: 2),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.black, size: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Team-Impuls',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseItem(BuildContext context, Map<String, dynamic> data) {
    final String name = data['name']?.toString() ?? 'Team';
    final String badge = data['ecosystemBadge']?.toString() ?? 'StoryJob Teams';
    final String message = data['message']?.toString() ?? '';
    final bool isDna = badge.contains('DNA');
    final Color ringColor = isDna ? StoryJobTheme.pinkMagenta : StoryJobTheme.cyanAccent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: ringColor.withValues(alpha: 0.45)),
            ),
            title: Text(
              '$name • $badge',
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Schließen', style: TextStyle(color: ringColor)),
              ),
            ],
          ),
        );
      },
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [ringColor, StoryJobTheme.primaryViolet],
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'T',
                    style: TextStyle(
                      color: ringColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}