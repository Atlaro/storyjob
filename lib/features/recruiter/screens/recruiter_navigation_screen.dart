// lib/features/recruiter/screens/recruiter_navigation_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/recruiter/screens/recruiter_dashboard_screen.dart';
import 'package:storyjob/features/recruiter/screens/recruiter_talent_pool_screen.dart';
import 'package:storyjob/features/recruiter/screens/company_dna_screen.dart';
import 'package:storyjob/features/record/screens/video_recording_screen.dart';
import 'package:storyjob/features/voice/screens/voice_story_recorder_screen.dart';
import 'package:storyjob/features/settings/screens/settings_screen.dart';

class RecruiterNavigationScreen extends StatefulWidget {
  const RecruiterNavigationScreen({super.key});

  @override
  State<RecruiterNavigationScreen> createState() => _RecruiterNavigationScreenState();
}

class _RecruiterNavigationScreenState extends State<RecruiterNavigationScreen>
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

    _pages = [
      const RecruiterDashboardScreen(),
      const RecruiterTalentPoolScreen(),
      const CompanyDnaScreen(),
      const SettingsScreen(),
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

  /// Recruiter Action-Hub: Echter Einblick auf Augenhöhe statt Textanzeigen
  void _openRecruiterActionHub() {
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
                  'Team-Kultur sprechen lassen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Keine Standard-Stellenanzeigen. Zeigt eure gelebten Werte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionTile(
                  icon: Icons.mic_rounded,
                  badgeText: '30 Sek.',
                  title: '🎙️  Team-Stimme aufnehmen',
                  subtitle: 'Beantwortet eine Frage zu Teamkultur & Miteinander',
                  color: StoryJobTheme.cyanAccent,
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
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.videocam_rounded,
                  badgeText: '60 Sek.',
                  title: '📹  Team- & Werte-Impuls',
                  subtitle: 'Stellt eine Chance oder eure Werkstatt im Kurzvideo vor',
                  color: StoryJobTheme.pinkMagenta,
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
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.hub_rounded,
                  badgeText: 'Kultur',
                  title: '✨  Firmen-DNA schärfen',
                  subtitle: 'Werte, Kulturmerkmale & Arbeitsweise pflegen',
                  color: StoryJobTheme.primaryViolet,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _currentIndex = 2);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String badgeText,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      borderRadius: 22,
      borderGradient: StoryJobTheme.dnaCardBorder,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 14),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: color,
                          fontSize: 10.5,
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
                    fontSize: 12,
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
            size: 13,
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
                  painter: _RecruiterNotchedNavPainter(),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Übersicht',
                    index: 0,
                    activeColor: StoryJobTheme.cyanAccent,
                  ),
                  _buildNavItem(
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_alt_rounded,
                    label: 'Macher',
                    index: 1,
                    activeColor: StoryJobTheme.primaryViolet,
                  ),
                  const SizedBox(width: 56),
                  _buildNavItem(
                    icon: Icons.corporate_fare_outlined,
                    activeIcon: Icons.corporate_fare_rounded,
                    label: 'Firmen-DNA',
                    index: 2,
                    activeColor: StoryJobTheme.pinkMagenta,
                  ),
                  _buildNavItem(
                    icon: Icons.tune_rounded,
                    activeIcon: Icons.tune_rounded,
                    label: 'Setup',
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
                    onTap: _openRecruiterActionHub,
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
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GESCHWUNGENE CRADLE-NOTCH KONTUR FÜR ARBEITGEBER
// ============================================================================
class _RecruiterNotchedNavPainter extends CustomPainter {
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