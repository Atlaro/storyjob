import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/intro_prefs_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/role_selection_screen.dart';

class StoryIntroScreen extends StatefulWidget {
  const StoryIntroScreen({super.key});

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen>
    with TickerProviderStateMixin {
  final IntroPrefsService _introPrefs = IntroPrefsService();

  late final AnimationController _introController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoPosition;
  late final Animation<double> _firstLineOpacity;
  late final Animation<double> _secondLineOpacity;
  late final Animation<double> _thirdLineOpacity;
  late final Animation<double> _hookOpacity;

  Timer? _navigationTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: StoryJobTheme.backgroundBase,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.32, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    _logoPosition = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    _firstLineOpacity = _fadeIn(0.34, 0.47);
    _secondLineOpacity = _fadeIn(0.45, 0.58);
    _thirdLineOpacity = _fadeIn(0.56, 0.69);
    _hookOpacity = _fadeIn(0.70, 0.88);

    _introController.forward();
    _pulseController.repeat(reverse: true);

    _navigationTimer = Timer(const Duration(seconds: 4), _completeIntro);
  }

  Animation<double> _fadeIn(double start, double end) {
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Future<void> _completeIntro() async {
    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    try {
      await _introPrefs.markIntroAsSeen();
    } catch (_) {
      // Auch bei Speicherfehlern sauber weiter navigieren
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _isNavigating = true;
    _navigationTimer?.cancel();
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -80,
            right: -60,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent,
              size: 280,
            ),
          ),
          const Positioned(
            bottom: -80,
            left: -60,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet,
              size: 280,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _introController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      final pulse = _pulseController.value;
                      final breathingScale = 1 + (pulse * 0.012);

                      return FadeTransition(
                        opacity: _logoOpacity,
                        child: SlideTransition(
                          position: _logoPosition,
                          child: Transform.scale(
                            scale: _logoScale.value * breathingScale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/splash/Branding.png',
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _firstLineOpacity,
                    child: const _IntroStatement('Keine Noten.'),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _secondLineOpacity,
                    child: const _IntroStatement('Kein Lebenslauf.'),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _thirdLineOpacity,
                    child: const _IntroStatement('Keine Bewerbung.'),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _hookOpacity,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            StoryJobTheme.cyanAccent,
                            Color(0xFFC2A3FF),
                          ],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'Potenzial sichtbar machen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroStatement extends StatelessWidget {
  const _IntroStatement(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: StoryJobTheme.textSecondary,
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
    );
  }
}