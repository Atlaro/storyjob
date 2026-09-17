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

    // Start-PopUp automatisch nach dem Laden anzeigen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
    setState(() {
      _selectedRole = role;
    });
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
              Align(
                alignment: Alignment.centerRight,
                child: Chip(
                  backgroundColor: isCandidate
                      ? Colors.blue.withAlpha(50)
                      : Colors.amber.withAlpha(50),
                  side: BorderSide(
                    color: isCandidate ? Colors.blue : Colors.amber,
                  ),
                  avatar: Icon(
                    isCandidate ? Icons.person : Icons.business,
                    size: 18,
                    color: isCandidate ? Colors.lightBlueAccent : Colors.amber,
                  ),
                  label: Text(
                    isCandidate ? 'Bewerber-Modus' : 'Arbeitgeber-Modus',
                    style: TextStyle(
                      color: isCandidate ? Colors.lightBlueAccent : Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                            color: isCandidate
                                ? const Color(0xFF0052CC)
                                : Colors.transparent,
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
                            color: !isCandidate
                                ? const Color(0xFFD97706)
                                : Colors.transparent,
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
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isCandidate
                          ? [const Color(0xFF0052CC), const Color(0xFF2563EB)]
                          : [const Color(0xFFD97706), const Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isCandidate ? Colors.blue : Colors.amber)
                            .withAlpha(100),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isCandidate ? Icons.mic : Icons.record_voice_over,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isCandidate
                    ? 'Erzähle deine Geschichte'
                    : 'Beschreibe deine Stelle',
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCandidate
                        ? const Color(0xFF0052CC)
                        : const Color(0xFFD97706),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                  },
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                  label: Text(
                    _isRecording
                        ? 'Aufnahme stoppen'
                        : (isCandidate
                            ? 'Bewerbung einsprechen'
                            : 'Stellenangebot einsprechen'),
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