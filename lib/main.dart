import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const VoiceMatchApp());
}

class VoiceMatchApp extends StatelessWidget {
  const VoiceMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryJob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),
      home: const AudioMemoScreen(),
    );
  }
}

enum UserRole { candidate, employer }

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
  });
}

class AudioMemoScreen extends StatefulWidget {
  const AudioMemoScreen({super.key});

  @override
  State<AudioMemoScreen> createState() => _AudioMemoScreenState();
}

class _AudioMemoScreenState extends State<AudioMemoScreen> with TickerProviderStateMixin {
  // ROLE & RECORDING STATES
  UserRole _selectedRole = UserRole.candidate;
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _waveTimer;

  // ANIMATIONS
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<double> _waveBars = List.generate(15, (index) => 0.2);

  // USER & MEMO LIMITS
  final bool _isPremiumUser = false;
  final int _maxFreeMemos = 3;
  final List<StoryCardData> _savedMemos = [];
  final String _userName = 'Peter Alt';
  final String _userLocation = 'Pocking';
  final String _userSubtitle = 'Versicherungs- & Finanzanlagenfachmann (IHK)';

  // FEED DATA (Globaler/Öffentlicher Feed)
  final List<StoryCardData> _feedData = [
    StoryCardData(
      id: 'demo_1',
      title: 'Erfahrener Vertriebsprofi & Berater',
      summary: 'Ich biete fundierte Kenntnisse im Außendienst und Kundenservice. Suche neue Herausforderung im Bereich Finanzen oder PV.',
      offers: ['Vertriebsstrategie', 'Kundenbetreuung', 'IHK Fachwissen'],
      seeks: ['Vollzeit / Teilzeit', 'Homeoffice-Option', 'Dynamisches Team'],
      duration: '1:15 min',
      role: UserRole.candidate,
      contactName: 'Peter Alt',
      contactInfo: 'Pocking | IHK Spezialist',
    ),
    StoryCardData(
      id: 'demo_2',
      title: 'Senior Flutter & Mobile Developer (m/w/d)',
      summary: 'Wir suchen einen erfahrenen Mobile-Entwickler für zukunftsweisende App-Projekte in Niederbayern.',
      offers: ['Attraktives Gehalt', '30 Tage Urlaub', 'Flexible Arbeitszeiten'],
      seeks: ['Flutter / Dart Skills', 'Clean Code', 'Eigenverantwortung'],
      duration: '0:45 min',
      role: UserRole.employer,
      contactName: 'TechSolutions GmbH',
      contactInfo: 'Passau | IT & Software',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRole(UserRole role) {
    if (_isRecording) return;
    setState(() {
      _selectedRole = role;
    });
  }

  void _toggleRecording() {
    if (!_isRecording) {
      if (!_isPremiumUser && _savedMemos.length >= _maxFreeMemos) {
        _showLimitReachedDialog();
        return;
      }
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });

    final random = Random();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      setState(() {
        _waveBars = List.generate(15, (_) => 0.15 + random.nextDouble() * 0.85);
      });
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
      _processMemoAndShowModal();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aufnahme zu kurz (mindestens 3 Sekunden sprechen).'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _processMemoAndShowModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          color: Color(0xFF1E293B),
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF38BDF8)),
                SizedBox(height: 16),
                Text('KI analysiert dein Memo...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Strukturierte Match-Karte wird erstellt', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showEditableStoryCardModal();
    });
  }

  void _showEditableStoryCardModal() {
    final isCandidate = _selectedRole == UserRole.candidate;
    final titleController = TextEditingController(
      text: isCandidate ? 'Vertriebs- & Finanzspezialist' : 'Kundenberater / Sales Manager (m/w/d)',
    );
    final summaryController = TextEditingController(
      text: isCandidate
          ? 'Erfahrener Spezialist für Finanzberatung, Kundenbetreuung und Vertrieb mit starker Eigeninitiative.'
          : 'Gesucht wird ein kommunikationsstarker Mitarbeiter für den Ausbau unseres Kundenstamms.',
    );

    List<String> offers = isCandidate
        ? ['Kundenberatung', 'Außendienst', 'IHK-Zertifiziert']
        : ['Attraktives Gehalt', 'Homeoffice-Möglichkeit', 'Weiterbildung'];
    List<String> seeks = isCandidate
        ? ['Vollzeit position', 'Gute Weiterbildung', 'Starkes Team']
        : ['Vertriebserfahrung', 'Verantwortungsbewusstsein', 'Teamgeist'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCandidate ? 'Deine Bewerber-Karte' : 'Deine Stellen-Karte',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Titel',
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: summaryController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Zusammenfassung (KI-generiert)',
                    labelStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isCandidate ? 'Was du bietest:' : 'Was geboten wird:',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: offers.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: const Color(0xFF334155),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  isCandidate ? 'Was du suchst:' : 'Was gesucht wird:',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: seeks.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: const Color(0xFF334155),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final durationStr = _formatDuration(_recordDuration);
                      
                      final newCard = StoryCardData(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        summary: summaryController.text,
                        offers: offers,
                        seeks: seeks,
                        duration: '$durationStr min',
                        role: _selectedRole,
                        contactName: _userName,
                        contactInfo: '$_userName | $_userLocation',
                      );

                      setState(() {
                        _savedMemos.add(newCard);
                        _feedData.insert(0, newCard);
                      });

                      Navigator.of(context).pop();
                      _showRewardEffect();
                    },
                    child: const Text('Veröffentlichen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRewardEffect() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 10),
            Expanded(child: Text('Memo veröffentlicht! Es ist jetzt im Feed sichtbar.')),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Memo-Limit erreicht', style: TextStyle(color: Colors.white)),
        content: Text(
          'Du hast dein Limit von $_maxFreeMemos kostenlosen Memos erreicht. Hol dir Premium für unbegrenzte Memos.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Später', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Premium upgraden', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openFeedModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Öffentlicher Feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _feedData.length,
                  itemBuilder: (context, index) {
                    final item = _feedData[index];
                    final isCand = item.role == UserRole.candidate;
                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCand ? const Color(0xFF0052CC).withOpacity(0.3) : const Color(0xFFD97706).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isCand ? 'Bewerber' : 'Arbeitgeber',
                                    style: TextStyle(
                                      color: isCand ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(item.duration, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(item.summary, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 12),
                            Text('Kontakt: ${item.contactInfo}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // DIALOG FÜR KONTO & MEINE MEMOS (MIT NUTZERDATEN & WOHNORT)
  void _openProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mein Konto & Memos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // USER PROFIL CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFF0052CC),
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text(_userSubtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8))),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white54, size: 14),
                                      const SizedBox(width: 4),
                                      Text(_userLocation, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Meine Aufnahmen (${_savedMemos.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 12),

                      if (_savedMemos.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Noch keine Memos aufgenommen.\nNimm dein erstes Memo auf!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54, height: 1.4),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _savedMemos.length,
                          itemBuilder: (context, index) {
                            final item = _savedMemos[index];
                            final isCand = item.role == UserRole.candidate;
                            return Card(
                              color: const Color(0xFF1E293B),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Icon(
                                  isCand ? Icons.person : Icons.business,
                                  color: isCand ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                                ),
                                title: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                trailing: Text(item.duration, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCandidate = _selectedRole == UserRole.candidate;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('StoryJob', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore, color: Colors.white70),
            tooltip: 'Feed öffnen',
            onPressed: _openFeedModal,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white70),
            tooltip: 'Mein Konto & Memos',
            onPressed: _openProfileModal,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ROLE TOGGLE (Bewerber / Arbeitgeber)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
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
                              Icon(Icons.person, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Bewerber', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                              Icon(Icons.business, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Arbeitgeber', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // RECORDING STATUS & WAVEFORM
              if (_isRecording) ...[
                Text(
                  _formatDuration(_recordDuration),
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _waveBars.map((heightFactor) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 4,
                        height: 40 * heightFactor,
                        decoration: BoxDecoration(
                          color: isCandidate ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sprich über deine Skills, Werte & Wünsche...',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ] else ...[
                Text(
                  isCandidate ? 'Nimm dein Bewerber-Memo auf' : 'Nimm dein Stellenangebot auf',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isCandidate
                      ? 'Beschreibe kurz, was du bietest und wonach du suchst. Die KI erstellt deine Match-Karte.'
                      : 'Beschreibe die Position und Anforderungen. Die KI gleicht sie direkt mit Bewerbern ab.',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const Spacer(),

              // RECORD BUTTON WITH PULSE ANIMATION
              ScaleTransition(
                scale: _isRecording ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? Colors.redAccent
                          : (isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706)),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? Colors.redAccent
                                  : (isCandidate ? const Color(0xFF0052CC) : const Color(0xFFD97706)))
                              .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // SAVED MEMOS COUNTER
              Text(
                'Gespeicherte Memos: ${_savedMemos.length} / ${_isPremiumUser ? "∞" : _maxFreeMemos}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}