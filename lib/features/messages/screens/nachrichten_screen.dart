import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';
import 'chat_detail_screen.dart';

class NachrichtenScreen extends StatelessWidget {
  const NachrichtenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = AppServices.auth.currentUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nachrichten', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AppServices.db
            .collection('chats')
            .where('participants', arrayContains: currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          // WICHTIG: Muss im Web als allererstes stehen, um den TypeError abzufangen!
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Lade Nachrichten...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StoryJobTheme.textSecondary, height: 1.5),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Keine Konversationen vorhanden.\nStarte einen Chat über ein Match oder Profil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StoryJobTheme.textSecondary, height: 1.5),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final chatId = docs[index].id;
              final lastMessage = data['lastMessage'] ?? 'Keine Nachrichten bisher';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    child: Icon(Icons.person_rounded, color: Colors.white),
                  ),
                  title: Text(
                    'Chat $chatId',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: StoryJobTheme.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: StoryJobTheme.textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatId: chatId,
                          currentUserId: currentUid,
                          chatPartnerName: 'Chat Partner',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}