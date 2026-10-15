// lib/features/navigation/onboarding/screens/modern_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({super.key});

  @override
  State<ModernOnboardingScreen> createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      title: 'Menschen sind mehr\nals ihr Lebenslauf.',
      subtitle: 'Lebensläufe zeigen nur Stationen.\nStoryJob macht deine Haltung und Persönlichkeit sichtbar.',
      badgeText: 'Mensch & Haltung ✨',
      imagePath: 'assets/onboarding/onboarding_person.webp',
    ),
    OnboardingPageData(
      title: 'Was dich antreibt,\nist dein wahrer Wert.',
      subtitle: 'Werte, Engagement, Ehrenamt & Macher-Mentalität.\nZeige das Fundament deines Handelns.',
      badgeText: 'Kultur & Ehrenamt 🤝',
      imagePath: 'assets/onboarding/story_recording_hero.webp',
    ),
    OnboardingPageData(
      title: 'StoryJob DNA™',
      subtitle: 'Aus Werten, Vision und Arbeitsstil entsteht deine DNA.\nKein starres Profil – sondern Raum für echte Entwicklung.',
      badgeText: 'StoryJob DNA™ 🧬',
      imagePath: 'assets/onboarding/performance.webp',
    ),
    OnboardingPageData(
      title: 'Finde Teams, die\nauf deiner Wellenlänge sind.',
      subtitle: 'Keine Algorithmus-Noten und kein Recruiting-Sprech.\nSondern Resonanz, Sinn und Dialoge auf Augenhöhe.',
      badgeText: 'Werte-Resonanz ⚡',
      imagePath: 'assets/onboarding/matches.webp',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TalentNavigationScreen()),
    );
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 720;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          // Dynamische Glow Orbs im Hintergrund
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            top: _currentPage.isEven ? -40 : 120,
            left: _currentPage.isEven ? -40 : 180,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.40),
              size: 280,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            bottom: _currentPage.isEven ? -60 : 80,
            right: _currentPage.isEven ? -30 : -80,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.32),
              size: 300,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header mit Logo & Überspringen
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/onboarding/StoryJob-Logo-weiss.png',
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Text(
                            'StoryJob',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (_currentPage < _pages.length - 1)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _completeOnboarding,
                              child: const Text(
                                'Überspringen',
                                style: TextStyle(
                                  color: StoryJobTheme.textSecondary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Main PageView mit dynamischer Höhenanpassung
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _pages[index];
                      final accentColor = index.isEven
                          ? StoryJobTheme.cyanAccent
                          : StoryJobTheme.primaryViolet;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Akzentbalken oben
                              Positioned(
                                top: -6,
                                left: 24,
                                right: 24,
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withValues(alpha: 0.40),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Hauptkarte
                              GlassCard(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                borderRadius: 24,
                                borderColor: Colors.white.withValues(alpha: 0.12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Screenshot-Frame
                                    Container(
                                      height: isSmallScreen ? 170 : 210,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          item.imagePath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.white.withValues(alpha: 0.04),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported_rounded,
                                                  color: Colors.white24,
                                                  size: 36,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    // Badge Row
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: accentColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: accentColor.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.badgeText,
                                            style: const TextStyle(
                                              color: StoryJobTheme.textPrimary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Text-Bereich
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        color: StoryJobTheme.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.subtitle,
                                      style: const TextStyle(
                                        color: StoryJobTheme.textSecondary,
                                        fontSize: 12.5,
                                        height: 1.4,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Footer Controls (Dots & Action-Button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? StoryJobTheme.cyanAccent
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: _currentPage == index
                                  ? [
                                      BoxShadow(
                                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GlassButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Meine Story beginnen ✨'
                            : 'Weiter',
                        isPrimaryGlow: _currentPage == _pages.length - 1,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String badgeText;
  final String imagePath;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.imagePath,
  });
}