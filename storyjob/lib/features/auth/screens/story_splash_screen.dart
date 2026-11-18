import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/role_selection_screen.dart';

class StorySplashScreen extends StatefulWidget {
  const StorySplashScreen({super.key});

  @override
  State<StorySplashScreen> createState() => _StorySplashScreenState();
}

class _StorySplashScreenState extends State<StorySplashScreen>
    with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF080914),
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

    _logoScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    _logoPosition = Tween<Offset>(
      begin: const Offset(0, 0.12),
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

    _navigationTimer = Timer(const Duration(seconds: 4), _openNextScreen);
  }

  Animation<double> _fadeIn(double start, double end) {
    return CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  void _openNextScreen() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080914),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF11162A),
                  Color(0xFF080914),
                  Color(0xFF100B20),
                ],
              ),
            ),
          ),

          const Positioned(
            top: -150,
            left: -150,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent,
              size: 350,
            ),
          ),
          const Positioned(
            right: -150,
            bottom: -160,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet,
              size: 370,
            ),
          ),

          // Leichte Abdunklung an den Rändern für mehr Tiefe.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Colors.transparent,
                  Color(0xAA080914),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: StoryJobTheme.cyanAccent
                                          .withValues(alpha: 0.12 + pulse * 0.08),
                                      blurRadius: 26 + pulse * 12,
                                      spreadRadius: 2 + pulse * 3,
                                    ),
                                    BoxShadow(
                                      color: StoryJobTheme.primaryViolet
                                          .withValues(alpha: 0.10 + pulse * 0.07),
                                      blurRadius: 34 + pulse * 12,
                                      spreadRadius: 1 + pulse * 2,
                                    ),
                                  ],
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/splash/Branding.png',
                        width: 290,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 38),

                    FadeTransition(
                      opacity: _firstLineOpacity,
                      child: const _SplashStatement('Keine Noten.'),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _secondLineOpacity,
                      child: const _SplashStatement('Kein Lebenslauf.'),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _thirdLineOpacity,
                      child: const _SplashStatement('Keine Bewerbung.'),
                    ),

                    const SizedBox(height: 26),

                    FadeTransition(
                      opacity: _hookOpacity,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFF70E7FF),
                              Color(0xFFC2A3FF),
                            ],
                          ).createShader(bounds);
                        },
                        child: const Text(
                          'Entdecke dein Potenzial.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    FadeTransition(
                      opacity: _hookOpacity,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashStatement extends StatelessWidget {
  const _SplashStatement(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFD1D4E0),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.35,
      ),
    );
  }
}