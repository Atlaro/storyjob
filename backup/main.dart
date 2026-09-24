import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: StoryJobTheme.backgroundBase,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const StoryJobApp());
}

// ============================================================================
// 1. THEME & DESIGN SYSTEM
// ============================================================================
class StoryJobTheme {
  static const Color backgroundBase = Color(0xFF0D0B14);
  static const Color cardSurface = Color(0xFF161224);
  static const Color cardSurfaceLight = Color(0xFF201A33);
  static const Color cardBorder = Color(0xFF2D244A);

  static const Color primaryViolet = Color(0xFF8B5CF6);
  static const Color electricPurple = Color(0xFFA855F7);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color emeraldGreen = Color(0xFF10B981);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundBase,
      primaryColor: primaryViolet,
      splashColor: primaryViolet.withAlpha(50),
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: primaryViolet,
        secondary: cyanAccent,
        surface: cardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundBase,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      dividerColor: cardBorder,
    );
  }
}

// ============================================================================
// 2. DATA MODELS
// ============================================================================
class MatchReason {
  final String emoji;
  final String title;

  MatchReason({required this.emoji, required this.title});
}

class HumanMatchProfile {
  final String id;
  final String name;
  final String roleOrContext;
  final String location;
  final String duration;
  final double matchScore;
  final List<MatchReason> matchReasons;

  HumanMatchProfile({
    required this.id,
    required this.name,
    required this.roleOrContext,
    required this.location,
    required this.duration,
    required this.matchScore,
    required this.matchReasons,
  });
}

final List<HumanMatchProfile> dummyMatches = [
  HumanMatchProfile(
    id: '1',
    name: 'TechVision GmbH & Team',
    roleOrContext: 'Team Lead Systems Engineering',
    location: 'Niederbayern & Remote',
    duration: '0:45',
    matchScore: 97.4,
    matchReasons: [
      MatchReason(emoji: '🚑', title: 'BRK Engagement'),
      MatchReason(emoji: '🤝', title: 'Teamgeist'),
      MatchReason(emoji: '⚡', title: 'Eigeninitiative'),
      MatchReason(emoji: '💡', title: 'Technik Leidenschaft'),
      MatchReason(emoji: '📍', title: 'Region Niederbayern'),
    ],
  ),
  HumanMatchProfile(
    id: '2',
    name: 'GreenEnergy Solutions',
    roleOrContext: 'Projektleiter Photovoltaik & Speicher',
    location: 'Passau & Pocking',
    duration: '1:12',
    matchScore: 94.2,
    matchReasons: [
      MatchReason(emoji: '🚒', title: 'Feuerwehr'),
      MatchReason(emoji: '☀️', title: 'PV Begeisterung'),
      MatchReason(emoji: '⚡', title: 'Eigeninitiative'),
      MatchReason(emoji: '📍', title: 'Region Pocking'),
    ],
  ),
];

// ============================================================================
// 3. APP ENTRY POINT
// ============================================================================
class StoryJobApp extends StatelessWidget {
  const StoryJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob',
      debugShowCheckedModeBanner: false,
      theme: StoryJobTheme.darkTheme,
      home: const EmotionalOnboardingScreen(),
    );
  }
}

// ============================================================================
// 4. ONBOARDING SCREEN
// ============================================================================
class EmotionalOnboardingScreen extends StatefulWidget {
  const EmotionalOnboardingScreen({super.key});

  @override
  State<EmotionalOnboardingScreen> createState() => _EmotionalOnboardingScreenState();
}

