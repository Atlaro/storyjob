// lib/features/teams/screens/teams_landing_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/auth/screens/teams_auth_screen.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/screens/teams_workspace_screen.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class TeamsLandingScreen extends StatefulWidget {
  const TeamsLandingScreen({super.key});

  @override
  State<TeamsLandingScreen> createState() => _TeamsLandingScreenState();
}

class _TeamsLandingScreenState extends State<TeamsLandingScreen> {
  final TeamsFirestoreService _service = TeamsFirestoreService();
  final TextEditingController _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _checkPendingInviteCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingInviteCode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final pending = doc.data()?['pendingInviteCode']?.toString() ?? '';
      if (pending.isNotEmpty && mounted) {
        _codeController.text = pending;
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'pendingInviteCode': FieldValue.delete()},
          SetOptions(merge: true),
        );
        await _joinByCode(pending);
      }
    } catch (_) {}
  }

  Future<void> _openTeam(String teamId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'activeTeamId': teamId},
        SetOptions(merge: true),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TeamsWorkspaceScreen(teamId: teamId)),
    );
  }

  Future<void> _joinByCode([String? explicitCode]) async {
    final code = (explicitCode ?? _codeController.text).trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('teams')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            content: Text('Kein Team mit diesem Einladungscode gefunden.'),
          ),
        );
        return;
      }

      final teamDoc = snap.docs.first;
      final uid = _service.currentUid;
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamDoc.id)
          .collection('members')
          .doc(uid)
          .set({
        'uid': uid,
        'displayName': user?.displayName ?? 'Team-Mitglied',
        'role': 'mitglied',
        'status': 'bereit',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _openTeam(teamDoc.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Beitritt fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _showCreateTeamDialog() async {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final mottoCtrl = TextEditingController(text: 'Gemeinsam stark im Einsatz & Alltag');
    String selectedCategory = 'Ehrenamt & Blaulicht';

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                  'Neues Team gründen',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Team- oder Vereinsname',
                    prefixIcon: Icon(Icons.groups_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  dropdownColor: StoryJobTheme.cardSurfaceElevated,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  items: const [
                    'Ehrenamt & Blaulicht',
                    'Sport & Verein',
                    'Betrieb & Handwerk',
                    'Projekt & Initiative',
                  ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setModalState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Ort / Standort',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mottoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Team-Motto',
                    prefixIcon: Icon(Icons.format_quote_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Team erstellen & starten', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (created == true && nameCtrl.text.trim().isNotEmpty) {
      final uid = _service.currentUid;
      final user = FirebaseAuth.instance.currentUser;
      final inviteCode = 'SJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';

      final teamRef = await FirebaseFirestore.instance.collection('teams').add({
        'name': nameCtrl.text.trim(),
        'category': selectedCategory,
        'location': locationCtrl.text.trim().isEmpty ? 'Regional' : locationCtrl.text.trim(),
        'motto': mottoCtrl.text.trim(),
        'teamStory': '',
        'cultureValues': ['Verlässlichkeit', 'Teamgeist', 'Zusammenhalt'],
        'leaderUid': uid,
        'inviteCode': inviteCode,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await teamRef.collection('members').doc(uid).set({
        'uid': uid,
        'displayName': user?.displayName ?? 'Teamleitung',
        'role': 'leitung',
        'status': 'bereit',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      await _openTeam(teamRef.id);
    }

    nameCtrl.dispose();
    locationCtrl.dispose();
    mottoCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: StoryJobTheme.backgroundBase,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(text: 'StoryJob ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Teams', style: TextStyle(color: StoryJobTheme.cyanAccent)),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Abmelden',
            icon: const Icon(Icons.logout_rounded, color: StoryJobTheme.textSecondary),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TeamsAuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Per Einladungscode beitreten',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gib den Code deiner Einheit, deines Vereins oder Betriebs ein.',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'z. B. SJ-2026',
                            prefixIcon: Icon(Icons.vpn_key_outlined, size: 19),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isJoining ? null : () => _joinByCode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoryJobTheme.cyanAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        ),
                        child: Text(
                          _isJoining ? '...' : 'Beitreten',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showCreateTeamDialog();
              },
              icon: const Icon(Icons.add_circle_outline_rounded, color: StoryJobTheme.primaryViolet),
              label: const Text('Neues Team / neuen Verein anlegen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: StoryJobTheme.primaryViolet.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'VERFÜGBARE TEAMS & EINHEITEN',
              style: TextStyle(
                color: StoryJobTheme.cyanAccent,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('teams').limit(25).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Noch keine öffentlichen Teams vorhanden. Gründe oben dein erstes Team!',
                      style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final team = TeamUnit.fromFirestore(docs[index]);
                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () => _openTeam(team.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                              ),
                              child: const Icon(Icons.shield_rounded, color: StoryJobTheme.cyanAccent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    team.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${team.motto} • ${team.location}',
                                    style: const TextStyle(
                                      color: StoryJobTheme.textSecondary,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: StoryJobTheme.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}