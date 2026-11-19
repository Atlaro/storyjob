// lib/features/community/screens/community_network_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/story_symbiosis_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';

class CommunityNetworkScreen extends StatefulWidget {
  final bool isTeamView;

  const CommunityNetworkScreen({
    super.key,
    this.isTeamView = false,
  });

  @override
  State<CommunityNetworkScreen> createState() => _CommunityNetworkScreenState();
}

class _CommunityNetworkScreenState extends State<CommunityNetworkScreen> {
  final _joinedCircles = <String>{};

  static const _circles = [
    {
      'id': 'ehrenamt_einsatzkraefte',
      'title': '🚒 Ehrenamt & Einsatzkräfte',
      'subtitle': 'Einsatzwesen, Rettungsdienst & Katastrophenschutz.',
      'tag': 'Werte: Krisenfestigkeit & Verantwortung',
      'accentColor': StoryJobTheme.neonPink,
      'badgeLabel': 'Regional aktiv',
      'spotlightName': 'BRK & Team-Initiativen',
      'spotlightContext': 'Kreis Ehrenamt & Einsatzkräfte',
      'resonanceLabel': 'Hohe Werte-Passung ✨',
    },
    {
      'id': 'innovation_zukunft',
      'title': '🚀 Innovation & Zukunft',
      'subtitle': 'Macher, Developer & Pioniere mit Gestaltungsdrang.',
      'tag': 'Werte: Mut, Eigeninitiative & Neugier',
      'accentColor': StoryJobTheme.cyanAccent,
      'badgeLabel': 'Ecosystem',
      'spotlightName': 'Future Builders & Teams',
      'spotlightContext': 'Kreis Innovation & Zukunft',
      'resonanceLabel': 'Starke Impuls-Passung ✨',
    },
    {
      'id': 'nachhaltigkeit_region',
      'title': '🌱 Nachhaltigkeit & Region',
      'subtitle': 'Gemeinschaftsprojekte und ökologischer Weitblick vor Ort.',
      'tag': 'Werte: Weitsicht & Zusammenhalt',
      'accentColor': StoryJobTheme.emeraldGreen,
      'badgeLabel': 'Regional aktiv',
      'spotlightName': 'Regionale Impact-Teams',
      'spotlightContext': 'Kreis Nachhaltigkeit & Region',
      'resonanceLabel': 'Geteilte Vision ✨',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCircles();
  }

  Future _loadUserCircles() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('story_identities')
          .doc(userId)
          .get();
      final data = doc.data();
      final rawCommunities = data?['communities'];
      if (rawCommunities is List && mounted) {
        setState(() {
          _joinedCircles
            ..clear()
            ..addAll(rawCommunities.map((e) => e.toString()));
        });
      }
    } catch (_) {
      // Bei Offline/Gast-Modus bleibt die lokale Auswahl aktiv
    }
  }

  Future _toggleCircle(Map circle) async {
    final circleId = circle['id'] as String;
    final circleTitle = circle['title'] as String;
    final willJoin = !_joinedCircles.contains(circleId);

    HapticFeedback.lightImpact();
    setState(() {
      if (willJoin) {
        _joinedCircles.add(circleId);
      } else {
        _joinedCircles.remove(circleId);
      }
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('story_identities')
            .doc(userId)
            .set({
          'userId': userId,
          'communities': willJoin
              ? FieldValue.arrayUnion([circleId])
              : FieldValue.arrayRemove([circleId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willJoin
              ? 'Du bist jetzt im Kreis „$circleTitle“ aktiv.'
              : 'Kreis „$circleTitle“ verlassen.',
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
  Widget build(BuildContext context) {
    final roleTag = widget.isTeamView ? 'TEAM DNA' : 'TALENT DNA';
    final roleColor = widget.isTeamView
        ? StoryJobTheme.primaryViolet
        : StoryJobTheme.cyanAccent;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Werte-Passung-Kreise™',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.3),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.2),
              size: 260,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: roleColor.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Text(
                          'StoryJob • $roleTag',
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_joinedCircles.length} Kreise aktiv',
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gemeinsam mehr bewirken',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Werte-Passung-Kreise verbinden Menschen, Teams und Initiativen über gelebte Werte und Engagement – nicht über Reichweite.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: StoryJobTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._circles.map((circle) {
                    final circleId = circle['id'] as String;
                    final isJoined = _joinedCircles.contains(circleId);
                    final accentColor = circle['accentColor'] as Color;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildResonanceCircleCard(
                        circle: circle,
                        isJoined: isJoined,
                        accentColor: accentColor,
                        onToggleJoin: () => _toggleCircle(circle),
                        onStartDialog: () {
                          HapticFeedback.mediumImpact();
                          StorySymbiosisService.openOrCreateDialog(
                            context,
                            targetName: circle['spotlightName'] as String,
                            roleContext: circle['spotlightContext'] as String,
                            matchScore: circle['resonanceLabel'] as String,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResonanceCircleCard({
    required Map circle,
    required bool isJoined,
    required Color accentColor,
    required VoidCallback onToggleJoin,
    required VoidCallback onStartDialog,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  circle['title'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: StoryJobTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  circle['badgeLabel'] as String,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            circle['subtitle'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: StoryJobTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              circle['tag'] as String,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggleJoin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isJoined ? accentColor : StoryJobTheme.textPrimary,
                    side: BorderSide(
                      color: isJoined
                          ? accentColor.withValues(alpha: 0.70)
                          : StoryJobTheme.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isJoined ? 'Im Kreis aktiv ✓' : 'Kreis beitreten',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStartDialog,
                  icon: const Icon(Icons.forum_rounded, size: 14),
                  label: const Text(
                    'Austausch starten',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}