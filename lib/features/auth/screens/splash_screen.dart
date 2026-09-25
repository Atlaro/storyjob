import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';
import 'onboarding_screen.dart';
import '../../../core/theme/storyjob_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ZUM TESTEN: Kommentiere die folgende Zeile EIN, um das Onboarding bei jedem App-Start zu erzwingen:
    // await prefs.setBool('seenOnboarding', false);

    final hasSeen = prefs.getBool('seenOnboarding') ?? false;

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_navigated) {
        _navigateToNextScreen(hasSeen);
      }
    });
  }

  void _navigateToNextScreen(bool hasSeen) {
    if (_navigated) return;
    _navigated = true;

    final Widget targetScreen = hasSeen ? const AuthScreen() : const ModernOnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/images/splash/storyjob_splash.webp',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error1, stackTrace1) {
              return const Center(
                child: Text(
                  'StoryJob',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}