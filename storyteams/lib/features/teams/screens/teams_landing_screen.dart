// lib/features/teams/screens/teams_landing_screen.dart
import 'package:flutter/material.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/teams/models/team_role.dart';
import 'package:storyteams/features/teams/screens/teams_workspace_screen.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class TeamsLandingScreen extends StatefulWidget {
  const TeamsLandingScreen({super.key});

  @override
  State<TeamsLandingScreen> createState() => _TeamsLandingScreenState();
}

class _TeamsLandingScreenState extends State<TeamsLandingScreen> {
  final TeamsFirestoreService _service = TeamsFirestoreService();

  void _showJoinDialog() {
    final codeController = TextEditingController();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Team beitreten', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: codeController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 4, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: 'z. B. HK9412', counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.length != 6) return;
              final teamId = await _service.joinTeamByCode(code);
              if (ctx.mounted) Navigator.pop(ctx);
              if (teamId != null) {
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => TeamsWorkspaceScreen(teamId: teamId)),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Kein Team mit diesem Einladungscode gefunden.')),
                );
              }
            },
            child: const Text('Beitreten'),
          ),
        ],
      ),
    );
  }

  void _showCreateTeamDialog() {
    final nameController = TextEditingController();
    final navigator = Navigator.of(context);
    String selectedType = 'Hilfsorganisation';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Neues Team gründen', style: TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'z. B. Feuerwehr Nord, Sportverein Aktiv oder Team Handwerk'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: StoryJobTheme.cardSurfaceElevated,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'Hilfsorganisation', child: Text('Feuerwehr & Hilfsorganisation')),
                  DropdownMenuItem(value: 'Verein', child: Text('Verein & Ehrenamt (Sport, Kultur)')),
                  DropdownMenuItem(value: 'Betrieb', child: Text('Betrieb / Gewerbe / Handwerk')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final teamId = await _service.createTeam(name: name, type: selectedType);
                if (ctx.mounted) Navigator.pop(ctx);
                if (teamId != null) {
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (_) => TeamsWorkspaceScreen(teamId: teamId)),
                  );
                }
              },
              child: const Text('Gründen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            children: [
              TextSpan(text: 'StoryJob ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Teams', style: TextStyle(color: StoryJobTheme.cyanAccent)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showJoinDialog,
            child: const Text('Code eingeben', style: TextStyle(color: StoryJobTheme.cyanAccent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                const Text(
                  'Echte Kameradschaft.\nKompakt organisiert.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Verein 2.0 für jedes Team ab 3 Personen: Ob Feuerwehr, Sportverein, Ehrenamt oder Betrieb – StoryJob Teams bündelt Sozialleben, Live-Verfügbarkeiten, Dienstpläne und Rollen vom Neuling bis zur Leitung.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: StoryJobTheme.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showCreateTeamDialog,
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Team erstellen (Leitung)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showJoinDialog,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Mit Einladungscode beitreten'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ...TeamRolle.values.map((rolle) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: rolle.darfVerwalten
                                  ? StoryJobTheme.primaryViolet.withValues(alpha: 0.25)
                                  : StoryJobTheme.cardSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              rolle.titel,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: rolle.darfVerwalten ? StoryJobTheme.cyanAccent : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              rolle.beschreibung,
                              style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}