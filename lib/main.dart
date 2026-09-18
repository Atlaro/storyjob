import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const StoryJobApp());
}

class StoryJobApp extends StatelessWidget {
  const StoryJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        fontFamily: 'Roboto',
      ),
      home: const OnboardingScreen(),
    );
  }
}

enum UserRole { student, candidate, employer }

class VibeTag {
  final String label;
  final Color color;
  VibeTag(this.label, this.color);
}

class ChestData {
  final String title;
  final Duration lockDuration;
  final DateTime earnedAt;
  final String rewardBadge;
  bool isOpened;

  ChestData({
    required this.title,
    required this.lockDuration,
    required this.earnedAt,
    required this.rewardBadge,
    this.isOpened = false,
  });

  bool get isReady => DateTime.now().difference(earnedAt) >= lockDuration;

  String get remainingTimeText {
    if (isReady) return 'Bereit zum Öffnen!';
    final remaining = lockDuration - DateTime.now().difference(earnedAt);
    final h = remaining.inHours.toString().padLeft(2, '0');
    final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    return '$h Std $m Min';
  }
}

class StoryCardData {
  final String id;
  final String title;
  final String summary;
  final List<String> offers;
  final List<String> seeks;
  final String duration;
  final UserRole role;
  final String contactName;
  final String contactInfo;
  final int matchScore;
  final List<VibeTag> vibeTags;
  final DateTime createdAt;

