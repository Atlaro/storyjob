import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppServices {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

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