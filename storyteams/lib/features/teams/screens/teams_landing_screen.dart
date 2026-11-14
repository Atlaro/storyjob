// lib/features/teams/screens/team_hub_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';
import 'package:storyteams/features/teams/screens/tabs/roster_pulse_tab.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class TeamHubScreen extends StatefulWidget {
  final String teamId;
  final List<String> userDnaValues;

  const TeamHubScreen({
    super.key,
    required this.teamId,
    this.userDnaValues = const [],
  });

  @override
  State<TeamHubScreen> createState() => _TeamHubScreenState();
}

class _TeamHubScreenState extends State<TeamHubScreen> {
  final TeamsFirestoreService _service = TeamsFirestoreService();

  Future<void> _showCreateEventDialog(TeamUnit team) async {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: team.location);
    final descCtrl = TextEditingController();
    String selectedCategory = 'Übung';

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 22,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Neuen Team-Termin anlegen',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Titel (z. B. Monatsübung Technische Hilfeleistung)',
                        prefixIcon: Icon(Icons.event_note_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: StoryJobTheme.cardSurfaceElevated,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.label_outline_rounded, size: 20),
                      ),
                      items: const ['Übung', 'Dienst', 'Einsatz', 'Versammlung', 'Event']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dateCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Wann? (z. B. Do., 19. Nov • 19:30 Uhr)',
                        prefixIcon: Icon(Icons.schedule_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ort / Treffpunkt',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Kurze Info für das Team (optional)',
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Termin veröffentlichen'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created == true && titleCtrl.text.trim().isNotEmpty) {
      await _service.createTeamEvent(
        teamId: team.id,
        title: titleCtrl.text,
        category: selectedCategory,
        dateLabel: dateCtrl.text.trim().isEmpty ? 'Demnächst' : dateCtrl.text,
        location: locationCtrl.text,
        description: descCtrl.text,
      );
    }

    titleCtrl.dispose();
    dateCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _showEditCultureDialog(TeamUnit team) async {
    final mottoCtrl = TextEditingController(text: team.motto);
    final storyCtrl = TextEditingController(text: team.teamStory);
    final valuesCtrl = TextEditingController(text: team.cultureValues.join(', '));

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 22,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Team-Kultur & DNA bearbeiten',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: mottoCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Leitsatz / Motto',
                  prefixIcon: Icon(Icons.format_quote_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valuesCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Kultur-Werte (kommagetrennt)',
                  prefixIcon: Icon(Icons.favorite_border_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storyCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Eure Team-Story: Wer seid ihr und wer passt zu euch?',
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Änderungen speichern'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      final parsedValues = valuesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _service.updateTeamCulture(
        teamId: team.id,
        motto: mottoCtrl.text,
        teamStory: storyCtrl.text,
        cultureValues: parsedValues,
      );
    }

    mottoCtrl.dispose();
    storyCtrl.dispose();
    valuesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _service.currentUid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').doc(widget.teamId).snapshots(),
      builder: (context, teamSnap) {
        if (!teamSnap.hasData) {
          return const Scaffold(
            backgroundColor: StoryJobTheme.bg0,
            body: Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent)),
          );
        }

        final team = TeamUnit.fromFirestore(teamSnap.data!);

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.teamId)
              .collection('members')
              .doc(currentUid)
              .snapshots(),
          builder: (context, memberSnap) {
            final rawMember = memberSnap.data?.data();
            final memberMap =
                (rawMember is Map<String, dynamic>) ? rawMember : <String, dynamic>{};

            TeamRolle myRole = TeamRolleInfo.fromKey(memberMap['role']?.toString());
            if (team.leaderUid == currentUid) {
              myRole = TeamRolle.leitung;
            }

            return DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: StoryJobTheme.bg0,
                appBar: AppBar(
                  backgroundColor: StoryJobTheme.bg0,
                  titleSpacing: 0,
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          team.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (team.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: StoryJobTheme.goldAccent,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    if (team.inviteCode.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: team.inviteCode));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: StoryJobTheme.cardSurfaceElevated,
                              content: Text('Einladungscode "${team.inviteCode}" kopiert!'),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: StoryJobTheme.goldAccent.withValues(alpha: 0.14),
                            border: Border.all(
                              color: StoryJobTheme.goldAccent.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.copy_rounded,
                                  size: 13, color: StoryJobTheme.goldAccent),
                              const SizedBox(width: 5),
                              Text(
                                team.inviteCode,
                                style: const TextStyle(
                                  color: StoryJobTheme.goldAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  bottom: const TabBar(
                    indicatorColor: StoryJobTheme.cyanAccent,
                    labelColor: StoryJobTheme.cyanAccent,
                    unselectedLabelColor: StoryJobTheme.textSecondary,
                    labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: [
                      Tab(text: 'Roster & Pulse'),
                      Tab(text: 'Dienstplan'),
                      Tab(text: 'Kultur & DNA'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    // Tab 1: Roster & Pulse
                    RosterPulseTab(
                      team: team,
                      myRole: myRole,
                      service: _service,
                    ),

                    // Tab 2: Dienstplan & Termine
                    _buildEventsTab(team, myRole, currentUid),

                    // Tab 3: Kultur, Team-Story & DNA-Abgleich
                    _buildCultureTab(team, myRole),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventsTab(TeamUnit team, TeamRolle myRole, String currentUid) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_available_rounded,
                            color: StoryJobTheme.cyanAccent, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Noch keine Termine eingetragen',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Plane hier Übungen, Dienste, Versammlungen oder Einsätze mit direkter Rückmeldung der Mannschaft.',
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
                            onPressed: () => _showCreateEventDialog(team),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Ersten Termin erstellen'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final raw = docs[index].data();
                final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
                final event = TeamEvent.fromMap(map, docs[index].id);
                final isAccepted = event.acceptedUids.contains(currentUid);
                final isDeclined = event.declinedUids.contains(currentUid);

                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.22),
                              border: Border.all(
                                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              event.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${event.acceptedCount} Zusagen',
                            style: const TextStyle(
                              color: StoryJobTheme.mintSuccess,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${event.dateLabel} • ${event.location}',
                        style: const TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          event.description,
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
                                _service.respondToEvent(
                                  teamId: team.id,
                                  eventId: event.id,
                                  accept: true,
                                );
                              },
                              icon: const Icon(Icons.check_rounded, size: 17),
                              label: const Text('Dabei'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAccepted
                                    ? StoryJobTheme.mintSuccess
                                    : StoryJobTheme.cardSurfaceElevated,
                                foregroundColor: isAccepted ? Colors.black : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _service.respondToEvent(
                                  teamId: team.id,
                                  eventId: event.id,
                                  accept: false,
                                );
                              },
                              icon: const Icon(Icons.close_rounded, size: 17),
                              label: const Text('Verhindert'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDeclined
                                    ? const Color(0xFFFCA5A5)
                                    : StoryJobTheme.textSecondary,
                                side: BorderSide(
                                  color: isDeclined
                                      ? Colors.redAccent
                                      : StoryJobTheme.cardBorder,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
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
        if (myRole.darfVerwalten)
          Positioned(
            right: 18,
            bottom: 18,
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateEventDialog(team),
              backgroundColor: StoryJobTheme.cyanAccent,
              foregroundColor: StoryJobTheme.bg0,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Termin', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }

  Widget _buildCultureTab(TeamUnit team, TeamRolle myRole) {
    final dnaMatch = team.calculateDnaMatchPercent(widget.userDnaValues);
    final sharedValues = team.findSharedValues(widget.userDnaValues);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: StoryJobTheme.cyanAccent, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Werte- & Kultur-Resonanz',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                      ),
                      child: Text(
                        '$dnaMatch% Match',
                        style: const TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  team.motto,
                  style: const TextStyle(
                    color: StoryJobTheme.goldAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (team.teamStory.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    team.teamStory,
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'UNSERE TEAM-WERTE',
                  style: TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: team.cultureValues.map((v) {
                    final isShared = sharedValues
                        .any((s) => s.toLowerCase() == v.trim().toLowerCase());
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isShared
                            ? StoryJobTheme.cyanAccent.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.06),
                        border: Border.all(
                          color: isShared
                              ? StoryJobTheme.cyanAccent
                              : StoryJobTheme.cardBorder,
                        ),
                      ),
                      child: Text(
                        isShared ? '✓ $v' : v,
                        style: TextStyle(
                          color: isShared ? StoryJobTheme.cyanAccent : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (myRole.darfVerwalten) ...[
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => _showEditCultureDialog(team),
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Kultur & Werte bearbeiten'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}