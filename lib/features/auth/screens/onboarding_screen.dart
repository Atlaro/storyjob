import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/storyjob_theme.dart';
import '../../navigation/main_navigation_hub.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({super.key});

  @override
  State createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _slideshowTimer;

  final _onboardingData = [
    {
      'title': 'Willkommen bei StoryJob',
      'text': 'Talente erkennt man nicht auf dem Papier.',
      'image': 'assets/images/onboarding/onboarding_person.webp',
    },
    {
      'title': 'Erzähle deine Geschichte',
      'text': 'Zeige Persönlichkeit, Motivation und Potenzial mit deinem Voice Pitch.',
      'image': 'assets/images/onboarding/story_recording_hero.webp',
    },
    {
      'title': 'Finde den passenden Match',
      'text': 'Unternehmen hören deine Geschichte bevor sie deinen Lebenslauf sehen.',
      'image': 'assets/images/onboarding/matches.webp',
    },
    {
      'title': 'Deine Story. Deine Zukunft.',
      'text': 'Jede Karriere beginnt mit einer Geschichte.',
      'image': 'assets/images/onboarding/performance.webp',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlideshow();
  }

  void _startAutoSlideshow() {
    _slideshowTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _onboardingData.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    _slideshowTimer?.cancel();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
    } catch (e) {
      debugPrint('Fehler beim Speichern des Onboarding-Status: $e');
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationHub(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [Color(0xFF1D1438), StoryJobTheme.backgroundBase],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.mic_rounded, color: StoryJobTheme.cyanAccent, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'StoryJob',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: StoryJobTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (_currentPage < _onboardingData.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: StoryJobTheme.textSecondary,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Überspringen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    if (index == _onboardingData.length - 1) {
                      _slideshowTimer?.cancel();
                    }
                  },
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    final isLastScreen = index == _onboardingData.length - 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Hero(
                              tag: 'onboarding_image_$index',
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    data['image']!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: StoryJobTheme.cardSurface,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(color: StoryJobTheme.primaryViolet),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 80,
                                            color: StoryJobTheme.cyanAccent,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Text(
                                  data['title']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.w900,
                                    color: StoryJobTheme.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  data['text']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    color: StoryJobTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isLastScreen) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 54,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: StoryJobTheme.primaryViolet, width: 2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      onPressed: _completeOnboarding,
                                      child: const Text(
                                        'Anmelden',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: StoryJobTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 54,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: StoryJobTheme.primaryViolet,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 6,
                                        shadowColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                                      ),
                                      onPressed: _completeOnboarding,
                                      child: const Text(
                                        'Registrieren',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _onboardingData.length,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        activeDotColor: StoryJobTheme.primaryViolet,
                        dotColor: StoryJobTheme.cardBorder,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentPage < _onboardingData.length - 1)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryJobTheme.primaryViolet,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                            shadowColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text(
                            'Weiter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}