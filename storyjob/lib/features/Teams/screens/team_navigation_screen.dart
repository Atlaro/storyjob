// lib/features/Teams/screens/team_navigation_screen.dart
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/Teams/screens/team_dashboard_screen.dart';
import 'package:storyjob/features/Teams/screens/teams_dna_screen.dart';
import 'package:storyjob/features/Teams/screens/team_talent_pool_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        indicatorColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: StoryJobTheme.textSecondary),
            selectedIcon: Icon(Icons.dashboard_rounded, color: StoryJobTheme.cyanAccent),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded, color: StoryJobTheme.textSecondary),
            selectedIcon: Icon(Icons.people_rounded, color: StoryJobTheme.cyanAccent),
            label: 'Talent Pool',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined, color: StoryJobTheme.textSecondary),
            selectedIcon: Icon(Icons.tune_rounded, color: StoryJobTheme.cyanAccent),
            label: 'Team DNA',
          ),
        ],
      ),
    );
  }
}