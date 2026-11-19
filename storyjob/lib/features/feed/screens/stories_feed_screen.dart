// lib/features/feed/screens/stories_feed_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/services/audio_cache_service.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/services/story_symbiosis_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/feed/models/story_model.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';
import 'package:storyjob/features/match/services/matching_service.dart';
import 'package:storyjob/features/match/services/values_match_service.dart';
import 'package:storyjob/features/navigation/widgets/story_app_bar.dart';
import 'package:storyjob/features/profile/screens/profile_detail_screen.dart';
import 'package:storyjob/features/record/screens/story_recording_screen.dart';
import 'package:storyjob/features/teams/screens/company_public_profile_screen.dart';

class StoriesFeedScreen extends StatefulWidget {
  final String? userId;
  final bool isteam;
  final Function(int targetIndex)? onNavigateToTab;

  const StoriesFeedScreen({
    super.key,
    this.userId,
    this.isteam = false,
    this.onNavigateToTab,
  });

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen>
    with SingleTickerProviderStateMixin {
  final StoryIdentityService _identityService = StoryIdentityService();
  final ValuesMatchService _matchService = ValuesMatchService();

  String get _currentUserId =>
      widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ').first;
    }
    return widget.isteam ? 'Gestalter' : 'Macher';
  }

  final StoryIdentity _fallbackIdentity = const StoryIdentity(
    interests: ['Innovation', 'Nachhaltigkeit', 'Gemeinschaft'],
    values: ['Verantwortung', 'Teamgeist', 'Echtheit'],
    goals: ['Etwas Sinnvolles bewegen'],
    workstyle: ['Flexible Arbeitsweise', 'Eigenverantwortung'],
    motivators: ['Sinnstiftender Impact'],
    strengths: ['Analytisches Denken', 'Macher-Mentalität'],
    communities: ['Region & Handwerk', 'Katastrophenschutz'],
    learningInterests: ['Zukunftstechnologien', 'Leadership'],
    impactVision:
        'Arbeit und Gemeinschaft im Einklang mit echten Werten gestalten.',
    orientationMode: 'open_paths',
    isOpenForNewPaths: true,
  );

  StoryIdentity? _cachedMyIdentity;
  String _selectedFilterCategory = 'Alle';
  bool _isOpenForNewPaths = true;

  final List<String> _resonanceFilters = const [
    'Alle',
    'Neuorientierung & Halt',
    'Handwerk & Praxis',
    'Nachhaltigkeit & Sinn',
    'Innovation & Tech',
    'Ehrenamt & Einsatz',
    'Kultur & Haltung',
  ];

  late AnimationController _rotationController;
  double _pullDistance = 0.0;
  bool _isLoading = false;
  bool _autoPlayEnabled = true;
  static const double _refreshTriggerThreshold = 75.0;

  String get _pullSlogan => widget.isteam
      ? 'Ziehen für neue Talente & Mitstreiter...'
      : 'Ziehen für neue Teams & Chancen...';

  String get _refreshSlogan =>
      'Wellenlängen zwischen Talent & TEAM synchronisieren...';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _loadSettingsAndIdentity();
  }

  Future<void> _loadSettingsAndIdentity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final identity = await _identityService.loadIdentity(_currentUserId);
      final resolved = identity ?? _fallbackIdentity;
      if (mounted) {
        setState(() {
          _autoPlayEnabled = prefs.getBool('voice_auto_play') ?? true;
          _cachedMyIdentity = resolved;
          _isOpenForNewPaths =
              prefs.getBool('orientation_radar_open') ?? resolved.isOpenForNewPaths;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Initialisieren des Feeds: $e');
      if (mounted) {
        setState(() {
          _cachedMyIdentity = _fallbackIdentity;
        });
      }
    }
  }

  Future<void> _toggleOrientationRadar() async {
    HapticFeedback.mediumImpact();
    final nextValue = !_isOpenForNewPaths;
    setState(() {
      _isOpenForNewPaths = nextValue;
      if (_cachedMyIdentity != null) {
        _cachedMyIdentity = _cachedMyIdentity!.copyWith(
          isOpenForNewPaths: nextValue,
          orientationMode: nextValue ? 'new_start' : 'rooted',
        );
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('orientation_radar_open', nextValue);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        final collectionName = widget.isteam ? 'team_dnas' : 'story_identities';
        await FirebaseFirestore.instance.collection(collectionName).doc(uid).set({
          if (widget.isteam)
            'welcomesCareerChangers': nextValue
          else
            'isOpenForNewPaths': nextValue,
          'orientationMode': nextValue ? 'new_start' : 'rooted',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isteam
              ? (nextValue
                  ? 'Team-Signal aktiv: Ihr zeigt Offenheit für Quereinstieg & Neuorientierung.'
                  : 'Team-Signal pausiert.')
              : (nextValue
                  ? 'Orientierungs-Radar aktiv: Passende Teams können dich diskret über deine Werte finden.'
                  : 'Orientierungs-Radar auf ruhig gestellt.'),
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 12.5,
          ),
        ),
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: StoryJobTheme.cardBorder),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    AudioService.stopAudio();
    super.dispose();
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Guten Morgen 👋';
    } else if (hour >= 12 && hour < 18) {
      return 'Guten Tag 👋';
    } else {
      return 'Guten Abend 👋';
    }
  }

  String _getRoleAndContextSubtitle() {
    if (widget.isteam) {
      return 'Finde Menschen mit echter Haltung – und biete Talenten im Wandel eine sichere Perspektive.';
    } else {
      return 'Kostenlos & auf Augenhöhe: Entdecke Teams auf deiner Wellenlänge – frühzeitig, ehrlich und ohne Lebenslauf-Hürden.';
    }
  }

  void _onFilterCategorySelected(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedFilterCategory = category;
    });

    _matchService.logInteraction(
      eventType: 'filter_selected',
      targetId: category,
      details: {'category': category},
    );
  }

  Future<void> _triggerRefresh() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _pullDistance = _refreshTriggerThreshold;
    });
    _rotationController.repeat();

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      _rotationController.stop();
      _rotationController.reset();
      setState(() {
        _isLoading = false;
        _pullDistance = 0.0;
      });
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isLoading) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        setState(() {
          _pullDistance = -notification.metrics.pixels;
        });
      } else if (_pullDistance != 0.0) {
        setState(() {
          _pullDistance = 0.0;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_pullDistance >= _refreshTriggerThreshold) {
        _triggerRefresh();
      } else {
        setState(() {
          _pullDistance = 0.0;
        });
      }
    }
    return false;
  }

  Stream<int> _unreadNotificationsCountStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return Stream.value(0);
    }
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final double indicatorProgress =
        (_pullDistance / _refreshTriggerThreshold).clamp(0.0, 1.0);
    final double bannerHeight =
        _isLoading ? 56.0 : (_pullDistance * 0.6).clamp(0.0, 56.0);
    final activeRoleBadge = widget.isteam ? 'TEAM DNA' : 'TALENT DNA';
    final activeRoleColor =
        widget.isteam ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: const StoryAppBar(),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: bannerHeight,
                width: double.infinity,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: _isLoading ? 1.0 : indicatorProgress,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? AnimatedBuilder(
                              animation: _rotationController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: _rotationController.value * 2 * math.pi,
                                  child: child,
                                );
                              },
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: StoryJobTheme.cyanAccent,
                                size: 22,
                              ),
                            )
                          : Transform.rotate(
                              angle: indicatorProgress * math.pi,
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: StoryJobTheme.cyanAccent,
                                size: 22,
                              ),
                            ),
                      const SizedBox(width: 10),
                      Text(
                        _isLoading ? _refreshSlogan : _pullSlogan,
                        style: TextStyle(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: AppServices.getStoryFeedStream(),
                  builder: (context, snapshot) {
                    final allStories = (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty)
                        ? snapshot.data!.docs
                            .map((doc) => StoryModel.fromFirestore(doc))
                            .toList()
                        : <StoryModel>[];

                    final myId = _cachedMyIdentity ?? _fallbackIdentity;

                    int liveValuesMatches = 0;
                    int liveVoiceImpressions = 0;

                    for (final s in allStories) {
                      liveVoiceImpressions += s.playsCount + s.likesCount;
                      final targetId = StoryIdentity(
                        interests: s.tags,
                        values: s.values.isNotEmpty
                            ? s.values
                            : const ['Verantwortung', 'Teamgeist'],
                        communities: s.tags,
                        impactVision: s.category,
                      );
                      final res = ValuesMatchService.calculateMatch(
                        sourceIdentity: myId,
                        targetIdentity: targetId,
                      );
                      if (res.totalScore >= 0.65) {
                        liveValuesMatches++;
                      }
                    }

                    List<StoryModel> filteredStories = allStories;
                    if (_selectedFilterCategory == 'Neuorientierung & Halt') {
                      filteredStories = allStories.where((s) {
                        final joined =
                            '${s.category} ${s.tags.join(' ')} ${s.values.join(' ')}'
                                .toLowerCase();
                        return joined.contains('neuorientierung') ||
                            joined.contains('quereinstieg') ||
                            joined.contains('halt') ||
                            joined.contains('kultur') ||
                            joined.contains('verantwortung') ||
                            (s.organizationName != null &&
                                s.organizationName!.isNotEmpty);
                      }).toList();
                    } else if (_selectedFilterCategory != 'Alle') {
                      final catClean = _selectedFilterCategory
                          .replaceAll(RegExp(r'[^\w\s]'), '')
                          .trim()
                          .toLowerCase();
                      filteredStories = allStories.where((s) {
                        return s.category.toLowerCase().contains(catClean) ||
                            s.tags.any((t) => t.toLowerCase().contains(catClean)) ||
                            s.values.any((v) => v.toLowerCase().contains(catClean));
                      }).toList();
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 18.0, 100.0),
                      children: [
                        Row(
                          children: [
                            Text(
                              _getTimeBasedGreeting(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: StoryJobTheme.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: activeRoleColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: activeRoleColor.withValues(alpha: 0.40),
                                ),
                              ),
                              child: Text(
                                'StoryJob • $activeRoleBadge',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: activeRoleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRoleAndContextSubtitle(),
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: StoryJobTheme.cyanAccent,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _toggleOrientationRadar,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurfaceElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _isOpenForNewPaths
                                    ? StoryJobTheme.emeraldGreen
                                        .withValues(alpha: 0.45)
                                    : StoryJobTheme.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (_isOpenForNewPaths
                                            ? StoryJobTheme.emeraldGreen
                                            : StoryJobTheme.textMuted)
                                        .withValues(alpha: 0.16),
                                  ),
                                  child: Icon(
                                    _isOpenForNewPaths
                                        ? Icons.explore_rounded
                                        : Icons.explore_off_rounded,
                                    color: _isOpenForNewPaths
                                        ? StoryJobTheme.emeraldGreen
                                        : StoryJobTheme.textMuted,
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isteam
                                            ? 'Quereinstieg- & Orientierungs-Brücke'
                                            : 'Diskreter Orientierungs-Radar (Kostenlos)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: StoryJobTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.isteam
                                            ? (_isOpenForNewPaths
                                                ? 'Aktiv: Ihr nehmt Menschen im Wandel & Quereinsteiger auf.'
                                                : 'Pausiert: Tippen zum Aktivieren.')
                                            : (_isOpenForNewPaths
                                                ? 'Aktiv: Diskret über Werte & Stimme sichtbar – ohne Lebenslauf-Risiko.'
                                                : 'Ruhig: Tippen, um dich frühzeitig für neue Wege zu öffnen.'),
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: StoryJobTheme.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (_isOpenForNewPaths
                                            ? StoryJobTheme.emeraldGreen
                                            : StoryJobTheme.cardSurface)
                                        .withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _isOpenForNewPaths ? 'Aktiv' : 'Aus',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _isOpenForNewPaths
                                          ? StoryJobTheme.emeraldGreen
                                          : StoryJobTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        StreamBuilder<int>(
                          stream: _unreadNotificationsCountStream(),
                          builder: (context, badgeSnap) {
                            final unreadCount = badgeSnap.data ?? 0;
                            final hasActivity = unreadCount > 0;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onNavigateToTab?.call(1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: StoryJobTheme.cardSurfaceElevated,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: hasActivity
                                        ? StoryJobTheme.cyanAccent
                                            .withValues(alpha: 0.35)
                                        : StoryJobTheme.cardBorder,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      hasActivity
                                          ? Icons.chat_bubble_rounded
                                          : Icons.chat_bubble_outline_rounded,
                                      color: hasActivity
                                          ? StoryJobTheme.cyanAccent
                                          : StoryJobTheme.textMuted,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        hasActivity
                                            ? 'Neue Resonanz & Dialoge im Postfach ($unreadCount)'
                                            : 'Nachrichten & Benachrichtigungen öffnen',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: StoryJobTheme.textPrimary
                                              .withValues(alpha: 0.9),
                                          fontWeight: hasActivity
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: StoryJobTheme.textMuted,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onNavigateToTab?.call(2);
                          },
                          child: GlassCard(
                            borderRadius: 20,
                            borderGradient: StoryJobTheme.dnaCardBorder,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: StoryJobTheme.primaryViolet
                                        .withValues(alpha: 0.16),
                                    border: Border.all(
                                      color: StoryJobTheme.primaryViolet
                                          .withValues(alpha: 0.4),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: StoryJobTheme.primaryViolet,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isteam
                                            ? 'STORYJOB TEAM DNA'
                                            : 'STORYJOB TALENT DNA',
                                        style: const TextStyle(
                                          color: StoryJobTheme.cyanAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Werte, Stärken & Haltung bearbeiten',
                                        style: TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: StoryJobTheme.textMuted,
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onNavigateToTab?.call(1);
                                },
                                child: GlassCard(
                                  borderRadius: 18,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Icon(
                                            Icons.hub_rounded,
                                            color: StoryJobTheme.primaryViolet,
                                            size: 19,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: StoryJobTheme.textMuted,
                                            size: 11,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '$liveValuesMatches',
                                        style: const TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Werte-Treffer im Feed',
                                        style: TextStyle(
                                          color: StoryJobTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onNavigateToTab?.call(3);
                                },
                                child: GlassCard(
                                  borderRadius: 18,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Icon(
                                            Icons.graphic_eq_rounded,
                                            color: StoryJobTheme.cyanAccent,
                                            size: 19,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: StoryJobTheme.textMuted,
                                            size: 11,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '$liveVoiceImpressions',
                                        style: const TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Stimm-Resonanzen',
                                        style: TextStyle(
                                          color: StoryJobTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        DailyAudioSparkWidget(
                          onOpenRecorder: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StoryRecordingScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.isteam
                                    ? 'Talente auf eurer Wellenlänge'
                                    : 'Teams & Talente auf deiner Wellenlänge',
                                style: const TextStyle(
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w700,
                                  color: StoryJobTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: StoryJobTheme.cyanAccent
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: StoryJobTheme.cyanAccent
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'Werte-Match',
                                style: TextStyle(
                                  color: StoryJobTheme.cyanAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _resonanceFilters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final category = _resonanceFilters[index];
                              final isSelected =
                                  _selectedFilterCategory == category;
                              return GestureDetector(
                                onTap: () =>
                                    _onFilterCategorySelected(category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? StoryJobTheme.primaryViolet
                                            .withValues(alpha: 0.22)
                                        : StoryJobTheme.cardSurfaceElevated,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? StoryJobTheme.primaryViolet
                                              .withValues(alpha: 0.6)
                                          : StoryJobTheme.cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : StoryJobTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            allStories.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: StoryJobTheme.cyanAccent,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else if (filteredStories.isEmpty)
                          _buildEmptyFeedState()
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredStories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final story = filteredStories[index];
                              final targetIdentity = StoryIdentity(
                                interests: story.tags,
                                values: story.values.isNotEmpty
                                    ? story.values
                                    : const ['Verantwortung', 'Teamgeist'],
                                goals: const ['Sinnvolles Bewegen'],
                                workstyle: const ['Offen', 'Pragmatisch'],
                                motivators: const ['Gemeinsamer Erfolg'],
                                strengths: const ['Einsatzbereitschaft'],
                                communities: story.tags,
                                learningInterests: const ['Innovation'],
                                impactVision: story.category,
                              );

                              final resonance =
                                  ValuesMatchService.calculateMatch(
                                sourceIdentity: myId,
                                targetIdentity: targetIdentity,
                              );

                              return StoryResonanceCardItem(
                                story: story,
                                resonance: resonance,
                                identity: targetIdentity,
                                autoPlayEnabled:
                                    _autoPlayEnabled && index == 0,
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFeedState() {
    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(
            Icons.graphic_eq_rounded,
            size: 40,
            color: StoryJobTheme.cyanAccent,
          ),
          const SizedBox(height: 12),
          const Text(
            'Lass deine Stimme hören',
            style: TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Noch keine Audio-Storys in dieser Kategorie. Nimm jetzt deine 30-Sekunden-Kurzgeschichte auf und werde über deine Werte sichtbar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
              foregroundColor: StoryJobTheme.cyanAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StoryRecordingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.mic_rounded, size: 17),
            label: const Text(
              'Story einsprechen',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryResonanceCardItem extends StatefulWidget {
  final StoryModel story;
  final ValuesMatchResult resonance;
  final StoryIdentity identity;
  final bool autoPlayEnabled;

  const StoryResonanceCardItem({
    super.key,
    required this.story,
    required this.resonance,
    required this.identity,
    this.autoPlayEnabled = false,
  });

  @override
  State<StoryResonanceCardItem> createState() => _StoryResonanceCardItemState();
}

class _StoryResonanceCardItemState extends State<StoryResonanceCardItem> {
  final MatchingService _matchingService = MatchingService();
  final ValuesMatchService _matchService = ValuesMatchService();

  bool _isPlaying = false;
  bool _hasSparked = false;
  late int _likesCount;

  int _listenSeconds = 0;
  Timer? _listenTimer;

  bool get _isTeamContribution =>
      widget.story.organizationName != null &&
      widget.story.organizationName!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.story.likesCount;
    if (widget.autoPlayEnabled && widget.story.audioUrl.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _startCachedPlayback());
    }
  }

  @override
  void dispose() {
    _logListenRatioBeforeExit();
    _listenTimer?.cancel();
    super.dispose();
  }

  void _startListenTimer() {
    _listenTimer?.cancel();
    _listenTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPlaying) {
        _listenSeconds++;
      }
    });
  }

  void _logListenRatioBeforeExit() {
    if (_listenSeconds > 0) {
      final int totalSec =
          widget.story.durationSeconds > 0 ? widget.story.durationSeconds : 45;
      final double ratio = (_listenSeconds / totalSec).clamp(0.0, 1.0);
      final String eventType =
          ratio < 0.20 ? 'story_skip_early' : 'story_listen_ratio';

      _matchService.logInteraction(
        eventType: eventType,
        targetId: widget.story.userId,
        details: {
          'storyId': widget.story.id,
          'category': widget.story.category,
          'totalDurationSec': totalSec,
          'listenedSec': _listenSeconds,
          'listenRatio': ratio,
          'sharedValues': widget.resonance.sharedValues,
        },
      );
    }
  }

  Future<void> _startCachedPlayback() async {
    try {
      final cachedPath =
          await AudioCacheService.getOrFetchAudioPath(widget.story.audioUrl);
      await AudioService.playAudio(cachedPath);
      AppServices.incrementPlays(widget.story.id);
      if (mounted) {
        setState(() => _isPlaying = true);
        _startListenTimer();
      }
    } catch (e) {
      debugPrint('Fehler bei Wiedergabe: $e');
    }
  }

  Future<void> _togglePlay() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await AudioService.stopAudio();
      _logListenRatioBeforeExit();
      setState(() => _isPlaying = false);
    } else {
      if (widget.story.audioUrl.isNotEmpty) {
        await _startCachedPlayback();
      }
    }
  }

  Future<void> _toggleSpark() async {
    HapticFeedback.lightImpact();
    final willSpark = !_hasSparked;
    setState(() {
      _hasSparked = willSpark;
      _likesCount += willSpark ? 1 : -1;
    });

    if (willSpark) {
      AppServices.incrementLikes(widget.story.id);

      _matchService.logInteraction(
        eventType: 'resonance_spark_triggered',
        targetId: widget.story.userId,
        details: {
          'storyId': widget.story.id,
          'category': widget.story.category,
          'sharedValues': widget.resonance.sharedValues,
        },
      );

      if (widget.story.userId.isNotEmpty) {
        try {
          await StorySymbiosisService.sendStoryImpulse(
            recipientId: widget.story.userId,
            targetName: widget.story.userName,
            storyTitle: widget.story.category.isNotEmpty
                ? widget.story.category
                : 'Story',
            matchScore: 'Werte-Impuls ✨',
            type: 'favorite',
            storyDocId: widget.story.id,
          );
        } catch (_) {}
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willSpark
              ? 'Wellenlängen-Impuls an ${widget.story.userName} gesendet.'
              : 'Impuls zurückgenommen.',
          style: const TextStyle(fontSize: 12.5),
        ),
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: StoryJobTheme.cardBorder),
        ),
      ),
    );
  }

  Future<void> _handleStartDialog() async {
    HapticFeedback.mediumImpact();
    final scorePercent = (widget.resonance.totalScore * 100).toInt();

    _matchService.logInteraction(
      eventType: 'dialog_intent_triggered',
      targetId: widget.story.userId,
      details: {
        'storyId': widget.story.id,
        'category': widget.story.category,
        'sharedValues': widget.resonance.sharedValues,
      },
    );

    await _matchingService.registerTalentInterest(
      targetteamId: widget.story.userId,
      jobStoryId: widget.story.id,
      matchScore: 'Hohe Werte-Passung ✨',
      sharedValues: widget.resonance.sharedValues,
    );

    if (!mounted) return;

    if (_isTeamContribution) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompanyPublicProfileScreen(
            companyId: widget.story.userId,
            teamId: widget.story.id,
            talentUid: currentUserId,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileDetailScreen(
          profileData: {
            'userId': widget.story.userId,
            'name': widget.story.userName,
            'avatarUrl': widget.story.userAvatarUrl,
            'category': widget.story.category,
            'audioPitchUrl': widget.story.audioUrl,
            'interests': widget.identity.interests,
            'values': widget.identity.values,
            'goal': widget.identity.goals.isNotEmpty
                ? widget.identity.goals.first
                : 'Sinnstiftende Zusammenarbeit',
            'matchScore': scorePercent,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleBadgeLabel = _isTeamContribution ? 'TEAM' : 'Talent';
    final roleBadgeColor = _isTeamContribution
        ? StoryJobTheme.primaryViolet
        : StoryJobTheme.cyanAccent;

    final sharedValuesText = widget.resonance.sharedValues.isNotEmpty
        ? widget.resonance.sharedValues.join(' • ')
        : 'Verlässlichkeit • Teamgeist';

    final personalReasonSuffix = _isTeamContribution
        ? ' – dieses Team sucht Menschen mit genau deiner Haltung.'
        : ' – starke Basis für gemeinsame Projekte und Austausch.';

    return GlassCard(
      borderRadius: 22,
      borderGradient: StoryJobTheme.dnaCardBorder,
      hasNeonGlow: _isPlaying,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: roleBadgeColor.withValues(alpha: 0.22),
                backgroundImage: widget.story.userAvatarUrl.isNotEmpty
                    ? NetworkImage(widget.story.userAvatarUrl)
                    : null,
                child: widget.story.userAvatarUrl.isEmpty
                    ? Text(
                        widget.story.userName.isNotEmpty
                            ? widget.story.userName.substring(0, 1).toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.story.userName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: StoryJobTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: roleBadgeColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: roleBadgeColor.withValues(alpha: 0.40),
                            ),
                          ),
                          child: Text(
                            roleBadgeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: roleBadgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.story.organizationName != null
                          ? '${widget.story.organizationName} • ${widget.story.category}'
                          : widget.story.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StoryJobTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: StoryJobTheme.cyanAccent,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Werte-Klang',
                      style: TextStyle(
                        fontSize: 11,
                        color: StoryJobTheme.cyanAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: StoryJobTheme.primaryViolet,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: StoryJobTheme.textPrimary,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Eure Brücke: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: sharedValuesText,
                          style: const TextStyle(
                            color: StoryJobTheme.cyanAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: personalReasonSuffix),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _isPlaying
                    ? StoryJobTheme.cyanAccent.withValues(alpha: 0.12)
                    : StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isPlaying
                      ? StoryJobTheme.cyanAccent.withValues(alpha: 0.45)
                      : StoryJobTheme.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          StoryJobTheme.soundWaveGradient.createShader(bounds),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(20, (i) {
                          final h = [
                            8,
                            14,
                            20,
                            12,
                            22,
                            16,
                            10,
                            24,
                            18,
                            12,
                            16,
                            20,
                            10,
                            14,
                            22,
                            16,
                            12,
                            8,
                            18,
                            14
                          ];
                          return Container(
                            width: 2.5,
                            height: _isPlaying
                                ? h[(i + _listenSeconds) % h.length].toDouble()
                                : (h[i % h.length] * 0.6).toDouble(),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.story.formattedDuration,
                    style: const TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.story.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: StoryJobTheme.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleSpark,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _hasSparked
                        ? StoryJobTheme.champagneGold.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasSparked
                          ? StoryJobTheme.champagneGold.withValues(alpha: 0.45)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _hasSparked
                            ? Icons.local_fire_department_rounded
                            : Icons.local_fire_department_outlined,
                        color: _hasSparked
                            ? StoryJobTheme.champagneGold
                            : StoryJobTheme.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _hasSparked
                              ? StoryJobTheme.champagneGold
                              : StoryJobTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _handleStartDialog,
              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
              label: const Text(
                'Story vertiefen & Dialog starten ✨',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryJobTheme.primaryViolet,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyAudioSparkWidget extends StatefulWidget {
  final VoidCallback? onOpenRecorder;

  const DailyAudioSparkWidget({super.key, this.onOpenRecorder});

  @override
  State<DailyAudioSparkWidget> createState() => _DailyAudioSparkWidgetState();
}

class _DailyAudioSparkWidgetState extends State<DailyAudioSparkWidget> {
  final ValuesMatchService _matchService = ValuesMatchService();
  bool _hasAnsweredToday = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 22,
      borderGradient: StoryJobTheme.dnaCardBorder,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.graphic_eq_rounded,
                color: StoryJobTheme.cyanAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'DAILY AUDIO SPARK',
                style: TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '30 Sek.',
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '„Was hat dir diese Woche bei der Arbeit oder in deinem Projekt die meiste Freude bereitet?“',
            style: TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasAnsweredToday
                    ? Colors.white.withValues(alpha: 0.06)
                    : StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                foregroundColor: _hasAnsweredToday
                    ? StoryJobTheme.textSecondary
                    : StoryJobTheme.cyanAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: _hasAnsweredToday
                        ? Colors.white.withValues(alpha: 0.12)
                        : StoryJobTheme.cyanAccent.withValues(alpha: 0.4),
                  ),
                ),
                elevation: 0,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _matchService.logInteraction(
                  eventType: 'daily_spark_tapped',
                  targetId: 'daily_prompt_reflection',
                  details: {'hasAnswered': _hasAnsweredToday},
                );

                if (!_hasAnsweredToday && widget.onOpenRecorder != null) {
                  widget.onOpenRecorder!();
                } else {
                  setState(() => _hasAnsweredToday = !_hasAnsweredToday);
                }
              },
              icon: Icon(
                _hasAnsweredToday
                    ? Icons.check_circle_rounded
                    : Icons.mic_rounded,
                size: 17,
              ),
              label: Text(
                _hasAnsweredToday
                    ? 'Heute eingesprochen (Antwort anhören)'
                    : 'Jetzt Antwort einsprechen',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}