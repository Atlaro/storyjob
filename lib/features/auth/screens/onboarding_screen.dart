// lib/features/auth/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/role_selection_screen.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({super.key});

  @override
  State<ModernOnboardingScreen> createState() => _ModernOnboardingScreenState();
}

typedef OnboardingScreen = ModernOnboardingScreen;

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          // Atmos-Glow Aura passend zum Deep Universe Look
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            top: _currentPage == 1 ? 40 : -60,
            left: _currentPage.isEven ? -40 : 120,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
              size: 340,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            bottom: _currentPage == 0 ? -60 : 30,
            right: _currentPage.isEven ? -40 : -30,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.28),
              size: 320,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: [
                  // HEADER: Branding & Überspringen
                  SizedBox(
                    height: 52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                                border: Border.all(
                                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.40),
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: StoryJobTheme.cyanAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'StoryJob',
                              style: TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        if (_currentPage < _totalPages - 1)
                          TextButton(
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
                      ],
                    ),
                  ),

                  // TOP HERO BANNER (Wie in Store Mockups)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: StoryJobTheme.heroBannerGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Keine Lebensläufe. Nur deine Story.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3 SCHRITTE
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() => _currentPage = index);
                      },
                      children: [
                        // SCHRITT 1: AUDIO STORY
                        _buildSlide(
                          badge: 'Deine Stimme',
                          icon: Icons.mic_external_on_rounded,
                          accentColor: StoryJobTheme.cyanAccent,
                          title: 'Erzähl deine Story,\nwer du wirklich bist.',
                          description:
                              'Schluss mit starren Lebensläufen und Noten. Zeige in 30-Sekunden Audio-Storys dein echtes Wesen, deine Haltung und wofür du brennst.',
                          footerText: '🎙️ Deine Stimme erzeugt sofort echtes Vertrauen.',
                        ),

                        // SCHRITT 2: WERTE-MATCH & PRAKTISCHES KÖNNEN
                        _buildSlide(
                          badge: 'Praktisches Talent',
                          icon: Icons.hub_rounded,
                          accentColor: StoryJobTheme.pinkMagenta,
                          title: 'Finde Teams,\ndie zu dir passen.',
                          description:
                              'Ob Handwerk, Technik oder Organisation: Bei StoryJob zählt dein praktisches Können. Finde Teams über Werte-Match und echten Team-Fit.',
                          footerText: '⚡ Höre dir Firmen-DNA und Werkstatt-Vibes an.',
                        ),

                        // SCHRITT 3: DIALOG AUF AUGENHÖHE
                        _buildSlide(
                          badge: 'Auf Augenhöhe',
                          icon: Icons.chat_bubble_outline_rounded,
                          accentColor: StoryJobTheme.primaryViolet,
                          title: 'Direkter Dialog.\nEchte Chancen.',
                          description:
                              'Keine Agenturen, kein Anschreiben-Theater. Tausche dich direkt per Voice und Chat aus – mit voller Kontrolle über deine Daten.',
                          footerText: '🚀 Starte direkt rein – kostenfrei und ohne Umwege.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // FOOTER: Dots & GlassButton
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalPages,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              gradient: _currentPage == index
                                  ? const LinearGradient(
                                      colors: [StoryJobTheme.cyanAccent, StoryJobTheme.pinkMagenta],
                                    )
                                  : null,
                              color: _currentPage == index ? null : Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      GlassButton(
                        label: _currentPage == _totalPages - 1
                            ? 'Jetzt starten 🚀'
                            : 'Weiter',
                        isPrimaryGlow: true,
                        height: 52,
                        borderRadius: 26,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _nextPage,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide({
    required String badge,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
    required String footerText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        borderRadius: 24,
        borderGradient: StoryJobTheme.dnaCardBorder,
        hasNeonGlow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.50),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accentColor.withValues(alpha: 0.40)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            Text(
              title,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              description,
              style: const TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Text(
                footerText,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}