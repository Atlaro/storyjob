import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';

class StoryMatchScreen extends StatefulWidget {
  const StoryMatchScreen({super.key});

  @override
  State<StoryMatchScreen> createState() => _StoryMatchScreenState();
}

class _StoryMatchScreenState extends State<StoryMatchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUid = AppServices.auth.currentUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryMatch', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Suche nach Werten, Interessen oder Region...',
                prefixIcon: const Icon(Icons.search, color: StoryJobTheme.cyanAccent),
                filled: true,
                fillColor: StoryJobTheme.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.handshake_rounded, color: StoryJobTheme.cyanAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'StoryMatching basiert auf Engagement, Werten, Interessen und Gemeinschaften.',
                      style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 18),
                SizedBox(width: 8),
                Text(
                  'Transparente StoryMatches',
                  style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: AppServices.db.collection('profiles').snapshots(),
              builder: (context, snapshot) {
                // WICHTIG: Muss im Web als allererstes stehen, um den TypeError abzufangen!
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Lade Profile...',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: StoryJobTheme.textSecondary, height: 1.5),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final filtered = docs.where((doc) {
                  if (doc.id == currentUid) return false;
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['displayName'] ?? '').toString().toLowerCase();
                  final role = (data['role'] ?? '').toString().toLowerCase();
                  final q = _searchQuery.toLowerCase();
                  return name.contains(q) || role.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Keine passenden Profile gefunden.', style: TextStyle(color: StoryJobTheme.textSecondary)),
                    ),
                  );
                }

                return Column(
                  children: filtered.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['displayName'] ?? 'Anonym';
                    final role = data['role'] ?? 'Talent';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: StoryJobTheme.primaryViolet,
                          child: Icon(Icons.person_rounded, color: Colors.white),
                        ),
                        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(role, style: const TextStyle(color: StoryJobTheme.textSecondary)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.emeraldGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '95% Match',
                            style: TextStyle(color: StoryJobTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}