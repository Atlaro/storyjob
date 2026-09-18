import 'dart:async';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0052CC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const StoryJobHomeScreen(),
    );
  }
}

enum UserRole { candidate, employer }

class StoryCardData {
  final String title;
  final String summary;
  final List<String> tags;
  final String duration;
  final UserRole role;

  StoryCardData({
    required this.title,
    required this.summary,
    required this.tags,
    required this.duration,
    required this.role,
  });
}

class StoryJobHomeScreen extends StatefulWidget {
  const StoryJobHomeScreen({super.key});

  @override
  State<StoryJobHomeScreen> createState() => _StoryJobHomeScreenState();
}

class _StoryJobHomeScreenState extends State<StoryJobHomeScreen>
    with TickerProviderStateMixin {
  UserRole _selectedRole = UserRole.candidate;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

  // Gamification / Belohnungssystem Status
  int _userXP = 150;
  int _userLevel = 1;

  final List<StoryCardData> _savedMemos = [];
  final List<StoryCardData> _feedData = [
    StoryCardData(
      title: 'Senior Flutter Entwickler (m/w/d)',
      summary: 'Suche nach spannenden App-Projekten im Remote-Bereich.',
      tags: ['Flutter', 'Dart', 'Remote', 'Fulltime'],
      duration: '01:15 min',
      role: UserRole.candidate,
    ),
    StoryCardData(
      title: 'Tech-Startup sucht UX/UI Designer',
      summary: 'Wir bauen die Zukunft des Recruiting. Werde Teil des Teams!',
      tags: ['Design', 'Figma', 'Startup', 'München'],
      duration: '00:48 min',
      role: UserRole.employer,
    ),
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF38BDF8)),
            SizedBox(width: 10),
            Text('Willkommen bei StoryJob', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Willkommen auf der Plattform für sprachbasierte Job-Matches!\n\n'
          '• Switch oben nutzen: Wähle zwischen "Ich suche Job" oder "Ich suche Talent".\n'
          '• Spreche deine Geschichte oder Anforderungen einfach ein.\n'
          '• Sammle XP & Punkte für jeden erfolgreichen Sprach-Beitrag!',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Jetzt starten', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleRole(UserRole role) {
    if (_isRecording) _stopRecording();
    setState(() {
      _selectedRole = role;
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordDuration = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });

    _processAudioAndShowStoryCard();
  }

  void _processAudioAndShowStoryCard() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF1E293B),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF38BDF8)),
              SizedBox(height: 20),
              Text(
                'KI wandelt Audio in StoryCard um...',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      _showStoryCardModal();
    });
  }

  void _showRewardEffect() {
    setState(() {
      _userXP += 100;
      if (_userXP >= 300) {
        _userLevel = 2;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Color(0xFFF59E0B),
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hervorragend!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Deine StoryCard wurde erfolgreich übermittelt.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: Color(0xFF38BDF8)),
                  SizedBox(width: 6),
                  Text(
                    '+100 XP Belohnung erhalten!',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052CC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Klasse!', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoryCardModal() {
    final bool isCandidate = _selectedRole == UserRole.candidate;
    final durationStr = _formatDuration(_recordDuration);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Text(
                  isCandidate ? 'Deine generierte StoryCard' : 'Generiertes Stellenprofil',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCandidate
                        ? 'Zusammenfassung: Motivierte Fachkraft mit fokussiertem Stärkenprofil ($durationStr min).'
                        : 'Anforderung: Erfahrener Teamplayer gesucht ($durationStr min).',
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Text('Erkannte Keywords:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(isCandidate ? 'Kommunikation' : 'Vollzeit'),
                        backgroundColor: const Color(0xFF1E293B),
                        side: BorderSide.none,
                      ),
                      Chip(
                        label: Text(isCandidate ? 'Erfahrung' : 'Führung'),
                        backgroundColor: const Color(0xFF1E293B),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Neu aufnehmen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() {
                        _savedMemos.add(
                          StoryCardData(
                            title: isCandidate ? 'Mein Sprach-Profil' : 'Gesuchte Stelle',
                            summary: isCandidate
                                ? 'Motivierte Fachkraft mit fokussiertem Stärkenprofil.'
                                : 'Erfahrener Teamplayer gesucht.',
                            tags: isCandidate ? ['Kommunikation', 'Erfahrung'] : ['Vollzeit', 'Führung'],
                            duration: '$durationStr min',
                            role: _selectedRole,
                          ),
                        );
                      });
                      Navigator.of(context).pop();
                      _showRewardEffect();
                    },
                    child: const Text('Veröffentlichen', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openMemosModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Meine Memos & Entwürfe',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (_savedMemos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'Noch keine Memos gespeichert.\nNimm eine StoryCard auf!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: _savedMemos.length,
                itemBuilder: (context, index) {
                  final memo = _savedMemos[index];
                  return Card(
                    color: const Color(0xFF0F172A),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        memo.role == UserRole.candidate ? Icons.mic : Icons.business,
                        color: memo.role == UserRole.candidate
                            ? const Color(0xFF0052CC)
                            : const Color(0xFFD97706),
                      ),
                      title: Text(memo.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(memo.summary, style: const TextStyle(color: Colors.white70)),
                      trailing: Text(memo.duration, style: const TextStyle(color: Colors.white38)),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openFeedModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.explore, color: Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                Text(
                  _selectedRole == UserRole.candidate ? 'Passende Stellenangebote' : 'Passende Kandidaten',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _feedData.length,
              itemBuilder: (context, index) {
                final item = _feedData[index];
                return Card(
                  color: const Color(0xFF0F172A),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(item.duration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item.summary, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: item.tags
                                  .map((t) => Chip(
                                        label: Text(t, style: const TextStyle(fontSize: 11)),
                                        backgroundColor: const Color(0xFF1E293B),
                                        padding: EdgeInsets.zero,
                                      ))
                                  .toList(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill, color: Color(0xFF38BDF8), size: 36),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Audio von "${item.title}" wird abgespielt...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    final bool isCandidate = _selectedRole == UserRole.candidate;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 2,
        title: Row(
          children: [
            const Text(
              'StoryJob',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // XP & Level Anzeige
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Lvl $_userLevel | $_userXP XP',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined, color: Colors.white70),
            tooltip: 'Explorer / Matches',
            onPressed: _openFeedModal,
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: Colors.white70),
            tooltip: 'Meine Memos',
            onPressed: _openMemosModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Umschalter
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleRole(UserRole.candidate),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isCandidate ? const Color(0xFF0052CC) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Ich suche Job',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _toggleRole(UserRole.employer),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isCandidate ? const Color(0xFFD97706) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_center, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Ich suche Talent',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Pulsierender / Aufnehmender Mikrofon-Button
              ScaleTransition(
                scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isRecording
                          ? [Colors.redAccent, Colors.red.shade700]
                          : (isCandidate
                              ? [const Color(0xFF0052CC), const Color(0xFF2563EB)]
                              : [const Color(0xFFD97706), const Color(0xFFF59E0B)]),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? Colors.red
                                : (isCandidate ? Colors.blue : Colors.amber))
                            .withAlpha(100),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording
                        ? Icons.graphic_eq
                        : (isCandidate ? Icons.mic : Icons.record_voice_over),
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_isRecording) ...[
                Text(
                  _formatDuration(_recordDuration),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              Text(
                isCandidate ? 'Erzähle deine Geschichte' : 'Beschreibe deine Stelle',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                isCandidate
                    ? 'Sprich über deine Stärken, Erfahrungen und was dir im Job wichtig ist. KI erstellt deine StoryCard.'
                    : 'Sprich über die Aufgaben, Unternehmenskultur und was du vom Kandidaten erwartest.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Aktionsbutton
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording
                        ? Colors.redAccent
                        : (isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                  label: Text(
                    _isRecording
                        ? 'Aufnahme stoppen (${_formatDuration(_recordDuration)})'
                        : (isCandidate ? 'Bewerbung einsprechen' : 'Stellenangebot einsprechen'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}