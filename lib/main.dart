import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/navigation/main_navigation_hub.dart';
import 'package:storyjob/features/auth/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Abgesicherter Start: Verhindert den White Screen, wenn Firebase Web-Options fehlen
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Initialisierungs-Hinweis: $e');
  }

  SharedPreferences? prefs;
  bool seenOnboarding = false;

  try {
    prefs = await SharedPreferences.getInstance();
    seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  } catch (e) {
    debugPrint('SharedPreferences Fehler: $e');
  }

  runApp(StoryJobApp(showOnboarding: !seenOnboarding));
}

class StoryJobApp extends StatelessWidget {
  final bool showOnboarding;

  const StoryJobApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: StoryJobTheme.darkTheme,
      home: showOnboarding 
          ? const ModernOnboardingScreen() 
          : const MainNavigationHub(),
    );
  }
}