// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storydna/firebase_options.dart';
import 'package:storydna/core/theme/storyjob_theme.dart';
import 'package:storydna/features/auth/screens/dna_auth_screen.dart';
import 'package:storydna/features/identity/screens/story_dna_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Init: $e');
  }
  runApp(const StoryDNAApp());
}

class StoryDNAApp extends StatelessWidget {
  const StoryDNAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob DNA™',
      debugShowCheckedModeBanner: false,
      theme: StoryJobTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: StoryJobTheme.backgroundBase,
              body: Center(
                child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
              ),
            );
          }
          if (snapshot.hasData) {
            return const StoryDNAScreen();
          }
          return const DnaAuthScreen();
        },
      ),
    );
  }
}