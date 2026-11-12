// lib/features/teams/screens/tabs/team_dna_bridge_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';

class TeamDnaBridgeTab extends StatelessWidget {
  final TeamUnit team;
  final TeamRolle myRole;

  const TeamDnaBridgeTab({
    super.key,
    required this.team,
    required this.myRole,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            child: Column(
              children: [
                const Text(
                  'EINLADUNGSCODE FÜR NEUE MITGLIEDER',
                  style: TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  team.inviteCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deine aktuelle Rolle: ${myRole.titel}',
                  style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: team.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Einladungscode in die Zwischenablage kopiert ✨')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Code kopieren & teilen'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.fingerprint_rounded, color: StoryJobTheme.pinkMagenta, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'StoryJob DNA™ Kultur-Brücke',
                      style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  team.motto,
                  style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: team.cultureValues.map((val) {
                    return Chip(
                      label: Text(val, style: const TextStyle(color: StoryJobTheme.pinkMagenta, fontSize: 12)),
                      backgroundColor: StoryJobTheme.pinkMagenta.withValues(alpha: 0.14),
                      side: BorderSide(color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.4)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}