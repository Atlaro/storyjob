// lib/features/feed/screens/stories_feed_screen.dart
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/services/audio_cache_service.dart';
import 'package:storyjob/core/services/resonance_analytics_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/feed/models/story_model.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';
import 'package:storyjob/features/match/services/story_resonance_engine.dart';
import 'package:storyjob/features/match/services/matching_service.dart';
import 'package:storyjob/features/navigation/widgets/story_app_bar.dart';
import 'package:storyjob/features/profile/screens/profile_detail_screen.dart';
import 'package:storyjob/features/record/screens/story_recording_screen.dart';

class StoriesFeedScreen extends StatefulWidget {
  final String? userId;
  final bool isRecruiter;
  final Function(int targetIndex)? onNavigateToTab;

  const StoriesFeedScreen({
    super.key,
    this.userId,
    this.isRecruiter = false,
    this.onNavigateToTab,
  });

  @override
  State<StoriesFeedScreen> createState() => _StoriesFeedScreenState();
}

class _StoriesFeedScreenState extends State<StoriesFeedScreen>
    with SingleTickerProviderStateMixin {
  final StoryIdentityService _identityService = StoryIdentityService();
  final ResonanceAnalyticsService _analytics = ResonanceAnalyticsService();

  String get _currentUserId =>
      widget.userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ').first;
    }
    return widget.isRecruiter ? 'Gestalter' : 'Macher';
  }

  final int _unreadMessagesCount = 1;

  final StoryIdentity _fallbackIdentity = const StoryIdentity(
    interests: ['Innovation', 'Nachhaltigkeit', 'Gemeinschaft'],
    values: ['Verantwortung', 'Teamgeist', 'Echtheit'],
    goals: ['Etwas Sinnvolles bewegen'],
    workstyle: ['Flexible Arbeitsweise', 'Eigenverantwortung'],
    motivators: ['Sinnstiftender Impact'],
    strengths: ['Analytisches Denken', 'Macher-Mentalität'],
    communities: ['Region & Handwerk', 'Katastrophenschutz'],
    learningInterests: ['Zukunftstechnologien', 'Leadership'],
    impactVision: 'Arbeit und Gemeinschaft im Einklang mit echten Werten gestalten.',
  );

  StoryIdentity? _cachedMyIdentity;
  String _selectedFilterCategory = 'Alle';

  final List<String> _resonanceFilters = const [
    'Alle',
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

  String get _pullSlogan => widget.isRecruiter
      ? 'Ziehen für neue Mitstreiter...'
      : 'Ziehen für neue Chancen...';

  String get _refreshSlogan => 'Wellenlängen synchronisieren...';

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
      if (mounted) {
        setState(() {
          _autoPlayEnabled = prefs.getBool('voice_auto_play') ?? true;
          _cachedMyIdentity = identity ?? _fallbackIdentity;
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
    final hour = DateTime.now().hour;
    if (widget.isRecruiter) {
      if (hour >= 5 && hour < 12) {
        return 'Finde heute Menschen, die für eure Kultur brennen.';
      } else if (hour >= 12 && hour < 18) {
        return 'Entdecke Macher, die eure Haltung teilen.';
      } else {
        return 'Erlebe neue Team-Fits und Stimmen in Ruhe.';
      }
    } else {
      if (hour >= 5 && hour < 12) {
        return 'Starte inspiriert – zeig der Welt, wie du tickst.';
      } else if (hour >= 12 && hour < 18) {
        return 'Kein Lebenslauf: Lass deine Werte & Stimme sprechen.';
      } else {
        return 'Zeit für dich: Entdecke Chancen auf deiner Wellenlänge.';
      }
    }
  }

  void _onFilterCategorySelected(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedFilterCategory = category;
    });

    _analytics.track(
      eventType: 'filter_selected',
      targetId: category,
      targetRole: 'system',
      screen: 'stories_feed',
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

  @override
  Widget build(BuildContext context) {
    final double indicatorProgress =
        (_pullDistance / _refreshTriggerThreshold).clamp(0.0, 1.0);
    final double bannerHeight =
        _isLoading ? 56.0 : (_pullDistance * 0.6).clamp(0.0, 56.0);

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
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(18.0, 6.0, 18.0, 100.0),
                  children: [
                    // 1. BEGRÜSSUNG
                    Text(
                      _getTimeBasedGreeting(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: StoryJobTheme.textSecondary,
                      ),
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

                    // 2. DIALOG-STATUS
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onNavigateToTab?.call(1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cardSurfaceElevated,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _unreadMessagesCount > 0
                                ? StoryJobTheme.cyanAccent.withValues(alpha: 0.35)
                                : StoryJobTheme.cardBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _unreadMessagesCount > 0
                                  ? Icons.chat_bubble_rounded
                                  : Icons.chat_bubble_outline_rounded,
                              color: _unreadMessagesCount > 0
                                  ? StoryJobTheme.cyanAccent
                                  : StoryJobTheme.textMuted,
                              size: 19,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _unreadMessagesCount > 0
                                    ? 'Du hast neue Dialoge im Postfach'
                                    : 'Keine neuen Dialoge in der Übersicht',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: StoryJobTheme.textPrimary.withValues(alpha: 0.9),
                                  fontWeight: _unreadMessagesCount > 0
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
                    ),
                    const SizedBox(height: 14),

                    // 3. DNA STATUS-BANNER
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
                                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                                border: Border.all(
                                  color: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'STORYJOB DNA',
                                        style: TextStyle(
                                          color: StoryJobTheme.cyanAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Sichtbar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Werte & Haltung entfaltet',
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

                    // 4. IMPULS-KACHELN
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  const Text(
                                    '12',
                                    style: TextStyle(
                                      color: StoryJobTheme.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Werte-Treffer',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  const Text(
                                    '37',
                                    style: TextStyle(
                                      color: StoryJobTheme.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Stimm-Eindrücke',
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

                    // 5. DAILY AUDIO SPARK
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

                    // 6. FILTER-LEISTE
                    Row(
                      children: [
                        Text(
                          widget.isRecruiter
                              ? 'Macher auf eurer Wellenlänge'
                              : 'Menschen auf deiner Wellenlänge',
                          style: const TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.3)),
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
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _resonanceFilters[index];
                          final isSelected = _selectedFilterCategory == category;
                          return GestureDetector(
                            onTap: () => _onFilterCategorySelected(category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? StoryJobTheme.primaryViolet.withValues(alpha: 0.22)
                                    : StoryJobTheme.cardSurfaceElevated,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? StoryJobTheme.primaryViolet.withValues(alpha: 0.6)
                                      : StoryJobTheme.cardBorder,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : StoryJobTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. STREAM DES FEEDS
                    StreamBuilder<QuerySnapshot>(
                      stream: AppServices.getStoryFeedStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: StoryJobTheme.cyanAccent,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        List<StoryModel> stories = [];
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          stories = snapshot.data!.docs
                              .map((doc) => StoryModel.fromFirestore(doc))
                              .toList();

                          if (_selectedFilterCategory != 'Alle') {
                            stories = stories.where((s) {
                              final catClean = _selectedFilterCategory
                                  .replaceAll(RegExp(r'[^\w\s]'), '')
                                  .trim()
                                  .toLowerCase();
                              return s.category.toLowerCase().contains(catClean) ||
                                  s.tags.any((t) => t.toLowerCase().contains(catClean)) ||
                                  s.values.any((v) => v.toLowerCase().contains(catClean));
                            }).toList();
                          }
                        }

                        if (stories.isEmpty) {
                          return _buildEmptyFeedState();
                        }

                        final myId = _cachedMyIdentity ?? _fallbackIdentity;

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stories.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final story = stories[index];
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

                            final resonance = StoryResonanzEngine.calculateResonance(
                              sourceIdentity: myId,
                              targetIdentity: targetIdentity,
                            );

                            return StoryResonanceCardItem(
                              story: story,
                              resonance: resonance,
                              identity: targetIdentity,
                              autoPlayEnabled: _autoPlayEnabled && index == 0,
                            );
                          },
                        );
                      },
                    ),
                  ],
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
          const Icon(Icons.graphic_eq_rounded, size: 40, color: StoryJobTheme.cyanAccent),
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
            'Noch keine Audio-Storys in dieser Kategorie. Nimm jetzt deine 30-Sekunden-Kurzgeschichte auf.',
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
                side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
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
  final ResonanceResult resonance;
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
  final ResonanceAnalyticsService _analytics = ResonanceAnalyticsService();

  bool _isPlaying = false;
  bool _hasSparked = false;
  late int _likesCount;

  int _listenSeconds = 0;
  Timer? _listenTimer;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.story.likesCount;
    if (widget.autoPlayEnabled && widget.story.audioUrl.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startCachedPlayback());
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
      final int totalSec = widget.story.durationSeconds > 0 ? widget.story.durationSeconds : 45;
      final double ratio = (_listenSeconds / totalSec).clamp(0.0, 1.0);
      final String eventType = ratio < 0.20 ? 'story_skip_early' : 'story_listen_ratio';

      _analytics.track(
        eventType: eventType,
        targetId: widget.story.userId,
        targetRole: 'creator',
        screen: 'stories_feed',
        details: {
          'storyId': widget.story.id,
          'category': widget.story.category,
          'totalDurationSec': totalSec,
          'listenedSec': _listenSeconds,
          'listenRatio': ratio,
          'matchScore': (widget.resonance.totalScore * 100).toInt(),
          'sharedValues': widget.resonance.sharedValues,
        },
      );
    }
  }

  Future<void> _startCachedPlayback() async {
    try {
      final cachedPath = await AudioCacheService.getOrFetchAudioPath(widget.story.audioUrl);
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

  void _toggleSpark() {
    HapticFeedback.lightImpact();
    setState(() {
      _hasSparked = !_hasSparked;
      _likesCount += _hasSparked ? 1 : -1;
    });

    if (_hasSparked) {
      AppServices.incrementLikes(widget.story.id);

      _analytics.track(
        eventType: 'resonance_spark_triggered',
        targetId: widget.story.userId,
        targetRole: 'creator',
        screen: 'stories_feed',
        details: {
          'storyId': widget.story.id,
          'category': widget.story.category,
          'matchScore': (widget.resonance.totalScore * 100).toInt(),
          'sharedValues': widget.resonance.sharedValues,
        },
      );
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _hasSparked
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

    _analytics.track(
      eventType: 'dialog_intent_triggered',
      targetId: widget.story.userId,
      targetRole: 'creator',
      screen: 'stories_feed',
      details: {
        'storyId': widget.story.id,
        'category': widget.story.category,
        'matchScore': '${(widget.resonance.totalScore * 100).toInt()}%',
        'sharedValues': widget.resonance.sharedValues,
      },
    );

    await _matchingService.registerTalentInterest(
      targetCompanyId: widget.story.userId,
      jobStoryId: widget.story.id,
      matchScore: '${(widget.resonance.totalScore * 100).toInt()}%',
    );

    if (!mounted) return;

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
            'matchScore': (widget.resonance.totalScore * 100).toInt(),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchPercent = (widget.resonance.totalScore * 100).toInt();

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
                backgroundColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.22),
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
                    Text(
                      widget.story.userName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: StoryJobTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
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
                  border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 13, color: StoryJobTheme.cyanAccent),
                    const SizedBox(width: 3),
                    Text(
                      '$matchPercent% Fit',
                      style: const TextStyle(
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

          // WERTE-BEGRÜNDUNG
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 14, color: StoryJobTheme.primaryViolet),
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
                          text: 'Gemeinsame Werte: ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: widget.resonance.sharedValues.isNotEmpty
                              ? widget.resonance.sharedValues.join(' • ')
                              : 'Verlässlichkeit • Teamgeist',
                          style: const TextStyle(
                            color: StoryJobTheme.cyanAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: '. Gegenseitiges Vertrauen und Anpacken stehen im Mittelpunkt.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // AUDIO PLAYER MIT SOUNDWELLE
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
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(20, (i) {
                          final h = [8, 14, 20, 12, 22, 16, 10, 24, 18, 12, 16, 20, 10, 14, 22, 16, 12, 8, 18, 14];
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

          // TAGS & SPARK
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.story.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        color: _hasSparked ? StoryJobTheme.champagneGold : StoryJobTheme.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likesCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _hasSparked ? StoryJobTheme.champagneGold : StoryJobTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // DIALOG STARTEN
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
  final ResonanceAnalyticsService _analytics = ResonanceAnalyticsService();
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
                _analytics.track(
                  eventType: 'daily_spark_tapped',
                  targetId: 'daily_prompt_reflection',
                  targetRole: 'system',
                  screen: 'stories_feed',
                  details: {'hasAnswered': _hasAnsweredToday},
                );

                if (!_hasAnsweredToday && widget.onOpenRecorder != null) {
                  widget.onOpenRecorder!();
                } else {
                  setState(() => _hasAnsweredToday = !_hasAnsweredToday);
                }
              },
              icon: Icon(
                _hasAnsweredToday ? Icons.check_circle_rounded : Icons.mic_rounded,
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