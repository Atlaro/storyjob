// lib/features/messages/widgets/appointment_request_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/match/services/resonance_intelligence_service.dart';

class AppointmentRequestWidget extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final String partnerName;

  const AppointmentRequestWidget({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.partnerName,
  });

  void _showAppointmentModal(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext ctx) {
        DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
        TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kennenlernen vereinbaren',
                        style: TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: StoryJobTheme.textSecondary, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Schlage $partnerName einen unverbindlichen Austausch auf Augenhöhe vor.',
                    style: const TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Datumsauswahl Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StoryJobTheme.textPrimary,
                      side: const BorderSide(color: StoryJobTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: StoryJobTheme.cardSurface,
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: modalContext,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: StoryJobTheme.primaryViolet,
                                onPrimary: Colors.white,
                                surface: Color(0xFF1E222B),
                                onSurface: StoryJobTheme.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, color: StoryJobTheme.cyanAccent, size: 18),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Datum: ${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Uhrzeitauswahl Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StoryJobTheme.textPrimary,
                      side: const BorderSide(color: StoryJobTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: StoryJobTheme.cardSurface,
                    ),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: modalContext,
                        initialTime: selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: StoryJobTheme.primaryViolet,
                                onPrimary: Colors.white,
                                surface: Color(0xFF1E222B),
                                onSurface: StoryJobTheme.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    icon: const Icon(Icons.access_time_rounded, color: StoryJobTheme.primaryViolet, size: 18),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Uhrzeit: ${selectedTime.format(modalContext)} Uhr',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Absenden Button (Pill)
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();

                        final formattedTimeStr = selectedTime.format(modalContext);

                        final appointmentDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        // 1. Termin in Firestore anlegen
                        await FirebaseFirestore.instance.collection('appointments').add({
                          'chatId': chatId,
                          'senderId': currentUserId,
                          'partnerName': partnerName,
                          'dateTime': Timestamp.fromDate(appointmentDateTime),
                          'status': 'pending',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        // 2. Beziehungsstufe auf 'call_scheduled' aktualisieren
                        await ResonanceIntelligenceService().updateConnectionStage(
                          targetId: chatId,
                          stage: 'call_scheduled',
                        );

                        // 3. Synchron über AppServices als Chat-Nachricht senden
                        final dateStr =
                            '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';

                        await AppServices.sendMessage(
                          chatId,
                          '📅 Terminvorschlag: Kennenlernen am $dateStr um $formattedTimeStr Uhr',
                          type: 'text',
                          senderId: currentUserId,
                        );

                        if (!ctx.mounted) return;
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(ctx).pop();

                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('Terminvorschlag erfolgreich gesendet! 🤝'),
                            backgroundColor: const Color(0xFF1E222B),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: StoryJobTheme.cardBorder),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Terminvorschlag senden ✨',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.transparent,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: StoryJobTheme.cyanAccent,
          side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
        ),
        onPressed: () => _showAppointmentModal(context),
        icon: const Icon(Icons.event_available_rounded, size: 16),
        label: const Text(
          'Kennenlernen vorschlagen',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}