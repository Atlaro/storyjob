// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class NotificationService {
  /// Registriert den Vordergrund-Listener für In-App-Hinweise
  static void bindForegroundListener(BuildContext context, {Function(RemoteMessage)? onBannerTap}) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!context.mounted) return;

      final title = message.notification?.title ?? 'Neue Resonanz';
      final body = message.notification?.body ?? 'Es gibt Neuigkeiten zu deinen Matches.';

      showInAppBanner(
        context,
        title: title,
        body: body,
        onTap: () => onBannerTap?.call(message),
      );
    });
  }

  /// Zeigt ein dezentes In-App Banner im neuen Slate-Design
  static void showInAppBanner(
    BuildContext context, {
    required String title,
    required String body,
    VoidCallback? onTap,
  }) {
    if (!context.mounted) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              entry.remove();
              onTap?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: StoryJobTheme.cyanAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: const TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  /// Vorlagen für strukturierte Mitteilungen
  static Map<String, String> createAudioMessageNotification({required String senderName}) {
    return {
      'title': '🎤 Neue Sprachnachricht',
      'body': '$senderName hat dir eine Sprachnachricht gesendet.',
    };
  }

  static Map<String, String> createMatchNotification({required String companyName}) {
    return {
      'title': '🤝 Neuer Werte-Match',
      'body': '$companyName passt zu deinen Werten. Eine neue Chance wartet auf dich.',
    };
  }
}