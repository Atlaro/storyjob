import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/intro_prefs_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/Teams/screens/team_dashboard_screen.dart';
import 'package:storyjob/features/auth/screens/role_selection_screen.dart';
import 'package:storyjob/features/auth/screens/story_intro_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';

class LogoSplashScreen extends StatefulWidget {
  const LogoSplashScreen({super.key});

  @override
  State<LogoSplashScreen> createState() => _LogoSplashScreenState();
}

class _LogoSplashScreenState extends State<LogoSplashScreen>
    with SingleTickerProviderStateMixin {
  final IntroPrefsService _introPrefs = IntroPrefsService();

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  Timer? _minDisplayTimer;
  bool _minTimeElapsed = false;
  bool _hasResolvedDestination = false;
  bool _isNavigating = false;
  Widget? _destination;

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Kurze Mindestzeit für flüssige Wahrnehmung ohne künstliches Mehrfach-Sekunden-Warten
    _minDisplayTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _minTimeElapsed = true;
      _tryNavigate();
    });

    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    try {
      final seenIntro = await _introPrefs.hasSeenIntro();
      if (!mounted) return;

      if (!seenIntro) {
        _destination = const StoryIntroScreen();
      } else {
        _destination = await _resolveReturningUserScreen();
      }
    } catch (_) {
      _destination = const RoleSelectionScreen();
    } finally {
      if (mounted) {
        _hasResolvedDestination = true;
        _tryNavigate();
      }
    }
  }

  Future<Widget> _resolveReturningUserScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const RoleSelectionScreen();
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = doc.data()?['role'] as String?;
      if (role == 'team') {
        return const TeamDashboardScreen();
      }
    } catch (_) {
      // Bei Lesefehlern sicher auf den Standard-Startscreen für Talente fallen
    }

    return const TalentNavigationScreen();
  }

  void _tryNavigate() {
    if (!mounted || _isNavigating) return;
    if (!_minTimeElapsed || !_hasResolvedDestination || _destination == null) {
      return;
    }

    _isNavigating = true;
    final target = _destination!;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => target,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _isNavigating = true;
    _minDisplayTimer?.cancel();
    _controller.dispose();
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
              child: Center(
                child: FadeTransition(
                  opacity: _opacity,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: StoryJobTheme.cyanAccent
                                .withValues(alpha: 0.14),
                            blurRadius: 36,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/splash/Branding.png',
                        width: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}