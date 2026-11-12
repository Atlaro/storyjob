// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/features/auth/screens/teams_auth_screen.dart';
import 'package:storyteams/features/teams/screens/teams_landing_screen.dart';
import 'package:storyteams/features/teams/screens/teams_workspace_screen.dart';
import 'package:storyteams/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase Init: $e');
  }
  runApp(const StoryTeamsApp());
}

class StoryTeamsApp extends StatelessWidget {
  const StoryTeamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob Teams – Team- & Einsatzmanagement',
      debugShowCheckedModeBanner: false,
      theme: StoryJobTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnap) {
          if (authSnap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: StoryJobTheme.backgroundBase,
              body: Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent)),
            );
          }

          final user = authSnap.data;
          if (user == null) {
            return const TeamsAuthScreen();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userDocSnap) {
              if (userDocSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: StoryJobTheme.backgroundBase,
                  body: Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent)),
                );
              }
              final raw = userDocSnap.data?.data();
              final data = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
              final activeTeamId = data['activeTeamId']?.toString();
              if (activeTeamId != null && activeTeamId.isNotEmpty) {
                return TeamsWorkspaceScreen(teamId: activeTeamId);
              }
              return const TeamsLandingScreen();
            },
          );
        },
      ),
    );
  }
}