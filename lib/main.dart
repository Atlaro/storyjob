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

class StoryJobHomeScreen extends StatefulWidget {
  const StoryJobHomeScreen({super.key});

  @override
  State<StoryJobHomeScreen> createState() => _StoryJobHomeScreenState();
}

class _StoryJobHomeScreenState extends State<StoryJobHomeScreen>
    with SingleTickerProviderStateMixin {
  UserRole _selectedRole = UserRole.candidate;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

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
          '• Verwalte deine Nachrichten, Memos & Konto in der oberen Menüleiste.',
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
    // Simulierter KI-Ladebildschirm
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

    // Nach 2 Sekunden Ergebnis anzeigen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Ladedialog schließen
      _showStoryCardModal();
    });
  }

  void _showStoryCardModal() {
    final bool isCandidate = _selectedRole == UserRole.candidate;

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
                        ? 'Zusammenfassung: Motivierte Fachkraft mit starkem Fokus auf Kundenorientierung & Teamwork.'
                        : 'Anforderung: Erfahrener Teamplayer für dynamisches Umfeld gesucht.',
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
                      Chip(
                        label: Text(isCandidate ? 'Flexibilität' : 'Projektarbeit'),
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
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('StoryCard erfolgreich veröffentlicht!'),
                          backgroundColor: Colors.green,
                        ),
                      );
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

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _showFeatureNotice(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title geöffnet'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF0052CC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCandidate = _selectedRole == UserRole.candidate;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 2,
        title: const Text(
          'StoryJob',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
            tooltip: 'Nachrichten',
            onPressed: () => _showFeatureNotice('Nachrichten'),
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: Colors.white70),
            tooltip: 'Meine Memos',
            onPressed: () => _showFeatureNotice('Meine Memos'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white70),
            tooltip: 'Konto',
            onPressed: () => _showFeatureNotice('Konto'),
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

              // Timer Anzeige bei Aufnahme
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