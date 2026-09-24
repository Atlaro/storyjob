import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String text;
  final String? audioUrl;
  final DateTime? timestamp;

  MessageModel({
    required this.senderId,
    required this.text,
    this.audioUrl,
    this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      audioUrl: data['audioUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}