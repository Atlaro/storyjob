// lib/features/teams/screens/tabs/schedule_events_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class ScheduleEventsTab extends StatelessWidget {
  final TeamUnit team;
  final TeamRolle myRole;
  final TeamsFirestoreService service;

  const ScheduleEventsTab({
    super.key,
    required this.team,
    required this.myRole,
    required this.service,
  });

  void _createEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: 'Freitag, 19:00 Uhr');
    final locCtrl = TextEditingController(text: 'Gerätehaus / Vereinsheim');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Neuen Dienst / Termin anlegen', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Titel (z. B. Gruppenübung Technische Hilfe)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Datum & Uhrzeit'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Treffpunkt'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              await FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team.id)
                  .collection('events')
                  .add({
                'title': titleCtrl.text.trim(),
                'category': 'Übung & Dienst',
                'dateLabel': dateCtrl.text.trim(),
                'location': locCtrl.text.trim(),
                'acceptedUids': [service.currentUid],
                'declinedUids': <String>[],
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: myRole.darfVerwalten
          ? FloatingActionButton.extended(
              backgroundColor: StoryJobTheme.primaryViolet,
              foregroundColor: Colors.white,
              onPressed: () => _createEventDialog(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Termin'),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teams')
            .doc(team.id)
            .collection('events')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.event_available_rounded, color: StoryJobTheme.amberEnergy, size: 36),
                      SizedBox(height: 10),
                      Text(
                        'Noch keine Dienste oder Übungen eingetragen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Leitung & Vorstand können über „+ Termin“ direkt Dienste mit Ein-Klick-Zusage planen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final raw = docs[i].data();
              final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
              final ev = TeamEvent.fromMap(map, docs[i].id);
              final bool accepted = ev.acceptedUids.contains(service.currentUid);

              return GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ev.title,
                          style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${ev.acceptedUids.length} dabei',
                          style: const TextStyle(
                            color: StoryJobTheme.mintSuccess,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${ev.dateLabel} • ${ev.location}',
                      style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              docs[i].reference.update({
                                'acceptedUids': FieldValue.arrayUnion([service.currentUid]),
                                'declinedUids': FieldValue.arrayRemove([service.currentUid]),
                              });
                            },
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(accepted ? 'Zugesagt ✓' : 'Zusagen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accepted
                                  ? StoryJobTheme.mintSuccess
                                  : StoryJobTheme.mintSuccess.withValues(alpha: 0.16),
                              foregroundColor: accepted ? Colors.black : StoryJobTheme.mintSuccess,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              docs[i].reference.update({
                                'declinedUids': FieldValue.arrayUnion([service.currentUid]),
                                'acceptedUids': FieldValue.arrayRemove([service.currentUid]),
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Absagen'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}