class _EmotionalOnboardingScreenState extends State<EmotionalOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedOption = 0;

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationHub(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1D1438), StoryJobTheme.backgroundBase],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.primaryViolet.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mic_rounded, color: StoryJobTheme.electricPurple, size: 24),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'StoryJob',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: StoryJobTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Opacity(
                      opacity: 0.45,
                      child: Text(
                        'Human Opportunity Network',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.8,
                          color: StoryJobTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildOnboardingPage(
                      icon: Icons.graphic_eq_rounded,
                      headline: 'Die Stimme macht den Unterschied.',
                      subheadline: 'StoryJob – Erzähl, was du wirklich kannst.',
                    ),
                    _buildOnboardingPage(
                      icon: Icons.people_outline_rounded,
                      headline: 'Echte Menschen.',
                      subheadline: 'Höre die Person vor dem Lebenslauf.\n\nKein Lebenslauf. Keine Noten.\nNur deine Story.',
                    ),
                    _buildOptionPage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? StoryJobTheme.primaryViolet
                                : StoryJobTheme.cardBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoryJobTheme.primaryViolet,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: StoryJobTheme.primaryViolet.withAlpha(100),
                        ),
                        onPressed: _nextPage,
                        child: Text(
                          _currentPage == 2 ? 'StoryJob erleben' : 'Weiter',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildOnboardingPage({
    required IconData icon,
    required String headline,
    required String subheadline,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [StoryJobTheme.cardSurfaceLight, StoryJobTheme.cardSurface],
              ),
              border: Border.all(color: StoryJobTheme.primaryViolet.withAlpha(120), width: 2),
              boxShadow: [
                BoxShadow(
                  color: StoryJobTheme.primaryViolet.withAlpha(80),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Icon(icon, size: 54, color: StoryJobTheme.cyanAccent),
          ),
          const SizedBox(height: 40),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w900,
              color: StoryJobTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            subheadline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              color: StoryJobTheme.textSecondary.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionPage() {
    final List<Map<String, String>> roleOptions = [
      {
        'title': 'Ich bin Praktikant, Azubi & Einsteiger',
        'subtitle': 'Ich suche Praktika, Ausbildungsplätze oder den Einstieg ins Berufsleben.',
        'icon': 'school',
      },
      {
        'title': 'Ich bin Talent & Bewerber',
        'subtitle': 'Ich möchte Voice Stories aufnehmen und von Unternehmen entdeckt werden.',
        'icon': 'search',
      },
      {
        'title': 'Ich bin Arbeitgeber & Recruiter',
        'subtitle': 'Ich möchte Stellenangebote schalten und authentische Sprach-Talente finden.',
        'icon': 'work',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Wie möchtest du StoryJob nutzen?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w900,
              color: StoryJobTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Wähle deine Rolle, um dein Profil optimal einzurichten.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: StoryJobTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(roleOptions.length, (index) {
            final isSelected = _selectedOption == index;
            final option = roleOptions[index];

            IconData iconData;
            if (option['icon'] == 'search') {
              iconData = Icons.person_search_rounded;
            } else if (option['icon'] == 'school') {
              iconData = Icons.school_rounded;
            } else {
              iconData = Icons.business_center_rounded;
            }

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedOption = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? StoryJobTheme.primaryViolet.withAlpha(40)
                      : StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? StoryJobTheme.primaryViolet : StoryJobTheme.cardBorder,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StoryJobTheme.primaryViolet.withAlpha(30),
                      ),
                      child: Icon(
                        iconData,
                        color: StoryJobTheme.cyanAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['title']!,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            option['subtitle']!,
                            style: const TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isSelected ? StoryJobTheme.electricPurple : StoryJobTheme.textMuted,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. MAIN NAVIGATION HUB
// ============================================================================
class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Widget> _screens = const [
    StoriesFeedScreen(),
    MenschUndMatchScreen(),
    RecordStoryScreen(),
    ImpactScreen(),
    MyStoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0810).withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: StoryJobTheme.cardBorder.withValues(alpha: 0.6), width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.auto_awesome_motion_outlined, Icons.auto_awesome_motion_rounded, 'Stories'),
              _buildNavItem(1, Icons.people_outline_rounded, Icons.people_alt_rounded, 'Mensch & Match'),
              GestureDetector(
                onTap: () => _onItemTapped(2),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [StoryJobTheme.neonPink, StoryJobTheme.primaryViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedIndex == 2 ? StoryJobTheme.neonPink : StoryJobTheme.primaryViolet).withAlpha(140),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
              _buildNavItem(3, Icons.insights_outlined, Icons.insights_rounded, 'Impact'),
              _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Meine Story'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconUnselected, IconData iconSelected, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? iconSelected : iconUnselected,
            color: isSelected ? StoryJobTheme.primaryViolet : StoryJobTheme.textMuted,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. FEED SCREEN
// ============================================================================
class StoriesFeedScreen extends StatelessWidget {
  const StoriesFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Stories')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: dummyMatches.length,
        itemBuilder: (context, index) {
          final profile = dummyMatches[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: StoryJobTheme.cardSurfaceLight,
                  child: Icon(Icons.graphic_eq_rounded, color: StoryJobTheme.cyanAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(profile.roleOrContext, style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Text(profile.duration, style: const TextStyle(color: StoryJobTheme.electricPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// 7. MENSCH & MATCH SCREEN
// ============================================================================
class MenschUndMatchScreen extends StatelessWidget {
  const MenschUndMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensch & Match')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.handshake_rounded, color: StoryJobTheme.cyanAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Matching basiert auf Engagement, Werte, Interessen, Region & Gemeinschaften.',
                      style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 18),
                SizedBox(width: 8),
                Text(
                  'Transparente Mensch-Matches',
                  style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...dummyMatches.map((profile) => MenschMatchCard(profile: profile)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 8. RECORD STORY SCREEN
// ============================================================================
class RecordStoryScreen extends StatefulWidget {
  const RecordStoryScreen({super.key});

  @override
  State<RecordStoryScreen> createState() => _RecordStoryScreenState();
}

class _RecordStoryScreenState extends State<RecordStoryScreen> with TickerProviderStateMixin {
  bool isRecording = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    HapticFeedback.heavyImpact();
    setState(() {
      isRecording = !isRecording;
      if (isRecording) {
        _radarController.repeat();
      } else {
        _radarController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: StoryJobTheme.cardSurfaceLight,
            content: Text('Voice Story erfolgreich aufgenommen!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎙 Story aufnehmen')),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isRecording) ...[
                      RippleCircle(animation: _radarController, radius: 150, color: StoryJobTheme.neonPink),
                      RippleCircle(animation: _radarController, radius: 110, color: StoryJobTheme.primaryViolet, delay: 0.5),
                    ],
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isRecording ? 100.0 : 125.0,
                      height: isRecording ? 100.0 : 125.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isRecording
                              ? [StoryJobTheme.neonPink, StoryJobTheme.primaryViolet]
                              : [StoryJobTheme.primaryViolet, StoryJobTheme.electricPurple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: StoryJobTheme.primaryViolet.withAlpha(100),
                            blurRadius: 30,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        size: isRecording ? 40.0 : 52.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isRecording ? 'Aufnahme läuft...' : 'Tippe aufs Mikrofon',
              style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Erzähle deine Geschichte, deine Werte, Engagement & Interessen in deiner eigenen Stimme.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 14, height: 1.5),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 9. IMPACT SCREEN
// ============================================================================
class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dein Impact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    StoryJobTheme.primaryViolet.withAlpha(60),
                    StoryJobTheme.cardSurface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.primaryViolet.withAlpha(100)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3.4x höherer Fit',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Profile mit Voice Storys erzielen im Vergleich zu klassischen Lebensläufen deutlich passendere Kontakte.',
                    style: TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aktivitäten & Interaktionen',
              style: TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  ImpactTile(
                    icon: Icons.graphic_eq_rounded,
                    title: 'Story Aufrufe',
                    value: '142',
                    subtitle: 'Deine Sprache wurde diese Woche angehört.',
                  ),
                  ImpactTile(
                    icon: Icons.handshake_rounded,
                    title: 'Mensch-Matches',
                    value: '12',
                    subtitle: 'Gemeinsame Werte und Engagement gefunden.',
                  ),
                  ImpactTile(
                    icon: Icons.mark_chat_unread_rounded,
                    title: 'Direkt-Anfragen',
                    value: '4',
                    subtitle: 'Arbeitgeber möchten dich kennenlernen.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImpactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const ImpactTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: StoryJobTheme.primaryViolet.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: StoryJobTheme.electricPurple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 10. MY STORY SCREEN (PROFIL)
// ============================================================================
class MyStoryScreen extends StatelessWidget {
  const MyStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Story'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [StoryJobTheme.primaryViolet, StoryJobTheme.cyanAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StoryJobTheme.primaryViolet.withAlpha(80),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: StoryJobTheme.backgroundBase,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: StoryJobTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: StoryJobTheme.cyanAccent,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: StoryJobTheme.backgroundBase,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Peter Alt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: StoryJobTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: StoryJobTheme.primaryViolet.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cyanAccent.withAlpha(100)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.graphic_eq_rounded, size: 16, color: StoryJobTheme.cyanAccent),
                  SizedBox(width: 6),
                  Text(
                    'Audio Story aktiv',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const WerBinIchNochCard(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_fill_rounded,
                    color: StoryJobTheme.electricPurple,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Haupt-Story (0:48 min)',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Aufgenommen am 21.09.2026',
                          style: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: StoryJobTheme.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 11. WER BIN ICH NOCH CARD (INTERAKTIV)
// ============================================================================
class WerBinIchNochCard extends StatefulWidget {
  const WerBinIchNochCard({super.key});

  @override
  State<WerBinIchNochCard> createState() => _WerBinIchNochCardState();
}

class _WerBinIchNochCardState extends State<WerBinIchNochCard> {
  final Set<String> _selectedEngagement = {'BRK', 'Feuerwehr', 'Ehrenamt'};
  final Set<String> _selectedInterests = {'Angeln', 'Technik', 'Reisen'};

  final List<String> _engagementOptions = ['BRK', 'Feuerwehr', 'THW', 'Schützenverein', 'Ehrenamt'];
  final List<String> _interestOptions = ['Tennis', 'Angeln', 'Wandern', 'Technik', 'Musik', 'Reisen'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StoryJobTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.primaryViolet.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Wer bin ich noch?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: StoryJobTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.edit_note_rounded,
                color: StoryJobTheme.cyanAccent,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'StoryJob zeigt den ganzen Menschen. Diese Infos fließen direkt in dein Voice Match ein.',
            style: TextStyle(
              fontSize: 13,
              color: StoryJobTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.volunteer_activism, color: Color(0xFFFF4081), size: 18),
              SizedBox(width: 8),
              Text(
                'Engagement',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4081),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _engagementOptions.map((item) {
              final isSelected = _selectedEngagement.contains(item);
              return _buildInteractiveChip(
                label: item,
                isSelected: isSelected,
                activeColor: const Color(0xFFFF4081),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedEngagement.remove(item);
                    } else {
                      _selectedEngagement.add(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.dashboard_customize_rounded, color: StoryJobTheme.cyanAccent, size: 18),
              SizedBox(width: 8),
              Text(
                'Interessen',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: StoryJobTheme.cyanAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestOptions.map((item) {
              final isSelected = _selectedInterests.contains(item);
              return _buildInteractiveChip(
                label: item,
                isSelected: isSelected,
                activeColor: StoryJobTheme.cyanAccent,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(item);
                    } else {
                      _selectedInterests.add(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha(35) : StoryJobTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : StoryJobTheme.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 14, color: activeColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 12. HELPER WIDGETS
// ============================================================================
class MenschMatchCard extends StatelessWidget {
  final HumanMatchProfile profile;

  const MenschMatchCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StoryJobTheme.cardSurfaceLight,
                  border: Border.all(color: StoryJobTheme.primaryViolet),
                ),
                child: const Icon(Icons.business_rounded, color: StoryJobTheme.cyanAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(profile.roleOrContext, style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: StoryJobTheme.emeraldGreen.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StoryJobTheme.emeraldGreen.withAlpha(120)),
                ),
                child: Text(
                  '${profile.matchScore}% Match',
                  style: const TextStyle(color: StoryJobTheme.emeraldGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.matchReasons.map((reason) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(reason.emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(reason.title, style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class RippleCircle extends StatelessWidget {
  final Animation<double> animation;
  final double radius;
  final Color color;
  final double delay;

  const RippleCircle({
    super.key,
    required this.animation,
    required this.radius,
    required this.color,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = (animation.value + delay) % 1.0;
        return Container(
          width: radius * progress * 2,
          height: radius * progress * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 1.0 - progress),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}