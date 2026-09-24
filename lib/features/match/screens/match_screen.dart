import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/storyjob_theme.dart';
import '../../../core/services/app_services.dart';
import '../models/match_model.dart';
import '../widgets/match_card.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Matching'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AppServices.db.collection('profiles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Keine passenden Profile gefunden.',
                style: TextStyle(color: StoryJobTheme.textSecondary),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final match = MatchModel.fromFirestore(docs[index]);
              return MatchCard(
                match: match,
                onConnectPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Verbindungsanfrage an ${match.displayName} gesendet!')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}