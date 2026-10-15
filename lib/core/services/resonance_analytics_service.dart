// lib/core/services/resonance_analytics_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class ResonanceAnalyticsService with WidgetsBindingObserver {
  static final ResonanceAnalyticsService _instance = ResonanceAnalyticsService._internal();
  factory ResonanceAnalyticsService() => _instance;

  ResonanceAnalyticsService._internal() {
    WidgetsBinding.instance.addObserver(this);
    _startBatchTimer();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _eventQueue = [];
  Timer? _flushTimer;
  bool _isFlushing = false;

  static const int maxBatchSize = 25;
  static const int maxQueueCapacity = 100;
  static const Duration flushInterval = Duration(seconds: 20);

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  void _startBatchTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(flushInterval, (_) => flush());
  }

  /// Zentraler Einstiegspunkt zum Erfassen jedes Signals
  void track({
    required String eventType,
    required String targetId,
    required String targetRole, // 'company' oder 'talent'
    required String screen,
    Map<String, dynamic>? details,
    bool immediateFlush = false,
  }) {
    final event = {
      'eventId': 'evt_${DateTime.now().millisecondsSinceEpoch}_${_eventQueue.length}',
      'eventType': eventType,
      'timestamp': FieldValue.serverTimestamp(),
      'actorId': _currentUserId,
      'targetId': targetId,
      'targetRole': targetRole,
      'screen': screen,
      'details': details ?? {},
    };

    // Speicherüberlauf verhindern bei dauerhaftem Offline-Status
    if (_eventQueue.length >= maxQueueCapacity) {
      _eventQueue.removeAt(0);
    }

    _eventQueue.add(event);

    if (immediateFlush || _eventQueue.length >= maxBatchSize) {
      flush();
    }
  }

  /// Schreibt alle gepufferten Events in einem einzigen Firestore-Batch
  Future<void> flush() async {
    if (_eventQueue.isEmpty || _isFlushing) return;

    _isFlushing = true;
    final List<Map<String, dynamic>> eventsToSend = List.from(_eventQueue);
    _eventQueue.clear();

    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('resonance_events');

      for (final event in eventsToSend) {
        final docRef = collection.doc(event['eventId'] as String);
        batch.set(docRef, event);
      }

      await batch.commit();
      debugPrint('⚡ [ResonanceAnalytics] ${eventsToSend.length} Signale erfolgreich gespeichert.');
    } catch (e) {
      debugPrint('❌ [ResonanceAnalytics] Fehler beim Batch-Schreiben: $e');
      // Begrenzt wieder einfügen ohne Speicherüberlauf
      final remainingCapacity = maxQueueCapacity - _eventQueue.length;
      if (remainingCapacity > 0) {
        _eventQueue.insertAll(0, eventsToSend.take(remainingCapacity));
      }
    } finally {
      _isFlushing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      flush(); // Offene Events vor Hintergrund-Wechsel sichern
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushTimer?.cancel();
    flush();
  }
}