  StoryCardData({
    required this.id,
    required this.title,
    required this.summary,
    required this.offers,
    required this.seeks,
    required this.duration,
    required this.role,
    required this.contactName,
    required this.contactInfo,
    required this.matchScore,
    required this.vibeTags,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isGold => matchScore >= 90;
  bool get isSilver => matchScore >= 70 && matchScore < 90;

  Color get medalColor {
    if (isGold) return const Color(0xFFFFD700);
    if (isSilver) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  bool isLockedForFree(bool isPremium) {
    if (isPremium) return false;
    if (!isGold) return false;
    return DateTime.now().difference(createdAt) < const Duration(hours: 24);
  }
}

// ==========================================
// 1. ONBOARDING & ROLLENAUSWAHL
// ==========================================
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  UserRole? _selectedRole;

  void _proceedToApp() {
    if (_selectedRole == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainHomeScreen(userRole: _selectedRole!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
                ).createShader(bounds),
                child: const Text(
                  'Willkommen bei StoryJob',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Echte Stimme, echte Chancen. Wähle deine Rolle:',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _buildRoleOption(
                role: UserRole.student,
                title: 'Schüler / Auszubildender',
                subtitle: 'Praktikum, Ausbildung & Orientierung mit Zukunft.',
                icon: Icons.school,
                accentColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                role: UserRole.candidate,
                title: 'Bewerber / Fachkraft',
                subtitle: 'Neue Herausforderungen, Wechselwunsch & Karriere.',
                icon: Icons.person,
                accentColor: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                role: UserRole.employer,
                title: 'Arbeitgeber / Recruiter',
                subtitle: 'Echte Talent-Vibes hören & Top-Matches finden.',
                icon: Icons.business,
                accentColor: const Color(0xFFF59E0B),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _selectedRole != null ? const Color(0xFF00F2FE) : Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _selectedRole != null ? _proceedToApp : null,
                  child: Text(
                    'App Starten',
                    style: TextStyle(
                      color: _selectedRole != null ? Colors.black : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.15) : const Color(0xFF131C2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MAIN APP NAVIGATION (NAVBAR + SCREENS)
// ==========================================
class MainHomeScreen extends StatefulWidget {
  final UserRole userRole;
  const MainHomeScreen({super.key, required this.userRole});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  late UserRole _currentRole;

  bool _isPremiumUser = false; // Freemium-Status
  int _bonusDrivePoints = 840;
  int _dailyStreak = 5;
  List<ChestData> _chests = [];
  List<String> _unlockedBadges = ['Top-Kommunikator', 'Macher-Energie'];

  late List<StoryCardData> _feedData;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.userRole;

    _chests = [
      ChestData(
        title: 'Silber-Match-Truhe',
        lockDuration: const Duration(hours: 2),
        earnedAt: DateTime.now().subtract(const Duration(minutes: 90)),
        rewardBadge: 'Teamplayer',
      ),
      ChestData(
        title: 'Gold-Vibe-Truhe',
        lockDuration: const Duration(hours: 8),
        earnedAt: DateTime.now(),
        rewardBadge: 'Führungstyp',
      ),
    ];

    _feedData = [
      StoryCardData(
        id: '1',
        title: 'Erfahrener Außendienst-Spezialist',
        summary: 'Vertrieb, Kundenbetreuung & IHK-Zertifizierung. Suche neue Herausforderung.',
        offers: ['Vertriebsstärke', 'Kundenbindung'],
        seeks: ['Vollzeit', 'Region Niederbayern'],
        duration: '1:15 min',
        role: UserRole.candidate,
        contactName: 'Peter Alt',
        contactInfo: 'Pocking | IHK Fachkraft',
        matchScore: 96,
        vibeTags: [
          VibeTag('Macher-Energie', const Color(0xFFEC4899)),
          VibeTag('Verlässlichkeit', const Color(0xFF10B981))
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)), // Vor 2 Std (Gold-Sperre für Free!)
      ),
      StoryCardData(
        id: '2',
        title: 'Ausbildung zum Fachinformatiker 2027',
        summary: 'Wir bieten Praxis ab Tag 1, Mentoring und flexible Arbeitszeiten.',
        offers: ['30 Tage Urlaub', 'Hardware-Bonus'],
        seeks: ['Motivation', 'Teamgeist'],
        duration: '0:50 min',
        role: UserRole.employer,
        contactName: 'IT Systemhaus Passau',
        contactInfo: 'Passau | Region',
        matchScore: 88,
        vibeTags: [
          VibeTag('Zukunftsorientiert', const Color(0xFF06B6D4)),
          VibeTag('Praxisnah', const Color(0xFFF59E0B))
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 30)),
      ),
      StoryCardData(
        id: '3',
        title: 'Motivierter Fachinformatiker (Azubi)',
        summary: 'Interesse an App-Entwicklung & Netzwerken. Suche Ausbildungsbetrieb.',
        offers: ['Eigeninitiative', 'Grundkenntnisse'],
        seeks: ['Ausbildungsplatz', 'Passau / Umgebung'],
        duration: '0:40 min',
        role: UserRole.student,
        contactName: 'Julian A.',
        contactInfo: 'Passau | Schüler',
        matchScore: 78,
        vibeTags: [
          VibeTag('Lernhungrig', const Color(0xFF8B5CF6)),
          VibeTag('Teamplayer', const Color(0xFF3B82F6))
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  void _openChestsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF090D16),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Deine Match-Truhen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (_chests.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Aktuell keine Truhen vorhanden. Nimm Memos auf, um welche zu verdienen!', style: TextStyle(color: Colors.white54)),
                )
              else
                ..._chests.map((chest) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131C2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2, color: chest.isReady ? const Color(0xFFFFD700) : Colors.white38, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chest.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(chest.remainingTimeText, style: TextStyle(color: chest.isReady ? const Color(0xFF10B981) : const Color(0xFF00F2FE), fontSize: 12)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: chest.isReady ? const Color(0xFFFFD700) : Colors.white12,
                          ),
                          onPressed: chest.isReady && !chest.isOpened
                              ? () {
                                  setState(() {
                                    chest.isOpened = true;
                                    _unlockedBadges.add(chest.rewardBadge);
                                    _chests.remove(chest);
                                  });
                                  setModalState(() {});
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Neues Skill-Badge freigeschaltet: ${chest.rewardBadge}!')),
                                  );
                                }
                              : null,
                          child: Text(chest.isReady ? 'Öffnen' : 'Gesperrt', style: TextStyle(color: chest.isReady ? Colors.black : Colors.white38, fontSize: 11)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // PAGE 0: AUDIO RECORDING & KI ANALYSE
      AudioRecordPage(
        currentRole: _currentRole,
        unlockedBadges: _unlockedBadges,
        onRoleChanged: (newRole) => setState(() => _currentRole = newRole),
        onMemoRecorded: (newCard, newChest) {
          setState(() {
            _feedData.insert(0, newCard);
            _chests.add(newChest);
            _bonusDrivePoints += 50;
          });
        },
      ),

      // PAGE 1: MATCH FEED & MEDAILLEN
      MatchFeedPage(
        feedData: _feedData,
        isPremium: _isPremiumUser,
        onTogglePremium: () {
          setState(() => _isPremiumUser = !_isPremiumUser);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isPremiumUser ? 'Premium aktiviert: Alle Gold-Matches sofort sichtbar!' : 'Auf Free-Version gewechselt.')),
          );
        },
      ),

      // PAGE 2: LIVE MATCH RADAR
      LiveRadarPage(feedData: _feedData),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)]).createShader(bounds),
              child: const Text('StoryJob', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            const SizedBox(width: 10),
            // STREAK
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFF5722).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFFF5722), size: 14),
                  const SizedBox(width: 2),
                  Text('$_dailyStreak', style: const TextStyle(color: Color(0xFFFF5722), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // BONUSDRIVE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 2),
                  Text('$_bonusDrivePoints Pkt', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2, color: Color(0xFFFFD700)),
            onPressed: _openChestsModal,
            tooltip: 'Match-Truhen',
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF131C2E),
        selectedItemColor: const Color(0xFF00F2FE),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Aufnahme'),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Match-Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Live Radar'),
        ],
      ),
    );
  }
}

