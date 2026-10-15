// lib/features/auth/screens/story_splash_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/onboarding_screen.dart';
import 'package:storyjob/features/auth/screens/role_selection_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';
import 'package:storyjob/features/recruiter/screens/recruiter_navigation_screen.dart';

class StorySplashScreen extends StatefulWidget {
  const StorySplashScreen({super.key});

  @override
  State<StorySplashScreen> createState() => _StorySplashScreenState();
}

class _StorySplashScreenState extends State<StorySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase 1: Filmisches Erstrahlen (0.0 - 0.25)
  late final Animation<double> _logoFadeIn;
  late final Animation<double> _glowAura;
  late final Animation<double> _textFadeIn;

  // Phase 2: Majestätisches Ruhen / leichtes Atmen (0.25 - 0.70)
  late final Animation<double> _breathingScale;

  // Phase 3: Text blendet aus (0.68 - 0.78)
  late final Animation<double> _textFadeOut;

  // Phase 4: Universal-Studios Kamera-Durchflug (0.75 - 1.00)
  late final Animation<double> _cameraZoom;
  late final Animation<double> _finalFadeOut;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Gesamtdauer auf filmreife 4,8 Sekunden erhöht
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    // 1. Logo & Aura faden weich ein (0.00 bis 0.22)
    _logoFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.22, curve: Curves.easeOutCubic),
      ),
    );

    _glowAura = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.45, curve: Curves.easeInOut),
      ),
    );

    // 2. Texte erscheinen kurz danach (0.18 bis 0.35)
    _textFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.18, 0.35, curve: Curves.easeIn),
      ),
    );

    // 3. Subtiles Atmen / Schweben während der Präsentation
    _breathingScale = Tween<double>(begin: 0.95, end: 1.03).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.10, 0.72, curve: Curves.easeInOutSine),
      ),
    );

    // 4. Claim & Subtitel ziehen sich zurück (0.68 bis 0.78)
    _textFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.68, 0.78, curve: Curves.easeOut),
      ),
    );

    // 5. Der gewaltige Universal-Zoom durch den Bildschirm (0.74 bis 1.00)
    _cameraZoom = Tween<double>(begin: 1.0, end: 45.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.74, 1.00, curve: Curves.easeInExpo),
      ),
    );

    // 6. Weiß/Licht-Auflösung kurz vor Schluss (0.88 bis 1.00)
    _finalFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.88, 1.00, curve: Curves.easeInCirc),
      ),
    );

    _ctrl.forward().then((_) {
      if (mounted) {
        _navigateNext();
      }
    });

    _triggerCinematicHaptics();
  }

  Future<void> _triggerCinematicHaptics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    HapticFeedback.lightImpact();
    // Haptischer Schockeffekt genau beim Start des Kamera-Durchflugs (nach ca. 3,6 Sek.)
    await Future.delayed(const Duration(milliseconds: 3200));
    HapticFeedback.heavyImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(
      precacheImage(
        const AssetImage('assets/onboarding/StoryJob-Logo-weiss.png'),
        context,
      ).catchError((_) {}),
    );
  }

  Future<void> _navigateNext() async {
    if (_navigated) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;
    final savedRole = prefs.getString('user_role') ?? 'talent';

    if (!mounted) return;

    Widget targetScreen;
    if (!seenOnboarding) {
      targetScreen = const ModernOnboardingScreen();
    } else if (currentUser == null) {
      targetScreen = const RoleSelectionScreen();
    } else {
      targetScreen = (savedRole == 'recruiter' || savedRole == 'company')
          ? const RecruiterNavigationScreen()
          : const TalentNavigationScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, __, ___) => targetScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Statisches Sternen- & Partikelfeld (Cinematic Universe)
          const Positioned.fill(
            child: _CinematicStarsField(),
          ),

          // Filmische Hintergrund-Aura
          Positioned(
            top: -100,
            right: -80,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
              size: 420,
            ),
          ),
          Positioned(
            bottom: -110,
            left: -90,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.28),
              size: 440,
            ),
          ),

          SafeArea(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final double currentZoom = _cameraZoom.value;
                final double currentOpacity = _logoFadeIn.value * _finalFadeOut.value;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // ==========================================
                      // DAS ZENTRALE LOGO MIT ZOOM-THROUGH
                      // ==========================================
                      Transform.scale(
                        scale: currentZoom * _breathingScale.value,
                        child: Opacity(
                          opacity: currentOpacity.clamp(0.0, 1.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Strahlende Licht-Aura hinter dem Logo
                              Container(
                                width: 310,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      color: StoryJobTheme.cyanAccent.withValues(
                                        alpha: 0.36 * _glowAura.value,
                                      ),
                                      blurRadius: 65,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: StoryJobTheme.primaryViolet.withValues(
                                        alpha: 0.28 * _glowAura.value,
                                      ),
                                      blurRadius: 85,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),

                              // Bild-Asset mit verlässlicher Fallback-Typo
                              SizedBox(
                                width: 320,
                                height: 110,
                                child: Image.asset(
                                  'assets/onboarding/StoryJob-Logo-weiss.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF161822),
                                            border: Border.all(
                                              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome_rounded,
                                            color: StoryJobTheme.cyanAccent,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        const Text(
                                          'StoryJob',
                                          style: TextStyle(
                                            color: StoryJobTheme.textPrimary,
                                            fontSize: 44,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      // ==========================================
                      // TEXTE (CLAIM & SUBTITLE)
                      // ==========================================
                      Opacity(
                        opacity: (_textFadeIn.value * _textFadeOut.value).clamp(0.0, 1.0),
                        child: Column(
                          children: [
                            const Text(
                              'Deine Story.\nDeine Chance.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Nicht jeder passt überall hin.\nAber jeder passt irgendwo perfekt hin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: StoryJobTheme.textSecondary.withValues(alpha: 0.9),
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 5),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Subtile Sternen- & Partikelebene für cineastische Tiefe
class _CinematicStarsField extends StatelessWidget {
  const _CinematicStarsField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarsPainter(),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.18);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.3 + 0.3;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}