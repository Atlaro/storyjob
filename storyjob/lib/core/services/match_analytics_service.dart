// lib/core/services/match_analytics_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class MatchAnalyticsService with WidgetsBindingObserver {
  static final MatchAnalyticsService _instance = MatchAnalyticsService._internal();
  factory MatchAnalyticsService() => _instance;

  MatchAnalyticsService._internal() {
    WidgetsBinding.instance.addObserver(this);
    _startBatchTimer();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List _eventQueue = [];
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

  void track({
    required String eventType,
    required String targetId,
    required String targetRole,
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

    if (_eventQueue.length >= maxQueueCapacity) {
      _eventQueue.removeAt(0);
    }

    _eventQueue.add(event);

    if (immediateFlush || _eventQueue.length >= maxBatchSize) {
      flush();
    }
  }

  Future<void> flush() async {
    if (_eventQueue.isEmpty || _isFlushing) return;

    _isFlushing = true;
    final eventsToSend = List.from(_eventQueue);
    _eventQueue.clear();

    try {
      final batch = _firestore.batch();
      final collection = _firestore.collection('resonance_events');

      for (final dynamic item in eventsToSend) {
        final Map event = item as Map;
        final docRef = collection.doc(event['eventId'] as String);
        batch.set(docRef, Map<String, dynamic>.from(event));
      }

      await batch.commit();
      debugPrint('⚡ [MatchAnalytics] ${eventsToSend.length} Signale erfolgreich gespeichert.');
    } catch (e) {
      debugPrint('❌ [MatchAnalytics] Fehler beim Batch-Schreiben: $e');
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
      flush();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushTimer?.cancel();
    flush();
  }
}

typedef ResonanceAnalyticsService = MatchAnalyticsService;