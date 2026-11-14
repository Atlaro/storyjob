// lib/features/teams/screens/tabs/schedule_events_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _createEventDialog(BuildContext context) async {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: 'Freitag, 19:00 Uhr');
    final locCtrl = TextEditingController(
      text: team.location.isNotEmpty ? team.location : 'Gerätehaus / Vereinsheim',
    );
    final descCtrl = TextEditingController();
    String selectedCategory = 'Übung & Dienst';

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
            ),
            title: const Text(
              'Neuen Dienst / Termin anlegen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Titel (z. B. Gruppenübung Technische Hilfe)',
                      prefixIcon: Icon(Icons.event_note_rounded, size: 19),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: StoryJobTheme.cardSurfaceElevated,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.label_outline_rounded, size: 19),
                    ),
                    items: const [
                      'Übung & Dienst',
                      'Einsatz / Bereitschaft',
                      'Versammlung',
                      'Ausbildung',
                      'Vereins-Event',
                    ]
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Datum & Uhrzeit',
                      prefixIcon: Icon(Icons.schedule_rounded, size: 19),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Treffpunkt',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 19),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Kurze Zusatzinfo (optional)',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(color: StoryJobTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );

    if (created == true && titleCtrl.text.trim().isNotEmpty) {
      HapticFeedback.mediumImpact();
      await service.createTeamEvent(
        teamId: team.id,
        title: titleCtrl.text,
        category: selectedCategory,
        dateLabel: dateCtrl.text.trim().isEmpty ? 'Demnächst' : dateCtrl.text,
        location: locCtrl.text,
        description: descCtrl.text,
      );
    }

    titleCtrl.dispose();
    dateCtrl.dispose();
    locCtrl.dispose();
    descCtrl.dispose();
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
              label: const Text(
                'Termin',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: StoryJobTheme.amberEnergy,
                        size: 38,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Noch keine Dienste oder Übungen eingetragen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Leitung & Vorstand können über „+ Termin“ direkt Dienste mit Ein-Klick-Zusage planen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      if (myRole.darfVerwalten) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _createEventDialog(context),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Ersten Termin planen'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final raw = docs[i].data();
              final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
              final ev = TeamEvent.fromMap(map, docs[i].id);
              final bool accepted = ev.acceptedUids.contains(service.currentUid);
              final bool declined = ev.declinedUids.contains(service.currentUid);

              return GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                            border: Border.all(
                              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(
                            ev.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${ev.acceptedUids.length} dabei',
                          style: const TextStyle(
                            color: StoryJobTheme.mintSuccess,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ev.declinedUids.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${ev.declinedUids.length} abgesagt',
                            style: const TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ev.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${ev.dateLabel} • ${ev.location}',
                      style: const TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (ev.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        ev.description,
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              service.respondToEvent(
                                teamId: team.id,
                                eventId: ev.id,
                                accept: true,
                              );
                            },
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: Text(accepted ? 'Zugesagt ✓' : 'Zusagen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accepted
                                  ? StoryJobTheme.mintSuccess
                                  : StoryJobTheme.mintSuccess.withValues(alpha: 0.16),
                              foregroundColor:
                                  accepted ? Colors.black : StoryJobTheme.mintSuccess,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              service.respondToEvent(
                                teamId: team.id,
                                eventId: ev.id,
                                accept: false,
                              );
                            },
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: Text(declined ? 'Abgesagt' : 'Absagen'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: declined
                                  ? const Color(0xFFFCA5A5)
                                  : StoryJobTheme.textSecondary,
                              side: BorderSide(
                                color: declined
                                    ? Colors.redAccent
                                    : StoryJobTheme.cardBorder,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
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