import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String category;
  final String audioUrl;
  final int durationSeconds;
  final DateTime? createdAt;
  final int playsCount;
  final int likesCount;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.category,
    required this.audioUrl,
    required this.durationSeconds,
    required this.createdAt,
    required this.playsCount,
    required this.likesCount,
  });

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonym',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      category: data['category'] ?? 'Allgemein',
      audioUrl: data['audioUrl'] ?? '',
      durationSeconds: data['durationSeconds'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      playsCount: data['playsCount'] ?? 0,
      likesCount: data['likesCount'] ?? 0,
    );
  }
}