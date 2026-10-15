// lib/features/messages/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String type; // 'text', 'audio', 'resonance_spark'
  final String? audioUrl;
  final int? audioDurationSeconds;
  final String? resonanceTag;
  final DateTime? timestamp;

  const MessageModel({
    this.id = '',
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.audioUrl,
    this.audioDurationSeconds,
    this.resonanceTag,
    this.timestamp,
  });

  /// Prüft, ob es sich um eine Sprachnachricht handelt
  bool get isAudio => type == 'audio' || (audioUrl != null && audioUrl!.isNotEmpty);

  /// Prüft, ob es sich um einen wertebasierten Impuls handelt
  bool get isSpark => type == 'resonance_spark' || (resonanceTag != null && resonanceTag!.isNotEmpty);

  /// Prüft, ob die Nachricht vom aktuellen Nutzer stammt
  bool isMine(String currentUserId) => senderId == currentUserId;

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    String? type,
    String? audioUrl,
    int? audioDurationSeconds,
    String? resonanceTag,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      resonanceTag: resonanceTag ?? this.resonanceTag,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type,
      'audioUrl': audioUrl ?? '',
      'audioDurationSeconds': audioDurationSeconds ?? 0,
      'resonanceTag': resonanceTag ?? '',
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data = (rawData is Map<String, dynamic>) ? rawData : {};

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: data['type'] as String? ??
          ((data['audioUrl'] != null && (data['audioUrl'] as String).isNotEmpty) ? 'audio' : 'text'),
      audioUrl: (data['audioUrl'] as String?)?.isNotEmpty == true ? data['audioUrl'] as String : null,
      audioDurationSeconds: data['audioDurationSeconds'] as int? ?? 0,
      resonanceTag: (data['resonanceTag'] as String?)?.isNotEmpty == true ? data['resonanceTag'] as String : null,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}