import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/role_selection_screen.dart';

class StorySplashScreen extends StatefulWidget {
  const StorySplashScreen({super.key});

  @override
  State<StorySplashScreen> createState() => _StorySplashScreenState();
}

class _StorySplashScreenState extends State<StorySplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Nach 3 Sekunden automatisch zur Rollenauswahl weiterleiten
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    });
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
      body: Stack(
        children: [
          const Positioned(
            top: -100,
            left: -100,
            child: GlowOrb(color: StoryJobTheme.cyanAccent, size: 320),
          ),
          const Positioned(
            bottom: -100,
            right: -100,
            child: GlowOrb(color: StoryJobTheme.primaryViolet, size: 320),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'storyjob_splash_logo_text',
                    child: Image.asset(
                      'assets/images/splash/Branding.png',
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Human Opportunity Network',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: StoryJobTheme.textSecondary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}