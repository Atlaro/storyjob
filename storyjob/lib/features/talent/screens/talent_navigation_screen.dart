// lib/features/talent/screens/talent_navigation_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/story_pulse_status_bar.dart';
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
  final int _matchBadgeCount = 3;
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
      _TalentStoriesTab(
        onOpenCreationHub: _openStoryCreationHub,
        onNavigateToTab: _onItemTapped,
      ),
      StoryMatchScreen(
        onOpenDna: () => _onItemTapped(2),
      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: iconColor.withValues(alpha: 0.35), width: 0.8),
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
                    badgeCount: _matchBadgeCount,
                  ),
                  const SizedBox(width: 56),
                  _buildNavItem(
                    icon: Icons.fingerprint_rounded,
                    activeIcon: Icons.fingerprint_rounded,
                    label: 'DNA',
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
    int badgeCount = 0,
  }) {
    final bool isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeColor : StoryJobTheme.textMuted,
                  size: 21,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.pinkMagenta,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
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
// STORIES HOME TAB (Mit app_icon_dark.png + 24h Pulse-Status-Leiste)
// ============================================================================
class _TalentStoriesTab extends StatelessWidget {
  final VoidCallback onOpenCreationHub;
  final Function(int) onNavigateToTab;

  const _TalentStoriesTab({
    required this.onOpenCreationHub,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!.split(' ').first
        : 'Mitglied';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TOP-LEISTE MIT OFFIZIELLEM APP-ICON (app_icon_dark.png)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.asset(
                          'assets/branding/app_icon_dark.png',
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.auto_awesome_rounded,
                            color: StoryJobTheme.cyanAccent,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'Story',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Job',
                              style: TextStyle(color: StoryJobTheme.cyanAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cardSurfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: StoryJobTheme.cardBorder),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: StoryJobTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: StoryJobTheme.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 24H PULSE STATUS-LEISTE (Talente & Team-Einblicke)
              StoryPulseStatusBar(
                isRecruiter: false,
                currentUserName: firstName,
              ),

              const SizedBox(height: 20),

              // Begrüßung
              Text(
                'Guten Morgen,\n$firstName 👋',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Teile deine Werte und Stimme, um Teams zu finden, die wirklich zu dir passen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Prominenter Haupt-Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: onOpenCreationHub,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22, color: Color(0xFF0A0B10)),
                  label: const Text(
                    'Neue Story aufnehmen',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0B10),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.cyanAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Sektions-Überschrift
              GestureDetector(
                onTap: () => onNavigateToTab(1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'In deiner Wellenlänge',
                      style: TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: StoryJobTheme.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Karte 1: Matches
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                onTap: () => onNavigateToTab(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3 neue Werte-Matches entdeckt',
                      style: TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Teams aus deiner Region teilen deine Haltung zu Teamgeist & Eigenverantwortung.',
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () => onNavigateToTab(1),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StoryJobTheme.textPrimary,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: const Text('Matches ansehen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Karte 2: DNA & Daily Spark
              GlassCard(
                borderRadius: 20,
                borderGradient: StoryJobTheme.dnaCardBorder,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [StoryJobTheme.primaryViolet, StoryJobTheme.pinkMagenta],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fingerprint_rounded, color: Colors.white, size: 28),
                          SizedBox(height: 4),
                          Text(
                            'DNA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Schärfe deine StoryJob DNA',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Beantworte die Frage des Tages in 30 Sekunden für bessere Treffer.',
                            style: TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () => onNavigateToTab(2),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: StoryJobTheme.textPrimary,
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text('DNA öffnen', style: TextStyle(fontSize: 12.5)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const VoiceStoryRecorderScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: StoryJobTheme.primaryViolet,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text('Einsprechen', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}