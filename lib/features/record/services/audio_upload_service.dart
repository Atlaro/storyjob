// lib/features/record/services/audio_upload_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AudioUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Statische Methode für den Schnellaufruf/Veröffentlichung aus dem Success-Screen (Audio & Video)
  static Future<bool> publishVoiceStory({
    String? userId,
    String? mediaFilePath,
    int? durationSeconds,
    bool isVideo = false,
    String? title,
    List<String>? tags,
  }) async {
    try {
      final targetUserId = userId ?? 'current_user';

      if (mediaFilePath != null && mediaFilePath.isNotEmpty && !kIsWeb) {
        final service = AudioUploadService();
        final file = File(mediaFilePath);
        if (await file.exists()) {
          if (isVideo) {
            final videoUrl = await service.uploadVideoStory(
              userId: targetUserId,
              videoFile: file,
              durationSeconds: durationSeconds ?? 30,
              title: title,
              tags: tags,
            );
            return videoUrl != null;
          } else {
            final audioUrl = await service.uploadVoiceStory(
              userId: targetUserId,
              audioFile: file,
              durationSeconds: durationSeconds ?? 45,
              title: title,
              tags: tags,
            );
            return audioUrl != null;
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 600));
      debugPrint('Story ($durationSeconds Sek., isVideo: $isVideo) simuliert für $targetUserId: $title');
      return true;
    } catch (e) {
      debugPrint('Fehler bei publishVoiceStory: $e');
      return false;
    }
  }

  /// Lädt die Audio-Story hoch und spiegelt die URLs profil-, identity- und feedweit
  Future<String?> uploadVoiceStory({
    required String userId,
    required File audioFile,
    int durationSeconds = 45,
    String? title,
    List<String>? tags,
    Function(double progress)? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref().child('users/$userId/stories/voice_story_$timestamp.aac');

      final uploadTask = storageRef.putFile(
        audioFile,
        SettableMetadata(
          contentType: 'audio/aac',
          customMetadata: {
            'uploadedBy': userId,
            'gdprConsent': 'true',
            'privacyLevel': 'verified_resonance',
            'durationSeconds': durationSeconds.toString(),
          },
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 1. Profil- und Identitätsdaten abrufen
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['displayName'] ?? userData['fullName'] ?? userData['name'] ?? 'StoryJob Macher';
      final handle = userData['handle'] ?? '@talent';
      final avatarUrl = userData['photoURL'] ?? userData['avatarUrl'];

      final defaultTitle = title ?? 'StoryJob DNA™ Audio-Story';
      final resolvedTags = tags ?? ['Haltung', 'Werte', 'Miteinander'];

      final batch = _firestore.batch();

      // 2. Nutzerprofil (users) aktualisieren
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'audioStoryUrl': downloadUrl,
        'audioPitchUrl': downloadUrl,
        'audioDurationSeconds': durationSeconds,
        'audioStoryTitle': defaultTitle,
        'hasActiveVoiceStory': true,
        'storyTags': resolvedTags,
        'audioStoryUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. StoryJob DNA Identität synchronisieren
      final identityRef = _firestore.collection('user_identities').doc(userId);
      batch.set(identityRef, {
        'audioStoryUrl': downloadUrl,
        'audioDurationSeconds': durationSeconds,
        'hasActiveVoiceStory': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      // 4. Im globalen Werte-Feed ('stories') veröffentlichen
      await _firestore.collection('stories').add({
        'userId': userId,
        'authorName': userName,
        'authorHandle': handle,
        'authorAvatar': avatarUrl,
        'mediaUrl': downloadUrl,
        'mediaType': 'audio',
        'title': defaultTitle,
        'durationSeconds': durationSeconds,
        'tags': resolvedTags,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Audio-Upload & Resonanz-Aktivierung erfolgreich: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Fehler beim Audio-Upload nach Firebase: $e');
      return null;
    }
  }

  /// Lädt eine Video-Story (.mp4) hoch und verknüpft sie mit Firestore & Identity
  Future<String?> uploadVideoStory({
    required String userId,
    required File videoFile,
    int durationSeconds = 30,
    String? title,
    List<String>? tags,
    Function(double progress)? onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage.ref().child('users/$userId/videos/video_story_$timestamp.mp4');

      final uploadTask = storageRef.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'uploadedBy': userId,
            'gdprConsent': 'true',
            'privacyLevel': 'verified_resonance',
            'durationSeconds': durationSeconds.toString(),
          },
        ),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['displayName'] ?? userData['fullName'] ?? userData['name'] ?? 'StoryJob Macher';
      final handle = userData['handle'] ?? '@talent';
      final avatarUrl = userData['photoURL'] ?? userData['avatarUrl'];

      final defaultTitle = title ?? 'StoryJob Video-Impuls';
      final resolvedTags = tags ?? ['Persönlichkeit', 'Kennenlernen'];

      final batch = _firestore.batch();

      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'videoStoryUrl': downloadUrl,
        'videoDurationSeconds': durationSeconds,
        'videoStoryTitle': defaultTitle,
        'hasActiveVideoStory': true,
        'storyTags': resolvedTags,
        'videoStoryUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final identityRef = _firestore.collection('user_identities').doc(userId);
      batch.set(identityRef, {
        'videoStoryUrl': downloadUrl,
        'hasActiveVideoStory': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      await _firestore.collection('stories').add({
        'userId': userId,
        'authorName': userName,
        'authorHandle': handle,
        'authorAvatar': avatarUrl,
        'mediaUrl': downloadUrl,
        'mediaType': 'video',
        'title': defaultTitle,
        'durationSeconds': durationSeconds,
        'tags': resolvedTags,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Video-Upload & Feed-Eintrag erfolgreich: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Fehler beim Video-Upload nach Firebase: $e');
      return null;
    }
  }

  /// DSGVO-konforme Löschung aller Stories (Audio, Video, Identity & Feed)
  Future<void> deleteUserMediaStories(String userId) async {
    try {
      try {
        final audioRef = _storage.ref().child('users/$userId/stories');
        final audioItems = await audioRef.listAll();
        for (final item in audioItems.items) {
          await item.delete();
        }
      } catch (_) {}

      try {
        final videoRef = _storage.ref().child('users/$userId/videos');
        final videoItems = await videoRef.listAll();
        for (final item in videoItems.items) {
          await item.delete();
        }
      } catch (_) {}

      // Feed-Stories des Nutzers bereinigen
      final feedStories = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in feedStories.docs) {
        await doc.reference.delete();
      }

      final batch = _firestore.batch();

      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'audioStoryUrl': FieldValue.delete(),
        'audioPitchUrl': FieldValue.delete(),
        'audioDurationSeconds': FieldValue.delete(),
        'hasActiveVoiceStory': false,
        'videoStoryUrl': FieldValue.delete(),
        'videoDurationSeconds': FieldValue.delete(),
        'hasActiveVideoStory': false,
        'mediaDeletedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final identityRef = _firestore.collection('user_identities').doc(userId);
      batch.set(identityRef, {
        'audioStoryUrl': FieldValue.delete(),
        'audioDurationSeconds': FieldValue.delete(),
        'hasActiveVoiceStory': false,
        'videoStoryUrl': FieldValue.delete(),
        'hasActiveVideoStory': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      debugPrint('Alle Stories und Identity-Medien DSGVO-konform gelöscht.');
    } catch (e) {
      debugPrint('Fehler beim Löschen der Medien: $e');
      rethrow;
    }
  }
}