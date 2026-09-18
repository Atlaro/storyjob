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

// --- ERWEITERTES DATENMODELL FÜR SKILL & VALUE MATCHING ---
class StoryCardData {
  final String id;
  final String title;
  final String summary;
  final List<String> offers; // Was wird geboten (Skills / Benefits)
  final List<String> seeks;  // Was wird gesucht
  final String duration;
  final UserRole role;
  final String contactName;
  final String contactInfo;

  StoryCardData({
    required this.id,
    required this.title,
    required this.summary,
    required this.offers,
    required this.seeks,
    required this.duration,
    required this.role,
    this.contactName = 'Max Mustermann',
    this.contactInfo = 'max@beispiel.de | +49 170 1234567',
  });

  // Hilfsmethode für alle Tags zusammen
  List<String> get allTags => [...offers, ...seeks];
}

// --- ERGEBNIS-KLASSE FÜR DIE MATCH-LOGIK ---
class MatchResult {
  final int scorePercentage;
  final List<String> matchingOffers; // Was dieser User bietet, das du suchst
  final List<String> matchingSeeks;  // Was dieser User sucht, das du bietest

  MatchResult({
    required this.scorePercentage,
    required this.matchingOffers,
    required this.matchingSeeks,
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

  // Audio Waveform Animation
  final List<double> _waveBars = List.generate(15, (index) => 0.2);
  Timer? _waveTimer;

  // Eigenes Profil mit Skill- & Value-Profil
  int _userXP = 150;
  int _userLevel = 1;
  String _userName = "Peter Alt";
  String _userLocation = "Pocking";

  // Meine eigenen Skills & Gesuche
  final List<String> _myOffers = ['Vertrieb', 'Kundenberatung', 'Außendienst', 'Projektmanagement'];
  final List<String> _mySeeks = ['Remote', 'Flutter', 'Flexibilität', 'Tech-Startup'];

  final int _maxFreeMemos = 3;
  bool _isPremiumUser = false;

  final List<StoryCardData> _savedMemos = [];
  final List<StoryCardData> _feedData = [
    StoryCardData(
      id: '1',
      title: 'Senior Flutter Entwickler (m/w/d)',
      summary: 'Suche nach spannenden App-Projekten im Remote-Bereich.',
      offers: ['Flutter', 'Dart', 'App-Entwicklung', 'Remote'],
      seeks: ['Tech-Startup', 'Flexibilität', 'Projektmanagement'],
      duration: '01:15 min',
      role: UserRole.candidate,
      contactName: 'Alex Schmidt',
      contactInfo: 'alex.schmidt@dev-mail.de',
    ),
    StoryCardData(
      id: '2',
      title: 'Tech-Startup sucht UX/UI Designer & Vertrieb',
      summary: 'Wir bauen die Zukunft des Recruiting. Werde Teil des Teams!',
      offers: ['Tech-Startup', 'Remote', 'Flexibilität', 'Attraktive Provision'],
      seeks: ['Vertrieb', 'Kundenberatung', 'Design', 'Außendienst'],
      duration: '00:48 min',
      role: UserRole.employer,
      contactName: 'Recruiting Team TechGmbH',
      contactInfo: 'jobs@techgmbh-demo.de',
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _waveTimer?.cancel();
    super.dispose();
  }

  // --- SKILL- & VALUE-MATCHING ALGORITHMUS ---
  MatchResult _calculateMatch(StoryCardData otherCard) {
    // 1. Was der andere bietet vs. Was ich suche
    final matchingOffers = otherCard.offers
        .where((offer) => _mySeeks.any((seek) => seek.toLowerCase() == offer.toLowerCase()))
        .toList();

    // 2. Was der andere sucht vs. Was ich biete
    final matchingSeeks = otherCard.seeks
        .where((seek) => _myOffers.any((offer) => offer.toLowerCase() == seek.toLowerCase()))
        .toList();

    int totalMatches = matchingOffers.length + matchingSeeks.length;
    int maxPossibleMatches = max(1, _myOffers.length + _mySeeks.length);

    // Berechne Prozentwert (mindestens 20% Basis-Match, max. 98%)
    int percentage = min(98, max(20, ((totalMatches / maxPossibleMatches) * 100).round() + 35));

    return MatchResult(
      scorePercentage: percentage,
      matchingOffers: matchingOffers,
      matchingSeeks: matchingSeeks,
    );
  }

  void _toggleRole(UserRole role) {
    if (_isRecording) _stopRecording();
    setState(() {
      _selectedRole = role;
    });
  }

  void _toggleRecording() {
    if (_savedMemos.length >= _maxFreeMemos && !_isPremiumUser) {
      _showPaywallModal(
        title: 'Memo-Limit erreicht!',
        description: 'Im Gratis-Tarif kannst du bis zu 3 Memos speichern. Hole dir Pro für unbegrenzte Memos!',
      );
      return;
    }

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

    _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      final random = Random();
      setState(() {
        for (int i = 0; i < _waveBars.length; i++) {
          _waveBars[i] = random.nextDouble() * 0.8 + 0.2;
        }
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _waveTimer?.cancel();
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
                'KI analysiert "Biete" & "Suche" Skills...',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      _showEditableStoryCardModal();
    });
  }

  void _showEditableStoryCardModal() {
    final bool isCandidate = _selectedRole == UserRole.candidate;
    final durationStr = _formatDuration(_recordDuration);

    final titleController = TextEditingController(
      text: isCandidate ? 'Vertriebs- & Projektberater' : 'Gesucht: Außendienstberater (m/w/d)',
    );
    final summaryController = TextEditingController(
      text: isCandidate
          ? 'Erfahrener Spezialist in Kundenberatung und Vertrieb mit starkem Fokus auf regionale Betreuung.'
          : 'Wir suchen eine motivierte Persönlichkeit für die Kundenbetreuung vor Ort.',
    );

    List<String> offers = isCandidate
        ? ['Vertrieb', 'Kundenberatung', 'Außendienst']
        : ['Flexibles Arbeiten', 'Top Provision', 'Dienstwagen'];
    List<String> seeks = isCandidate
        ? ['Pocking/Passau', 'Remote', 'Vollzeit']
        : ['Vertrieb', 'Verhandlungsgeschick', 'Außendienst'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      Text(
                        isCandidate ? 'KI-StoryCard Vorschau' : 'KI-Stellenangebot Vorschau',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Titel',
                      labelStyle: const TextStyle(color: Color(0xFF38BDF8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: summaryController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white70),
                    decoration: InputDecoration(
                      labelText: 'KI-Zusammenfassung',
                      labelStyle: const TextStyle(color: Color(0xFF38BDF8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BIETE TAGS
                  const Text('Ich biete / Wir bieten:', style: TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: offers.map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: const Color(0xFF065F46),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  const SizedBox(height: 12),

                  // SUCHE TAGS
                  const Text('Ich suche / Wir suchen:', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: seeks.map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: const Color(0xFF1E3A8A),
                      side: BorderSide.none,
                    )).toList(),
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
                          child: const Text('Verwerfen'),
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
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  title: titleController.text,
                                  summary: summaryController.text,
                                  offers: offers,
                                  seeks: seeks,
                                  duration: '$durationStr min',
                                  role: _selectedRole,
                                  contactName: _userName,
                                  contactInfo: '$_userName | $_userLocation',
                                ),
                              );
                            });
                            Navigator.of(context).pop();
                            _showRewardEffect();
                          },
                          child: const Text('Veröffentlichen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRewardEffect() {
    setState(() {
      _userXP += 100;
      if (_userXP >= 300) _userLevel = 2;
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
            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 64),
            const SizedBox(height: 16),
            const Text('Hervorragend!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Deine StoryCard wurde inklusive Skill-Matching veröffentlicht.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Text('+100 XP Belohnung!', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0052CC)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Klasse!', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywallModal({required String title, required String description}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 48),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
                onPressed: () {
                  setState(() => _isPremiumUser = true);
                  Navigator.of(context).pop();
                },
                child: const Text('Jetzt Business / Pro aktivieren', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.explore, color: Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                Text(
                  _selectedRole == UserRole.candidate ? 'Synergie-Matches & Angebote' : 'Synergie-Matches & Talent-Feed',
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
                final match = _calculateMatch(item);

                return Card(
                  color: const Color(0xFF0F172A),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: match.scorePercentage >= 70 ? const Color(0xFF34D399) : Colors.white10,
                      width: match.scorePercentage >= 70 ? 1.5 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER MIT MATCH BADGE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: match.scorePercentage >= 70 ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: match.scorePercentage >= 70 ? const Color(0xFF34D399) : Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.bolt, color: match.scorePercentage >= 70 ? const Color(0xFF34D399) : Colors.white54, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${match.scorePercentage}% Match',
                                    style: TextStyle(
                                      color: match.scorePercentage >= 70 ? const Color(0xFF34D399) : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item.summary, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 12),

                        // BIETE / SUCHE DETAIL-VERGLEICH
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Bietet, was du suchst: ${match.matchingOffers.isEmpty ? 'Allgemeine Skills' : match.matchingOffers.join(", ")}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.swap_horiz, color: Color(0xFF38BDF8), size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Sucht, was du bietest: ${match.matchingSeeks.isEmpty ? 'Allgemeiner Bedarf' : match.matchingSeeks.join(", ")}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // KONTAKT & ACTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isPremiumUser ? item.contactName : 'Kontakt: ████████',
                              style: TextStyle(color: _isPremiumUser ? Colors.white70 : Colors.white38, fontSize: 12),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0052CC),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Sende Match-Anfrage an "${item.contactName}"...')),
                                );
                              },
                              icon: const Icon(Icons.send, size: 14, color: Colors.white),
                              label: const Text('Anfragen', style: TextStyle(color: Colors.white, fontSize: 12)),
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

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF0052CC),
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Level $_userLevel | $_userXP XP', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Mein "Ich Biete" Profil:', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _myOffers.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: const Color(0xFF065F46))).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Mein "Ich Suche" Profil:', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: _mySeeks.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: const Color(0xFF1E3A8A))).toList(),
            ),
            const SizedBox(height: 20),
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
        title: Row(
          children: [
            const Text('StoryJob', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showProfileModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                ),
                child: Text('Lvl $_userLevel | $_userXP XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined, color: Colors.white70),
            onPressed: _openFeedModal,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white70),
            onPressed: _showProfileModal,
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
              // ROLE TOGGLE
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
                              Text('Ich suche Job', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                              Text('Ich suche Talent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // RECORDING BUTTON
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
                    ),
                  ),
                  child: Icon(
                    _isRecording ? Icons.graphic_eq : (isCandidate ? Icons.mic : Icons.record_voice_over),
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_isRecording) ...[
                Text(
                  _formatDuration(_recordDuration),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
              ],

              Text(
                isCandidate ? 'Erzähle deine Geschichte' : 'Beschreibe deine Stelle',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.redAccent : (isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                  label: Text(
                    _isRecording ? 'Aufnahme stoppen' : (isCandidate ? 'Bewerbung einsprechen' : 'Stellenangebot einsprechen'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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