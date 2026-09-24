import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = AppServices.auth.currentUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nachrichten & Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AppServices.db.collection('chats').orderBy('lastUpdated', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Noch keine aktiven Chats vorhanden.',
                style: TextStyle(color: StoryJobTheme.textSecondary),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final chatId = docs[index].id;
              final partnerName = data['partnerName'] ?? 'Unternehmens-Kontakt';
              final lastMessage = data['lastMessage'] ?? 'Keine Nachrichten';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    child: Icon(Icons.business_rounded, color: Colors.white),
                  ),
                  title: Text(
                    partnerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: StoryJobTheme.textPrimary),
                  ),
                  subtitle: Text(
                    lastMessage,
                    style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          chatId: chatId,
                          currentUserId: currentUid,
                          chatPartnerName: partnerName,
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