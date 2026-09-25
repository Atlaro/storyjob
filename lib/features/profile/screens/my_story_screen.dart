import 'package:flutter/material.dart';
import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';

class MyStoryScreen extends StatelessWidget {
  const MyStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Story & Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: StoryJobTheme.primaryViolet,
                child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dein Profil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: StoryJobTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hier verwaltest du deine Voice Stories und deine persönlichen Engagement-Chips.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: StoryJobTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Engagement & Werte',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StoryJobTheme.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('🌱 Nachhaltigkeit & PV'),
                      _buildChip('🛠️ Handwerk & Technik'),
                      _buildChip('🤝 Teamplayer'),
                      _buildChip('💡 Problemlöser'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await AppServices.signOut();
                },
                child: const Text('Abmelden', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: StoryJobTheme.cyanAccent, fontSize: 12)),
      backgroundColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: StoryJobTheme.cardBorder),
      ),
    );
  }
}