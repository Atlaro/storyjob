// lib/core/services/app_services.dart
import 'dart:io' show File, Directory;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AppServices {
  // Zentrale Firebase-Instanzen
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static final AudioRecorder _audioRecorder = AudioRecorder();

  // ==========================================================================
  // 1. AUDIO RECORDING & STORY PUBLISHING
  // ==========================================================================

  static Future<String?> startRecording() async {
    final bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Mikrofon-Berechtigung wurde verweigert.');
    }

    String path = '';
    if (kIsWeb) {
      path = 'audio_story_${DateTime.now().millisecondsSinceEpoch}.m4a';
    } else {
      final Directory dir = await getTemporaryDirectory();
      path = '${dir.path}/story_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    return path;
  }

  static Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }

  static Future<void> cancelRecording() async {
    try {
      await _audioRecorder.cancel();
    } catch (e) {
      debugPrint('Fehler beim Abbrechen der Aufnahme: $e');
    }
  }

  static Future<void> publishStory({
    required String filePath,
    required int durationSeconds,
    String category = 'Werte & Teamfit',
  }) async {
    final User? user = auth.currentUser;
    final String userId = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    String downloadUrl = '';

    if (!kIsWeb) {
      final File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Aufnahmedatei wurde nicht gefunden.');
      }

      final String storyId = db.collection('stories').doc().id;
      final Reference ref = storage.ref().child('stories/$userId/$storyId.m4a');
      final TaskSnapshot uploadTask = await ref.putFile(file);
      downloadUrl = await uploadTask.ref.getDownloadURL();

      final storyPayload = {
        'id': storyId,
        'userId': userId,
        'userName': user?.displayName ?? 'Talent',
        'userAvatarUrl': user?.photoURL ?? '',
        'category': category,
        'audioUrl': downloadUrl,
        'durationSeconds': durationSeconds,
        'createdAt': FieldValue.serverTimestamp(),
        'playsCount': 0,
        'likesCount': 0,
      };

      await db.collection('stories').doc(storyId).set(storyPayload);
    } else {
      final String storyId = db.collection('stories').doc().id;
      final storyPayload = {
        'id': storyId,
        'userId': userId,
        'userName': user?.displayName ?? 'Talent',
        'userAvatarUrl': user?.photoURL ?? '',
        'category': category,
        'audioUrl': filePath,
        'durationSeconds': durationSeconds,
        'createdAt': FieldValue.serverTimestamp(),
        'playsCount': 0,
        'likesCount': 0,
      };

      await db.collection('stories').doc(storyId).set(storyPayload);
    }
  }

  static Stream<QuerySnapshot> getStoryFeedStream() {
    return db
        .collection('stories')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> incrementPlays(String storyId) async {
    try {
      await db.collection('stories').doc(storyId).update({
        'playsCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Fehler beim Inkrementieren der Plays: $e');
    }
  }

  static Future<void> incrementLikes(String storyId) async {
    try {
      await db.collection('stories').doc(storyId).update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Fehler beim Inkrementieren der Likes: $e');
    }
  }

  static void disposeRecorder() {
    _audioRecorder.dispose();
  }

  // ==========================================================================
  // 2. CHAT & STORYDIALOG SERVICES
  // ==========================================================================

  static Future<void> sendMessage(
    String chatId,
    String text, {
    String type = 'text',
    String? audioUrl,
    String? senderId,
  }) async {
    try {
      final effectiveSenderId = senderId ?? 
          auth.currentUser?.uid ?? 
          'guest_user';

      await db
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': effectiveSenderId,
        'text': text,
        'type': type,
        'audioUrl': audioUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await db.collection('chats').doc(chatId).set({
        'lastMessage': type == 'audio' ? '🎤 Sprachnachricht' : text,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('AppServices.sendMessage Fehler: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> getChatMessages(String chatId) {
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ==========================================================================
  // 3. AUTH LOGIK & STORE-READINESS (LÖSCHUNG NACH APPLE-RICHTLINIEN 5.1.1)
  // ==========================================================================

  static Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String role,
    required String displayName,
    String location = 'Region Niederbayern',
    List<String> engagement = const [],
    List<String> interests = const ['Werte & Haltung', 'Innovation'],
  }) async {
    try {
      UserCredential creds = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = creds.user?.uid;

      if (uid != null) {
        await creds.user?.updateDisplayName(displayName);

        await db.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'fullName': displayName,
          'role': role,
          'location': location,
          'engagement': engagement,
          'interests': interests,
          'storyMatchesCount': 0,
          'profileViewsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await db.collection('profiles').doc(uid).set({
          'uid': uid,
          'displayName': displayName,
          'role': role,
          'location': location,
          'engagement': engagement,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return creds;
    } catch (e) {
      debugPrint('Auth Error: $e');
      return null;
    }
  }

  static Future<UserCredential?> loginUser(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
  }

  static Future<bool> sendPasswordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  /// Alias-Methode für die Kaskadenlöschung
  static Future<void> deleteUserAccountCascade() async {
    await deleteAccount();
  }

  /// App Store Richtlinie 5.1.1 & DSGVO (Vollständige Kaskaden-Löschung)
  static Future<void> deleteAccount() async {
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      try {
        await db.collection('users').doc(uid).delete();
        await db.collection('profiles').doc(uid).delete();
        await db.collection('growth_journeys').doc(uid).delete();
        await db.collection('user_identities').doc(uid).delete();
        await db.collection('identities').doc(uid).delete();
        await auth.currentUser?.delete();
      } catch (e) {
        debugPrint('Fehler beim vollständigen Löschen des Accounts: $e');
        rethrow;
      }
    }
  }
}