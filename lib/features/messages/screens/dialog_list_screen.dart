// lib/features/messages/screens/dialog_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';
import 'package:storyjob/features/profile/widgets/security_trust_widget.dart';

class DialogListScreen extends StatelessWidget {
  const DialogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meine StoryDialoge',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Datensicherheit',
            icon: const Icon(
              Icons.shield_outlined,
              color: StoryJobTheme.textSecondary,
              size: 20,
            ),
            onPressed: () => SecurityTrustWidget.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Text(
                'Vertrauliche Gespräche & Kennenlernen auf Augenhöhe.',
                style: TextStyle(
                  color: StoryJobTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: currentUserId != null
                    ? FirebaseFirestore.instance
                        .collection('dialogs')
                        .where('participants', arrayContains: currentUserId)
                        .orderBy('lastMessageTimestamp', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('dialogs')
                        .limit(20)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // Fallback auf collection 'story_dialogs', falls alte Dokumente migriert werden
                    return _buildLegacyStream(context, currentUserId);
                  }

                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _buildLegacyStream(context, currentUserId);
                  }

                  return _buildDialogListView(docs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegacyStream(BuildContext context, String? currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('story_dialogs').snapshots(),
      builder: (context, legacySnap) {
        if (legacySnap.connectionState == ConnectionState.waiting && !legacySnap.hasData) {
          return const Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent));
        }
        final legacyDocs = legacySnap.data?.docs ?? [];
        if (legacyDocs.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildDialogListView(legacyDocs);
      },
    );
  }

  Widget _buildDialogListView(List<QueryDocumentSnapshot> docs) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>? ?? {};

        final partnerName = data['partnerName'] as String? ??
            data['targetName'] as String? ??
            'StoryJob Kontakt';
        final roleTitle = data['roleTitle'] as String? ??
            data['roleContext'] as String? ??
            'Austausch auf Augenhöhe';
        final matchScore = data['matchScore'] as String? ??
            data['resonanceLevel'] as String? ??
            'Hohe Resonanz ✨';
        final lastMessage = data['lastMessage'] as String? ?? 'Neuer StoryDialog gestartet';
        final timeStr = data['time'] as String? ?? 'Heute';

        return Container(
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StoryJobTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: StoryJobTheme.cardSurface,
                    border: Border.all(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.40),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: StoryJobTheme.emeraldGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: StoryJobTheme.cardSurfaceElevated, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    partnerName,
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: StoryJobTheme.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        roleTitle,
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        matchScore,
                        style: const TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  lastMessage,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: StoryJobTheme.textMuted,
              size: 12,
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryDialogScreen(
                    chatId: doc.id,
                    targetName: partnerName,
                    roleContext: roleTitle,
                    matchScore: matchScore,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 36,
                color: StoryJobTheme.cyanAccent,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Noch keine aktiven Dialoge',
              style: TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sobald Resonanz auf eine Story entsteht oder eine Wellenlänge entdeckt wird, startet euer Dialog auf Augenhöhe direkt hier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}