// lib/features/talent/screens/talent_navigation_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/match/screens/story_match_screen.dart';
import 'package:storyjob/features/profile/screens/user_growth_profile_screen.dart';
import 'package:storyjob/features/profile/screens/my_story_screen.dart';
import 'package:storyjob/features/record/screens/video_recording_screen.dart';
import 'package:storyjob/features/voice/screens/voice_story_recorder_screen.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class TalentNavigationScreen extends StatefulWidget {
  const TalentNavigationScreen({super.key});

  @override
  State<TalentNavigationScreen> createState() => _TalentNavigationScreenState();
}

class _TalentNavigationScreenState extends State<TalentNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    _pages = [
      const _TalentStoriesTab(),
      const StoryMatchScreen(),
      UserGrowthProfileScreen(
        userId: currentUserId,
        identity: const StoryIdentity(),
      ),
      const MyStoryScreen(),
    ];
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  void _openStoryCreationHub() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.50),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Wähle deine Story',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Echte Persönlichkeit statt Lebenslauf auf Papier.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 26),
                _buildModernStoryCard(
                  icon: Icons.mic_rounded,
                  iconColor: StoryJobTheme.cyanAccent,
                  badgeText: '30 Sek.',
                  title: '🎙️  Voice Story',
                  subtitle: 'Deine Stimme. Deine Geschichte.',
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VoiceStoryRecorderScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildModernStoryCard(
                  icon: Icons.videocam_rounded,
                  iconColor: StoryJobTheme.pinkMagenta,
                  badgeText: 'Kurzclip',
                  title: '📹  Video Story',
                  subtitle: 'Zeige, wer du wirklich bist.',
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VideoRecordingScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStoryCard({
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: 22,
      borderGradient: StoryJobTheme.dnaCardBorder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.16),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.45),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: StoryJobTheme.textMuted.withValues(alpha: 0.7),
            size: 14,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 74,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: CustomPaint(
                  size: const Size(double.infinity, 74),
                  painter: _NotchedNavBorderPainter(),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: 'Stories',
                    index: 0,
                    activeColor: StoryJobTheme.cyanAccent,
                  ),
                  _buildNavItem(
                    icon: Icons.bolt_outlined,
                    activeIcon: Icons.bolt_rounded,
                    label: 'Match',
                    index: 1,
                    activeColor: StoryJobTheme.primaryViolet,
                  ),
                  const SizedBox(width: 56),
                  _buildNavItem(
                    icon: Icons.fingerprint_rounded,
                    activeIcon: Icons.fingerprint_rounded,
                    label: 'StoryJob DNA',
                    index: 2,
                    activeColor: StoryJobTheme.pinkMagenta,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profil',
                    index: 3,
                    activeColor: StoryJobTheme.cyanAccent,
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final double verticalOffset = -12 + (_pulseAnimation.value - 1.0) * 8;

                return Positioned(
                  top: verticalOffset,
                  child: GestureDetector(
                    onTap: _openStoryCreationHub,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 56 * _pulseAnimation.value,
                          height: 56 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.30),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                StoryJobTheme.cyanAccent,
                                StoryJobTheme.primaryViolet,
                                StoryJobTheme.pinkMagenta,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.50),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final bool isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : StoryJobTheme.textMuted,
              size: 21,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textMuted,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GESCHWUNGENE CRADLE-NOTCH KONTUR
// ============================================================================
class _NotchedNavBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double center = width / 2;
    const double notchRadius = 35.0;
    const double notchDepth = 13.0;
    const double shoulderWidth = 14.0;

    final fillPaint = Paint()
      ..color = StoryJobTheme.backgroundBase.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = StoryJobTheme.cardBorder.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(center - notchRadius - shoulderWidth, 0);
    path.cubicTo(center - notchRadius, 0, center - notchRadius + 5, notchDepth, center, notchDepth);
    path.cubicTo(center + notchRadius - 5, notchDepth, center + notchRadius, 0, center + notchRadius + shoulderWidth, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, fillPaint);

    final borderPath = Path();
    borderPath.moveTo(0, 0);
    borderPath.lineTo(center - notchRadius - shoulderWidth, 0);
    borderPath.cubicTo(center - notchRadius, 0, center - notchRadius + 5, notchDepth, center, notchDepth);
    borderPath.cubicTo(center + notchRadius - 5, notchDepth, center + notchRadius, 0, center + notchRadius + shoulderWidth, 0);
    borderPath.lineTo(width, 0);
    canvas.drawPath(borderPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// STORIES FEED TAB
// ============================================================================
class _TalentStoriesTab extends StatefulWidget {
  const _TalentStoriesTab();

  @override
  State<_TalentStoriesTab> createState() => _TalentStoriesTabState();
}

class _TalentStoriesTabState extends State<_TalentStoriesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: StoryJobTheme.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Image.asset(
                      'assets/branding/app_icon_dark.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.auto_awesome_rounded,
                          color: StoryJobTheme.cyanAccent,
                          size: 20,
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StoryDialogScreen(
                            chatId: 'general_dialogs',
                            targetName: 'Nachrichten',
                            roleContext: 'Aktive Gespräche & Dialoge',
                            matchScore: 'StoryJob',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: StoryJobTheme.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Guten Morgen, Peter',
                style: TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: StoryJobTheme.mintSuccess,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '3 neue Teams teilen deine Werte',
                    style: TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Frage des Tages mit GlassCard
              GlassCard(
                borderRadius: 22,
                borderGradient: StoryJobTheme.dnaCardBorder,
                hasNeonGlow: true,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.graphic_eq_rounded,
                              color: StoryJobTheme.cyanAccent,
                              size: 15,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'FRAGE DES TAGES',
                              style: TextStyle(
                                color: StoryJobTheme.cyanAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cardSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: StoryJobTheme.cardBorder),
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
                    const SizedBox(height: 16),
                    const Text(
                      '„Was war dein wichtigstes Learning in einem Projekt dieses Jahr?“',
                      style: TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VoiceStoryRecorderScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.mic_rounded, size: 18, color: StoryJobTheme.cyanAccent),
                        label: const Text(
                          'Antwort aufnehmen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: StoryJobTheme.textPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Text('🔥', style: TextStyle(fontSize: 13)),
                        SizedBox(width: 6),
                        Text(
                          '4 Tage aktiv',
                          style: TextStyle(
                            color: StoryJobTheme.amberEnergy,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '  •  Noch 1 Antwort für mehr Sichtbarkeit',
                          style: TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Metrik-Kacheln
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.bolt_rounded, size: 15, color: StoryJobTheme.primaryViolet),
                              SizedBox(width: 6),
                              Text(
                                'Werte-Matches',
                                style: TextStyle(
                                  color: StoryJobTheme.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '12',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '3 warten auf Dialog',
                            style: TextStyle(
                              color: StoryJobTheme.primaryViolet,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.headphones_rounded, size: 15, color: StoryJobTheme.cyanAccent),
                              SizedBox(width: 6),
                              Text(
                                'Deine Story',
                                style: TextStyle(
                                  color: StoryJobTheme.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '37',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Teams haben zugehört',
                            style: TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Aus der Community
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 14,
                        decoration: BoxDecoration(
                          color: StoryJobTheme.amberEnergy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Aus der Community',
                        style: TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Alle hören',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 126,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  children: [
                    _buildCommunityAudioCard(
                      author: 'Sarah M.',
                      role: 'Product Designerin',
                      duration: '0:28',
                      tag: 'Kreativität',
                      tagColor: StoryJobTheme.cyanAccent,
                    ),
                    _buildCommunityAudioCard(
                      author: 'Tobias K.',
                      role: 'Tech Lead',
                      duration: '0:31',
                      tag: 'Teamkultur',
                      tagColor: StoryJobTheme.primaryViolet,
                    ),
                    _buildCommunityAudioCard(
                      author: 'Elena R.',
                      role: 'Brand Stratege',
                      duration: '0:24',
                      tag: 'Werte & Sinn',
                      tagColor: StoryJobTheme.pinkMagenta,
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

  Widget _buildCommunityAudioCard({
    required String author,
    required String role,
    required String duration,
    required String tag,
    required Color tagColor,
  }) {
    return GlassCard(
      borderRadius: 20,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      borderColor: tagColor.withValues(alpha: 0.3),
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  duration,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tagColor.withValues(alpha: 0.16),
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: tagColor, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}