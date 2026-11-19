// lib/core/services/story_symbiosis_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class StorySymbiosisService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String buildDialogId(String? currentUserId, String targetKey) {
    final cleanTarget =
        targetKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (currentUserId == null || currentUserId.isEmpty) {
      return 'dialog_$cleanTarget';
    }
    final pair = [currentUserId, cleanTarget]..sort();
    return 'dialog_${pair.first}_${pair.last}';
  }

  /// Sendet einen Impuls / eine Resonanz auf eine Talent- oder Team-Story
  /// und erzeugt einen Eintrag für den Tab "Benachrichtigungen".
  static Future<void> sendStoryImpulse({
    required String? recipientId,
    required String targetName,
    required String storyTitle,
    String matchScore = 'Werte-Resonanz ✨',
    String type = 'favorite',
    String? storyDocId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final actorName = currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!.trim()
        : 'StoryJob Mitglied';

    final chatId = buildDialogId(
      currentUser?.uid,
      recipientId?.isNotEmpty == true ? recipientId! : targetName,
    );

    if (storyDocId != null && storyDocId.isNotEmpty) {
      await _db.collection('stories').doc(storyDocId).set({
        'likesCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    if (recipientId != null && recipientId.isNotEmpty) {
      await _db.collection('notifications').add({
        'recipientId': recipientId,
        'actorId': currentUser?.uid ?? '',
        'actorName': actorName,
        'targetName': targetName,
        'storyTitle': storyTitle,
        'roleContext': storyTitle,
        'matchScore': matchScore,
        'type': type,
        'chatId': chatId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Stellt sicher, dass der Dialog-Eintrag existiert, und öffnet StoryDialogScreen.
  static Future<void> openOrCreateDialog(
    BuildContext context, {
    String? recipientId,
    required String targetName,
    required String roleContext,
    String matchScore = 'Hohe Werte-Passung ✨',
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final chatId = buildDialogId(
      currentUser?.uid,
      recipientId?.isNotEmpty == true ? recipientId! : targetName,
    );

    final participants = <String>[
      if (currentUser?.uid != null && currentUser!.uid.isNotEmpty) currentUser.uid,
      if (recipientId != null && recipientId.isNotEmpty) recipientId,
    ];

    final dialogRef = _db.collection('dialogs').doc(chatId);
    await dialogRef.set({
      'participants': participants,
      'partnerName': targetName,
      'targetName': targetName,
      'roleTitle': roleContext,
      'roleContext': roleContext,
      'matchScore': matchScore,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'time': 'Jetzt',
    }, SetOptions(merge: true));

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDialogScreen(
          chatId: chatId,
          targetName: targetName,
          roleContext: roleContext,
          matchScore: matchScore,
        ),
      ),
    );
  }
}