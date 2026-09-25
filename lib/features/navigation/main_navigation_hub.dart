import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/storyjob_theme.dart';
import '../feed/screens/stories_feed_screen.dart';
import '../match/screens/story_match_screen.dart';
import '../record/screens/record_story_screen.dart';
import '../messages/screens/nachrichten_screen.dart';
import '../profile/screens/my_story_screen.dart';

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => MainNavigationHubState();
}

class MainNavigationHubState extends State<MainNavigationHub> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const StoriesFeedScreen(),
      const StoryMatchScreen(),
      const RecordStoryScreen(),
      const NachrichtenScreen(),
      const MyStoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0810).withValues(alpha: 0.96),
          border: const Border(
            top: BorderSide(color: StoryJobTheme.cardBorder, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.auto_awesome_motion_outlined, Icons.auto_awesome_motion_rounded, 'Stories'),
              _buildNavItem(1, Icons.people_outline_rounded, Icons.people_alt_rounded, 'StoryMatch'),
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [StoryJobTheme.neonPink, StoryJobTheme.primaryViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedIndex == 2 ? StoryJobTheme.neonPink : StoryJobTheme.primaryViolet).withValues(alpha: 0.6),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              _buildNavItem(3, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Nachrichten'),
              _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Meine Story'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconUnselected, IconData iconSelected, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? iconSelected : iconUnselected,
            color: isSelected ? StoryJobTheme.primaryViolet : StoryJobTheme.textMuted,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}