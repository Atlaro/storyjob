import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/Teams/screens/team_dashboard_screen.dart';
import 'package:storyjob/features/Teams/screens/teams_dna_screen.dart';
import 'package:storyjob/features/Teams/screens/team_talent_pool_screen.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class TeamNavigationScreen extends StatefulWidget {
  const TeamNavigationScreen({super.key});

  @override
  State<TeamNavigationScreen> createState() => _TeamNavigationScreenState();
}

class _TeamNavigationScreenState extends State<TeamNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TeamDashboardScreen(),
    const TeamTalentPoolScreen(),
    const TeamsDnaScreen(),
  ];

  void _onFabPressed() {
    HapticFeedback.mediumImpact();
    // Aktion beim Klick auf das zentrale Plus-Symbol (z.B. Team-Impuls aufnehmen)
    showModalBottomSheet(
      context: context,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team-Story & Kultur-Impuls',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Präsentiere eure Werte direkt im Feed.',
                          style: TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryJobTheme.primaryViolet,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeamsDnaScreen()),
                  );
                },
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: const Text(
                  'Kultur-Impuls aufnehmen ✨',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: StoryJobTheme.cardSurfaceElevated,
          border: Border(top: BorderSide(color: StoryJobTheme.cardBorder, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
                _buildNavItem(1, Icons.people_rounded, 'Talent Pool'),
                // Zentrales Plus-Symbol im gleichen Stil wie bei der Talentseite
                GestureDetector(
                  onTap: _onFabPressed,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [StoryJobTheme.cyanAccent, StoryJobTheme.primaryViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  ),
                ),
                _buildNavItem(2, Icons.tune_rounded, 'Team DNA'),
                _buildNavItem(3, Icons.forum_rounded, 'Dialoge'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (index == 3) {
          // Öffnet direkt die Dialoge/Nachrichten
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const StoryDialogScreen(
                chatId: 'team_dialogs',
                targetName: 'Team-Dialoge',
                roleContext: 'Aktive Gespräche mit Machern',
                matchScore: 'StoryJob Teams',
              ),
            ),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}