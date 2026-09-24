import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'core/theme/storyjob_theme.dart';
import 'features/auth/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase Init Fehler (evtl. schon initialisiert): $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: StoryJobTheme.backgroundBase,
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
      home: const AuthScreen(),
    );
  }
}