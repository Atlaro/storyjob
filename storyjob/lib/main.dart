// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/services/fcm_service.dart';
import 'package:storyjob/features/auth/screens/story_splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase & Benachrichtigungen initialisieren
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FcmService().initializeFcm();
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  // 2. Bildschirmausrichtung sperren (Portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 3. System-UI-Styling (Statusleiste & Navigationsleiste nahtlos im Off-Black Look)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: StoryJobTheme.backgroundBase,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const StoryJobApp());
}

class StoryJobApp extends StatelessWidget {
  const StoryJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: StoryJobTheme.darkTheme,
      darkTheme: StoryJobTheme.darkTheme,
      home: const StorySplashScreen(),
    );
  }
}