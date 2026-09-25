import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppServices {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // --- AUTHENTIFICATION ---

  static Future<User?> loginUser(
    String email,
    String password,
  ) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<User?> registerUser({
    required String email,
    required String password,
    required String role,
    required String displayName,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'role': role,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  // --- RECORDING & STORY SERVICES ---

  static Future<String?> startRecording() async {
    return "recording_started";
  }

  static Future<String?> stopRecording() async {
    return "path/to/audio/file.m4a";
  }

  static Stream<QuerySnapshot> getStoryFeedStream() {
    return db.collection('stories').orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> incrementPlays(String storyId) async {
    try {
      final docRef = db.collection('stories').doc(storyId);
      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final currentPlays = snapshot.data()?['plays'] ?? 0;
          transaction.update(docRef, {'plays': currentPlays + 1});
        }
      });
    } catch (_) {}
  }

  static Future<void> publishStory({
    required String path,
    required int durationSeconds,
  }) async {
    final uid = auth.currentUser?.uid ?? 'guest';
    
    await db.collection('stories').add({
      'userId': uid,
      'audioPath': path,
      'duration': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- CHAT SERVICES ---

  static Stream<QuerySnapshot> getChatMessages(
    String chatId,
  ) {
    return db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  static Future<void> sendMessage(
    String chatId,
    String text,
  ) async {
    final uid = auth.currentUser?.uid ?? 'guest';

    await db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await db.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}