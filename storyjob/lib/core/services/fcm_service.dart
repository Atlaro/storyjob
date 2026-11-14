// lib/core/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeFcm({Function(Map<String, dynamic> data)? onNotificationClick}) async {
    try {
      // 1. Berechtigungen anfordern
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM: Push-Berechtigung erteilt.');

        // 2. Token abholen & speichern (sofern bereits eingeloggt)
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveTokenToDatabase(token);
        }

        // 3. Token-Aktualisierungen überwachen
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          _saveTokenToDatabase(newToken);
        });

        // 4. Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FCM Foreground: ${message.notification?.title}');
        });

        // 5. Klick auf Push-Mitteilung aus dem Hintergrund (DeepLink-Hook)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('FCM geöffnete Mitteilung: ${message.data}');
          if (onNotificationClick != null) {
            onNotificationClick(message.data);
          }
        });

        // 6. Klick auf Push-Mitteilung bei komplett geschlossener App
        final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null && onNotificationClick != null) {
          onNotificationClick(initialMessage.data);
        }
      } else {
        debugPrint('FCM: Berechtigung verweigert oder eingeschränkt.');
      }
    } catch (e) {
      debugPrint('FCM Initialisierungsfehler: $e');
    }
  }

  /// Wird nach erfolgreichem Login oder Registrieren aufgerufen,
  /// um das Token sicher dem User-Dokument zuzuordnen
  Future<void> syncTokenAfterLogin() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
    } catch (e) {
      debugPrint('FCM Token-Sync Fehler: $e');
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('FCM Token erfolgreich in Firestore hinterlegt.');
      } catch (e) {
        debugPrint('Fehler beim Speichern des FCM Tokens: $e');
      }
    }
  }
}