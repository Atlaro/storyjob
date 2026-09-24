import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AppServices {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static final AudioRecorder _audioRecorder = AudioRecorder();

  static Future<String?> startRecording() async {
    final bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Mikrofon-Berechtigung wurde verweigert.');
    }

    final Directory dir = await getTemporaryDirectory();
    final String path = '${dir.path}/story_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    return path;
  }

  static Future<String?> stopRecording() async {
    return await _audioRecorder.stop();
  }

  static Future<void> publishStory({
    required String filePath,
    required int durationSeconds,
    String category = 'PV/Technik',
  }) async {
    final User? user = auth.currentUser;
    final String userId = user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    final File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Aufnahmedatei wurde nicht gefunden.');
    }

    final String storyId = db.collection('stories').doc().id;

    final Reference ref = storage.ref().child('stories/$userId/$storyId.m4a');
    final TaskSnapshot uploadTask = await ref.putFile(file);
    final String downloadUrl = await uploadTask.ref.getDownloadURL();

    await db.collection('stories').doc(storyId).set({
      'id': storyId,
      'userId': userId,
      'userName': user?.displayName ?? 'Peter Alt',
      'userAvatarUrl': user?.photoURL ?? '',
      'category': category,
      'audioUrl': downloadUrl,
      'durationSeconds': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
      'playsCount': 0,
      'likesCount': 0,
    });
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
      debugPrint("Fehler beim Inkrementieren der Plays: $e");
    }
  }

  static Future<void> incrementLikes(String storyId) async {
    try {
      await db.collection('stories').doc(storyId).update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint("Fehler beim Inkrementieren der Likes: $e");
    }
  }

  static void disposeRecorder() {
    _audioRecorder.dispose();
  }

  // --- Auth Logik mit Location-Fix ---
  static Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String role,
    required String displayName,
    String location = 'Pocking', // Location-Fix für sofortiges Matching
    List<String> engagement = const ['BRK', 'Feuerwehr'],
  }) async {
    try {
      UserCredential creds = await auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = creds.user?.uid;

      if (uid != null) {
        await creds.user?.updateDisplayName(displayName);
        await db.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await db.collection('profiles').doc(uid).set({
          'uid': uid,
          'displayName': displayName,
          'role': role,
          'location': location, // Korrekt hinterlegt
          'engagement': engagement,
          'interests': ['Technik', 'Angeln'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return creds;
    } catch (e) {
      debugPrint("Auth Error: $e");
      return null;
    }
  }

  static Future<UserCredential?> loginUser(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  static Future<bool> sendPasswordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint("Password Reset Error: $e");
      return false;
    }
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  static Future<void> deleteAccount() async {
    final uid = auth.currentUser?.uid;
    if (uid != null) {
      await db.collection('users').doc(uid).delete();
      await db.collection('profiles').doc(uid).delete();
      await auth.currentUser?.delete();
    }
  }
}