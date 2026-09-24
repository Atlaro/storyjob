import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/storyjob_theme.dart';
import '../../../core/services/app_services.dart';
import '../models/story_model.dart';
import '../widgets/story_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryJob Feed'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AppServices.getStoryFeedStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mic_none, size: 64, color: StoryJobTheme.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'Noch keine Stories vorhanden.\nStarte die Aufnahme und teile deine Story!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: StoryJobTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final story = StoryModel.fromFirestore(docs[index]);
              return StoryCard(story: story);
            },
          );
        },
      ),
    );
  }
}