// ==========================================
// PAGE 0: AUDIO RECORD PAGE
// ==========================================
class AudioRecordPage extends StatefulWidget {
  final UserRole currentRole;
  final List<String> unlockedBadges;
  final ValueChanged<UserRole> onRoleChanged;
  final Function(StoryCardData, ChestData) onMemoRecorded;

  const AudioRecordPage({
    super.key,
    required this.currentRole,
    required this.unlockedBadges,
    required this.onRoleChanged,
    required this.onMemoRecorded,
  });

  @override
  State<AudioRecordPage> createState() => _AudioRecordPageState();
}

class _AudioRecordPageState extends State<AudioRecordPage> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _waveTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<double> _waveBars = List.generate(15, (_) => 0.2);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (!_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = 0;
    });
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _recordDuration++));
    final rand = Random();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _waveBars = List.generate(15, (_) => 0.15 + rand.nextDouble() * 0.85));
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _isRecording = false;
      _waveBars = List.generate(15, (_) => 0.2);
    });

    if (_recordDuration >= 3) {
      _processAiAnalysis();
    }
  }

  void _processAiAnalysis() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF131C2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.4))),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF00F2FE)),
              SizedBox(height: 16),
              Text('KI Vibe-Analyse läuft...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Analyse von Tonfall, Energie & Vibe-Tags', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();

      final newChest = ChestData(
        title: 'Gold-Match-Truhe',
        lockDuration: const Duration(hours: 4),
        earnedAt: DateTime.now(),
        rewardBadge: 'Verlässlicher Partner',
      );

      final newCard = StoryCardData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: widget.currentRole == UserRole.student ? 'Schüler Profile-Memo' : (widget.currentRole == UserRole.candidate ? 'Erfahrene Fachkraft' : 'Stellenangebot Recruiter'),
        summary: 'KI-Analyse: Klare Ausdrucksweise, Hohes Engagement.',
        offers: ['Engagement', 'Fachwissen'],
        seeks: ['Top Team', 'Region Pocking/Passau'],
        duration: '0:${_recordDuration.toString().padLeft(2, '0')} min',
        role: widget.currentRole,
        contactName: 'Peter Alt',
        contactInfo: 'Pocking',
        matchScore: 92 + Random().nextInt(7),
        vibeTags: [VibeTag('Macher-Energie', const Color(0xFFEC4899)), VibeTag('Top Vibe', const Color(0xFF06B6D4))],
      );

      widget.onMemoRecorded(newCard, newChest);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memo gespeichert & Neue Truhe verdient!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFF131C2E), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(child: _buildRoleTab('Schüler', UserRole.student, const Color(0xFF10B981))),
                Expanded(child: _buildRoleTab('Bewerber', UserRole.candidate, const Color(0xFF3B82F6))),
                Expanded(child: _buildRoleTab('Arbeitgeber', UserRole.employer, const Color(0xFFF59E0B))),
              ],
            ),
          ),
          const Spacer(),
          if (_isRecording) ...[
            Text('0:${_recordDuration.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _waveBars.map((h) => AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 4,
                  height: 40 * h,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)]), borderRadius: BorderRadius.circular(2)),
                )).toList(),
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 6,
              children: widget.unlockedBadges.map((b) => Chip(
                label: Text('★ $b', style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                backgroundColor: const Color(0xFFFFD700),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              widget.currentRole == UserRole.student
                  ? 'Sprich dein Schüler-Memo ein'
                  : (widget.currentRole == UserRole.candidate ? 'Nimm dein Bewerber-Memo auf' : 'Spreche ein Stellenangebot ein'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text('Die KI berechnet deinen Vibe-Index & Match-Score.', style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
          ],
          const Spacer(),
          ScaleTransition(
            scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isRecording ? const LinearGradient(colors: [Colors.redAccent, Colors.deepOrange]) : const LinearGradient(colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)]),
                  boxShadow: [BoxShadow(color: (_isRecording ? Colors.redAccent : const Color(0xFF00F2FE)).withOpacity(0.35), blurRadius: 25, spreadRadius: 4)],
                ),
                child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.black, size: 38),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRoleTab(String label, UserRole role, Color activeColor) {
    final isSelected = widget.currentRole == role;
    return GestureDetector(
      onTap: () => widget.onRoleChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: activeColor.withOpacity(0.6)) : Border.all(color: Colors.transparent),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? activeColor : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

// ==========================================
// PAGE 1: MATCH FEED PAGE (MIT MEDAILLEN & FREEMIUM LOCK)
// ==========================================
class MatchFeedPage extends StatelessWidget {
  final List<StoryCardData> feedData;
  final bool isPremium;
  final VoidCallback onTogglePremium;

  const MatchFeedPage({
    super.key,
    required this.feedData,
    required this.isPremium,
    required this.onTogglePremium,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FREEMIUM TOGGLE BANNER
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF131C2E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPremium ? 'Status: Premium Aktiv' : 'Status: Free Version', style: TextStyle(color: isPremium ? const Color(0xFFFFD700) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Text('Gold-Matches (>90%) 24h früher sehen', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
              Switch(
                value: isPremium,
                onChanged: (v) => onTogglePremium(),
                activeColor: const Color(0xFFFFD700),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: feedData.length,
            itemBuilder: (context, index) {
              final card = feedData[index];
              final isLocked = card.isLockedForFree(isPremium);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131C2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: card.medalColor.withOpacity(0.5), width: 1.5),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // MEDAILLE BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: card.medalColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: card.medalColor)),
                                child: Row(
                                  children: [
                                    Icon(Icons.workspace_premium, color: card.medalColor, size: 16),
                                    const SizedBox(width: 4),
                                    Text('${card.matchScore}% Match', style: TextStyle(color: card.medalColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(card.duration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(card.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${card.contactName} • ${card.contactInfo}', style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(card.summary, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 12),

                          // VIBE TAGS
                          Wrap(
                            spacing: 6,
                            children: card.vibeTags.map((v) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: v.color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text('# ${v.label}', style: TextStyle(color: v.color, fontSize: 11, fontWeight: FontWeight.bold)),
                            )).toList(),
                          ),
                          const SizedBox(height: 16),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00F2FE),
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isLocked ? null : () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Memo von ${card.contactName} wird abgespielt...')));
                            },
                            icon: const Icon(Icons.play_arrow, color: Colors.black),
                            label: const Text('Audio Memo anhören', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                    // UNSTETIGER GLAS-SCHLEIER FÜR SPERRE (FREEMIUM)
                    if (isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.82),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, color: Color(0xFFFFD700), size: 36),
                              const SizedBox(height: 8),
                              const Text('Gold Match (90%+)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              const Text('In Premium sofort verfügbar oder in 24 Std. gratis', style: TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                                onPressed: onTogglePremium,
                                child: const Text('Jetzt freischalten', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ==========================================
// PAGE 2: LIVE MATCH RADAR (NIEDERBAYERN/PASSAU)
// ==========================================
class LiveRadarPage extends StatelessWidget {
  final List<StoryCardData> feedData;

  const LiveRadarPage({super.key, required this.feedData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Match Radar', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Aktive Memos & Chancen im Raum Niederbayern', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF131C2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.2)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // RADAR KREISE
                  Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.15), width: 1.5))),
                  Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.25), width: 1.5))),
                  Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.4), width: 1.5))),

                  // MITTELPUNKT (EIGENER STANDORT)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF00F2FE), shape: BoxShape.circle), child: const Icon(Icons.my_location, color: Colors.black, size: 16)),
                      const SizedBox(height: 4),
                      const Text('Pocking', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),

                  // RADAR ORBS (MATCHES IN DIE REGIONEN VERTEILT)
                  _buildRadarOrb(context, top: 40, left: 60, city: 'Passau', score: 96, color: const Color(0xFFFFD700)),
                  _buildRadarOrb(context, bottom: 60, right: 50, city: 'Bad Birnbach', score: 88, color: const Color(0xFFC0C0C0)),
                  _buildRadarOrb(context, top: 90, right: 40, city: 'Vilshofen', score: 92, color: const Color(0xFFFFD700)),
                  _buildRadarOrb(context, bottom: 50, left: 70, city: 'Ruhstorf', score: 78, color: const Color(0xFFCD7F32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarOrb(BuildContext context, {double? top, double? bottom, double? left, double? right, required String city, required int score, required Color color}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Match in $city ($score% Vibe) ausgewählt!')));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.25), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
              child: Text('$score%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
            const SizedBox(height: 2),
            Text(city, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}