import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

// Passt die Imports ggf. an eure Pfade in 'lib/core/...' an
import '../../../core/theme/storyjob_theme.dart';
import '../../../core/services/app_services.dart';

// ============================================================================
// MY PROFILE SCREEN (INCL. 5 STATISTIKKARTEN & HELLES DESIGN)
// ============================================================================
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final AudioPlayer _profileAudioPlayer = AudioPlayer();
  bool _isPlayingMyStory = false;
  final bool _hasActiveVoicy = true;

  @override
  void dispose() {
    _profileAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleMyStory() async {
    if (!_hasActiveVoicy) return;

    if (_isPlayingMyStory) {
      await _profileAudioPlayer.pause();
      setState(() => _isPlayingMyStory = false);
    } else {
      await _profileAudioPlayer.play(
        UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3'),
      );
      setState(() => _isPlayingMyStory = true);
    }

    _profileAudioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlayingMyStory = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = AppServices.auth.currentUser?.uid ?? 'guest';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Meine Story & Profil',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: AppServices.db.collection('profiles').doc(currentUid).snapshots(),
        builder: (context, snapshot) {
          // 1. SICHERHEITSABRUF FÜR FLUTTER WEB (Muss als allererstes stehen!):
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Lade Profil-Daten...',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            );
          }

          String matchScoreStr = '97.4%';
          int playsCount = 142;
          int contactsCount = 18;
          int likesCount = 34;
          int profileViews = 210;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            if (data['matchScore'] != null) {
              matchScoreStr = '${data['matchScore']}%';
            }
            playsCount = data['playsCount'] ?? playsCount;
            contactsCount = data['contactsCount'] ?? contactsCount;
            likesCount = data['likesCount'] ?? likesCount;
            profileViews = data['profileViews'] ?? profileViews;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Audio Player Card mit Waveform
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleMyStory,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF818CF8),
                              ),
                              child: Icon(
                                _isPlayingMyStory ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Meine Voice Story',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isPlayingMyStory ? 'Wird abgespielt...' : '0:48 min • Bereit',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 36,
                        child: CustomPaint(
                          painter: WaveformPainter(isPlaying: _isPlayingMyStory),
                          child: Container(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. 5 Statistikkarten (Horizontal Scrollbar)
                StatsSection(
                  matchScore: matchScoreStr,
                  playsCount: playsCount,
                  contactsCount: contactsCount,
                  likesCount: likesCount,
                  profileViews: profileViews,
                ),

                const SizedBox(height: 20),

                // 3. Mensch & Engagement Card
                const WerBinIchNochCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 5 STATISTIKKARTEN WIDGET
// ============================================================================
class StatsSection extends StatelessWidget {
  final String matchScore;
  final int playsCount;
  final int contactsCount;
  final int likesCount;
  final int profileViews;

  const StatsSection({
    super.key,
    required this.matchScore,
    required this.playsCount,
    required this.contactsCount,
    required this.likesCount,
    required this.profileViews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            'Statistiken & Impact',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 105,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildStatCard(
                emojiIcon: '🔥',
                value: matchScore,
                label: 'Match Score',
                color: const Color(0xFFFF9F43),
              ),
              _buildStatCard(
                iconData: Icons.headphones_rounded,
                value: '$playsCount',
                label: 'Lauscher',
                color: const Color(0xFF06B6D4),
              ),
              _buildStatCard(
                iconData: Icons.chat_bubble_rounded,
                value: '$contactsCount',
                label: 'Kontakte',
                color: const Color(0xFFA855F7),
              ),
              _buildStatCard(
                iconData: Icons.favorite_rounded,
                value: '$likesCount',
                label: 'Gemerkt',
                color: const Color(0xFFEC4899),
              ),
              _buildStatCard(
                iconData: Icons.remove_red_eye_rounded,
                value: '$profileViews',
                label: 'Aufrufe',
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    String? emojiIcon,
    IconData? iconData,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (emojiIcon != null)
            Text(emojiIcon, style: const TextStyle(fontSize: 18))
          else if (iconData != null)
            Icon(iconData, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MENSCH & ENGAGEMENT WIDGET
// ============================================================================
class WerBinIchNochCard extends StatelessWidget {
  const WerBinIchNochCard({super.key});

  static const List<Map<String, dynamic>> _tags = [
    {'name': 'BRK', 'color': Color(0xFFEC4899)},
    {'name': 'Feuerwehr', 'color': Color(0xFFEC4899)},
    {'name': 'Angeln', 'color': Color(0xFF06B6D4)},
    {'name': 'Technik', 'color': Color(0xFF06B6D4)},
    {'name': 'PV', 'color': Color(0xFFA855F7)},
    {'name': 'Smart Home', 'color': Color(0xFFA855F7)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: directRangeCheckNamePlaceholderOrSimilar... // (unverändert)
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF06B6D4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mensch & Engagement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _tags.map((tag) {
              final Color color = tag['color'];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Text(
                  tag['name'],
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}