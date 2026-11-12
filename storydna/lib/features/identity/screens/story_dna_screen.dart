// lib/features/identity/screens/story_dna_screen.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'package:storydna/core/theme/storyjob_theme.dart';
import 'package:storydna/core/widgets/glass_card.dart';
import 'package:storydna/core/widgets/glass_button.dart';
import 'package:storydna/features/identity/models/story_identity.dart';

class StoryDNAScreen extends StatefulWidget {
  const StoryDNAScreen({super.key});

  @override
  State<StoryDNAScreen> createState() => _StoryDNAScreenState();
}

class _StoryDNAScreenState extends State<StoryDNAScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sichtbarkeit des eigenen DNA-Organismus
  String _visibilityScope = 'network'; // 'network', 'teams', 'private'
  bool _publishToPulse = true;

  // Aktueller 24h-Gedanken-/Vibe-Impuls im eigenen Ich-Zentrum
  String _currentPulseMessage =
      'Offen für echte Begegnungen, Team-Projekte und gemeinsamen Impact ✨';

  // Gesammelte Stimmen & Feedback aus dem Umfeld (Talente, Teams, Vereine, Betriebe)
  final List<ResonanceEcho> _echoes = [
    const ResonanceEcho(
      id: 'echo_1',
      fromName: 'Kameraden & Einsatzleitung',
      contextTag: 'StoryJob Teams • Ehrenamt',
      valueBadge: 'Ruhe in der Krise',
      message:
          'Behält auch in hektischen Lagen den Überblick und packt dort mit an, wo Hilfe gebraucht wird.',
      timeAgo: 'Vor 2 Tagen',
    ),
    const ResonanceEcho(
      id: 'echo_2',
      fromName: 'Projektpartner Süd',
      contextTag: 'StoryJob • Zusammenarbeit',
      valueBadge: 'Verlässlichkeit',
      message:
          'Klare Worte, hands-on Umsetzung und ein Miteinander auf echter Augenhöhe.',
      timeAgo: 'Vor 5 Tagen',
    ),
    const ResonanceEcho(
      id: 'echo_3',
      fromName: 'Team-Impuls • Bright Minds',
      contextTag: 'Werte-Match • 94%',
      valueBadge: 'Tatkraft & Machen',
      message:
          'Deine Haltung zu Eigenverantwortung und Teamgeist passt hervorragend zu unserer Kultur.',
      timeAgo: 'Vor 1 Woche',
    ),
  ];

  // 24h Pulse-Kreise aus dem eigenen Netzwerk (Teams, Wegbegleiter & Betriebe)
  final List<Map<String, dynamic>> _networkPulses = [
    {
      'name': 'Team Nord',
      'badge': 'StoryJob Teams',
      'time': 'Vor 1 Std.',
      'text': 'Übungsabend & Kameradschaftspflege – starker Zusammenhalt in der Mannschaft! 🚒',
      'color': StoryJobTheme.cyanAccent,
      'seen': false,
    },
    {
      'name': 'Bright Minds',
      'badge': 'StoryJob • 94%',
      'time': 'Vor 3 Std.',
      'text': 'Wir suchen Menschen mit Haltung statt perfektem Lebenslauf. Schaut in unsere Team-DNA!',
      'color': StoryJobTheme.primaryViolet,
      'seen': false,
    },
    {
      'name': 'Lukas M.',
      'badge': 'StoryJob DNA',
      'time': 'Vor 5 Std.',
      'text': 'Neuen Meilenstein im Handwerksprojekt abgeschlossen – stolz auf das Ergebnis.',
      'color': StoryJobTheme.pinkMagenta,
      'seen': true,
    },
  ];

  final List<String> _allValues = [
    'Tatkraft & Machen',
    'Verlässlichkeit',
    'Teamgeist & Zusammenhalt',
    'Echtheit & Ehrlichkeit',
    'Ruhe in der Krise',
    'Sinn & Gemeinschaft',
    'Offenheit für Neues',
    'Verantwortung übernehmen',
  ];

  final List<String> _allStrengths = [
    'Praktisches Anpacken',
    'Strategischer Weitblick',
    'Organisation & Struktur',
    'Einfühlungsvermögen',
    'Krisenfestigkeit',
    'Begeisterungsfähigkeit',
    'Analytisches Denken',
    'Schnelle Auffassungsgabe',
  ];

  final List<String> _allInterests = [
    'Technik & Innovation',
    'Natur & Handwerk',
    'Führung & Coaching',
    'Hilfs- & Rettungswesen',
    'Digitale Medien & Design',
    'Gemeinschaft & Kultur',
  ];

  final List<String> _allCommunities = [
    'Freiwillige Feuerwehr',
    'Rettungsdienst & Sanitätsdienst',
    'Technischer Katastrophenschutz',
    'Sportverein / Jugendarbeit',
    'Katastrophenschutz',
    'Gemeinnützige Initiative',
  ];

  final Set<String> _selectedValues = {'Tatkraft & Machen', 'Verlässlichkeit'};
  final Set<String> _selectedStrengths = {'Praktisches Anpacken'};
  final Set<String> _selectedInterests = {'Hilfs- & Rettungswesen', 'Technik & Innovation'};
  final Set<String> _selectedCommunities = {'Freiwillige Feuerwehr'};

  final TextEditingController _visionController = TextEditingController(
    text: 'Gemeinsam anpacken, Verantwortung leben und echte Ergebnisse schaffen.',
  );

  AudioRecorder? _audioRecorder;
  AudioPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  int _recordSeconds = 0;
  Timer? _timer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    try {
      _audioRecorder = AudioRecorder();
      _audioPlayer = AudioPlayer();
    } catch (e) {
      debugPrint('Audio nicht initialisiert: $e');
    }
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioRecorder?.dispose();
    _audioPlayer?.dispose();
    _timer?.cancel();
    _visionController.dispose();
    super.dispose();
  }

  int get _completenessPercent {
    int score = 0;
    if (_selectedValues.isNotEmpty) score += 25;
    if (_selectedStrengths.isNotEmpty || _selectedInterests.isNotEmpty) score += 25;
    if (_selectedCommunities.isNotEmpty) score += 20;
    if (_visionController.text.trim().isNotEmpty) score += 15;
    if (_recordedFilePath != null) score += 15;
    return score.clamp(0, 100);
  }

  String get _userName {
    final name = FirebaseAuth.instance.currentUser?.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return 'Mitglied';
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dnaProfile')
          .doc('main')
          .get();

      if (doc.exists && mounted) {
        final identity = StoryIdentity.fromFirestore(doc);
        setState(() {
          _visibilityScope = identity.visibilityScope;
          if (identity.values.isNotEmpty) {
            _selectedValues
              ..clear()
              ..addAll(identity.values);
          }
          if (identity.strengths.isNotEmpty) {
            _selectedStrengths
              ..clear()
              ..addAll(identity.strengths);
          }
          if (identity.interests.isNotEmpty) {
            _selectedInterests
              ..clear()
              ..addAll(identity.interests);
          }
          if (identity.communities.isNotEmpty) {
            _selectedCommunities
              ..clear()
              ..addAll(identity.communities);
          }
          if (identity.impactVision.isNotEmpty) {
            _visionController.text = identity.impactVision;
          }
          if (identity.echoes.isNotEmpty) {
            _echoes
              ..clear()
              ..addAll(identity.echoes);
          }
        });
      }
    } catch (e) {
      debugPrint('Laden des Profils: $e');
    }
  }

  void _openPulseComposer() {
    HapticFeedback.mediumImpact();
    final controller = TextEditingController(text: _currentPulseMessage);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.4)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dein 24h-DNA-Impuls',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Teile einen Gedanken, ein Erlebnis oder deinen aktuellen Fokus mit deinem Netzwerk.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 180,
                style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: StoryJobTheme.backgroundBase,
                  hintText: 'Was bewegt dich gerade?',
                  hintStyle: const TextStyle(color: StoryJobTheme.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _currentPulseMessage = text;
                    _echoes.insert(
                      0,
                      ResonanceEcho(
                        id: 'self_${DateTime.now().millisecondsSinceEpoch}',
                        fromName: '$_userName (Ich-Impuls)',
                        contextTag: 'StoryJob DNA • 24h Pulse',
                        valueBadge: _selectedValues.first,
                        message: text,
                        timeAgo: 'Gerade eben',
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryJobTheme.cyanAccent,
                  foregroundColor: const Color(0xFF0A0B10),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text(
                  'Im Ich-Zentrum & Pulse teilen',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddEchoDialog() {
    HapticFeedback.lightImpact();
    final nameCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String selectedBadge = _selectedValues.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.45)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Neue Werte-Passung / Rückmeldung festhalten',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sammle echte Rückmeldungen aus Projekten, Vereinen, Ehrenamt oder Arbeit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: StoryJobTheme.backgroundBase,
                    hintText: 'Von wem? (z. B. Teamleitung, Verein, Kollege)',
                    hintStyle: const TextStyle(color: StoryJobTheme.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: _selectedValues.map((val) {
                    final active = selectedBadge == val;
                    return ChoiceChip(
                      label: Text(val, style: const TextStyle(fontSize: 11.5)),
                      selected: active,
                      selectedColor: StoryJobTheme.pinkMagenta.withValues(alpha: 0.25),
                      onSelected: (_) => setModalState(() => selectedBadge = val),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: msgCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: StoryJobTheme.backgroundBase,
                    hintText: 'Was wurde an deiner Art & Haltung besonders geschätzt?',
                    hintStyle: const TextStyle(color: StoryJobTheme.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    if (msgCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _echoes.insert(
                        0,
                        ResonanceEcho(
                          id: 'echo_${DateTime.now().millisecondsSinceEpoch}',
                          fromName: nameCtrl.text.trim().isNotEmpty
                              ? nameCtrl.text.trim()
                              : 'Wegbegleiter aus dem Netzwerk',
                          contextTag: 'StoryJob DNA • Werte-Passung-Anker',
                          valueBadge: selectedBadge,
                          message: msgCtrl.text.trim(),
                          timeAgo: 'Gerade eben',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text('In meiner DNA-Chronik bündeln ✨'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_audioRecorder == null) return;
    try {
      if (await _audioRecorder!.hasPermission()) {
        String path = '';
        if (!kIsWeb) {
          final dir = await getApplicationDocumentsDirectory();
          path = '${dir.path}/story_dna_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder!.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
          _recordedFilePath = null;
        });

        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordSeconds++);
          if (_recordSeconds >= 30) {
            _stopRecording();
          }
        });
      }
    } catch (e) {
      debugPrint('Fehler bei Aufnahme: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_audioRecorder == null) return;
    _timer?.cancel();
    try {
      final path = await _audioRecorder!.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
    } catch (e) {
      debugPrint('Fehler beim Stoppen: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null || _audioPlayer == null) return;
    if (_isPlaying) {
      await _audioPlayer!.stop();
      setState(() => _isPlaying = false);
    } else {
      if (kIsWeb) {
        await _audioPlayer!.play(UrlSource(_recordedFilePath!));
      } else {
        await _audioPlayer!.play(DeviceFileSource(_recordedFilePath!));
      }
      setState(() => _isPlaying = true);
      _audioPlayer!.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  Future<void> _saveDNA() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          content: Text(
            'Hinweis: Melde dich an, um deine StoryJob DNA™ zentral im Netzwerk zu sichern.',
            style: TextStyle(color: StoryJobTheme.textPrimary),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final identity = StoryIdentity(
        userId: user.uid,
        displayName: _userName,
        visibilityScope: _visibilityScope,
        values: _selectedValues.toList(),
        strengths: _selectedStrengths.toList(),
        interests: _selectedInterests.toList(),
        communities: _selectedCommunities.toList(),
        impactVision: _visionController.text.trim(),
        echoes: _echoes,
      );

      final data = identity.toMap();
      data['completenessPercent'] = _completenessPercent;
      data['hasVoiceIntro'] = _recordedFilePath != null;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dnaProfile')
          .doc('main')
          .set(data, SetOptions(merge: true));

      // Symmetrische Synchronisation in die gemeinsame 24h-Pulse-Status-Leiste
      if (_publishToPulse && _visibilityScope != 'private') {
        await FirebaseFirestore.instance.collection('pulse_statuses').doc(user.uid).set({
          'authorId': user.uid,
          'authorRole': 'talent',
          'name': _userName,
          'roleOrTag': '${_selectedValues.take(2).join(' & ')} • $_completenessPercent% DNA',
          'message': _currentPulseMessage,
          'ecosystemBadge': 'StoryJob DNA • $_completenessPercent%',
          'visibilityScope': _visibilityScope,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: StoryJobTheme.mintSuccess,
            content: Text(
              '✓ Dein Ich-Zentrum & StoryJob DNA™ wurden synchronisiert!',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Fehler beim Speichern: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleSetItem(Set<String> targetSet, String item, {int max = 4}) {
    HapticFeedback.selectionClick();
    setState(() {
      if (targetSet.contains(item)) {
        if (targetSet.length > 1) targetSet.remove(item);
      } else {
        if (targetSet.length < max) targetSet.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top-Bar mit StoryJob DNA Branding & Sichtbarkeits-Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.fingerprint, color: StoryJobTheme.cyanAccent, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'StoryJob DNA™',
                              style: TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$_completenessPercent% entfaltet',
                            style: const TextStyle(
                              color: StoryJobTheme.mintSuccess,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hallo $_userName – dein Ich-Zentrum',
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                      color: StoryJobTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Hier laufen deine Werte, Stimmen und echten Werte-Passungen aus Teams, Vereinen & Projekten zusammen.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: StoryJobTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _completenessPercent / 100.0,
                      backgroundColor: StoryJobTheme.cardSurfaceElevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(StoryJobTheme.cyanAccent),
                      minHeight: 4.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: StoryJobTheme.cyanAccent,
                    indicatorWeight: 2.5,
                    labelColor: StoryJobTheme.cyanAccent,
                    unselectedLabelColor: StoryJobTheme.textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Ich & Werte-Passungen'),
                      Tab(text: 'Werte & Haltung'),
                      Tab(text: 'Stärken & Fokus'),
                      Tab(text: 'Stimme & Vision'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: StoryJobTheme.dividerColor, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ===========================================================
                  // TAB 1: DAS LEBENDIGE ICH-ZENTRUM (Werte-Passung-Organismus)
                  // ===========================================================
                  _buildResonanceHubTab(),

                  // ===========================================================
                  // TAB 2: WERTE & ENGAGEMENT
                  // ===========================================================
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          title: 'Kernwerte & Prinzipien',
                          subtitle: 'Wähle bis zu 4 Werte, die dein Handeln leiten.',
                          count: '${_selectedValues.length}/4',
                        ),
                        const SizedBox(height: 12),
                        _buildChipCloud(
                          items: _allValues,
                          selectedSet: _selectedValues,
                          activeColor: StoryJobTheme.primaryViolet,
                          onTap: (val) => _toggleSetItem(_selectedValues, val, max: 4),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          title: 'Engagement & Gemeinschaft',
                          subtitle: 'Wo bringst du dich aktiv ein? (Blaulicht, Verein, Initiative)',
                          count: '${_selectedCommunities.length}/3',
                        ),
                        const SizedBox(height: 12),
                        _buildChipCloud(
                          items: _allCommunities,
                          selectedSet: _selectedCommunities,
                          activeColor: StoryJobTheme.amberEnergy,
                          onTap: (val) => _toggleSetItem(_selectedCommunities, val, max: 3),
                        ),
                      ],
                    ),
                  ),

                  // ===========================================================
                  // TAB 3: STÄRKEN & FOKUS
                  // ===========================================================
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          title: 'Deine echten Stärken',
                          subtitle: 'Worauf kann man sich bei dir im Team blind verlassen?',
                          count: '${_selectedStrengths.length}/4',
                        ),
                        const SizedBox(height: 12),
                        _buildChipCloud(
                          items: _allStrengths,
                          selectedSet: _selectedStrengths,
                          activeColor: StoryJobTheme.cyanAccent,
                          onTap: (val) => _toggleSetItem(_selectedStrengths, val, max: 4),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          title: 'Interessen & Leidenschaften',
                          subtitle: 'Themen, für die du brennst und Energie aufbringst.',
                          count: '${_selectedInterests.length}/4',
                        ),
                        const SizedBox(height: 12),
                        _buildChipCloud(
                          items: _allInterests,
                          selectedSet: _selectedInterests,
                          activeColor: StoryJobTheme.mintSuccess,
                          onTap: (val) => _toggleSetItem(_selectedInterests, val, max: 4),
                        ),
                      ],
                    ),
                  ),

                  // ===========================================================
                  // TAB 4: STIMME & VISION
                  // ===========================================================
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          title: '30-Sekunden Sprachimpuls',
                          subtitle: 'Sprich kurz ein, wer du bist und wofür du stehst.',
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderGradient: _isRecording
                              ? const LinearGradient(
                                  colors: [Colors.redAccent, Colors.deepOrangeAccent],
                                )
                              : StoryJobTheme.soundWaveGradient,
                          hasNeonGlow: _isRecording,
                          child: Column(
                            children: [
                              Text(
                                _isRecording
                                    ? 'Aufnahme läuft: 00:${_recordSeconds.toString().padLeft(2, '0')} / 00:30'
                                    : (_recordedFilePath != null
                                        ? 'Dein persönlicher Klang steht bereit!'
                                        : 'Drücke das Mikrofon und starte deine Story'),
                                style: TextStyle(
                                  color: _isRecording
                                      ? Colors.redAccent
                                      : StoryJobTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _isRecording ? _stopRecording : _startRecording,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: 66,
                                      height: 66,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: _isRecording
                                            ? null
                                            : StoryJobTheme.brandGradient,
                                        color: _isRecording ? Colors.redAccent : null,
                                        boxShadow: StoryJobTheme.neonGlow(
                                          _isRecording ? Colors.redAccent : StoryJobTheme.primaryViolet,
                                          intensity: 0.45,
                                        ),
                                      ),
                                      child: Icon(
                                        _isRecording ? Icons.stop : Icons.mic,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  if (_recordedFilePath != null && !_isRecording) ...[
                                    const SizedBox(width: 20),
                                    IconButton(
                                      onPressed: _playRecording,
                                      iconSize: 44,
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        color: StoryJobTheme.cyanAccent,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          title: 'Leitgedanke & Lebensvision',
                          subtitle: 'Ein prägnanter Satz zu deiner persönlichen Ausrichtung.',
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _visionController,
                            maxLines: 3,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: 'z. B. Zusammen anpacken, wenn es darauf ankommt.',
                              hintStyle: TextStyle(color: StoryJobTheme.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: GlassButton(
                label: 'StoryJob DNA™ synchronisieren',
                icon: Icons.sync,
                isPrimaryGlow: true,
                isLoading: _isSaving,
                onPressed: _saveDNA,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResonanceHubTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 24h-Netzwerk-Pulse (Wegbegleiter, StoryJob Teams & Betriebe)
          const Text(
            '24H PULSE AUS DEINEM UMFELD & TEAMS',
            style: TextStyle(
              color: StoryJobTheme.cyanAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 86,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // Eigener Impuls-Kreis
                GestureDetector(
                  onTap: _openPulseComposer,
                  child: SizedBox(
                    width: 68,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              padding: const EdgeInsets.all(2.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    StoryJobTheme.cyanAccent,
                                    StoryJobTheme.primaryViolet,
                                    StoryJobTheme.pinkMagenta,
                                  ],
                                ),
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: StoryJobTheme.cardSurfaceElevated,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: StoryJobTheme.textPrimary,
                                  size: 26,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: StoryJobTheme.cyanAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: StoryJobTheme.backgroundBase,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFF0A0B10),
                                  size: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Mein Impuls',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ..._networkPulses.map((item) {
                  final Color ringColor = item['color'] as Color;
                  final bool isSeen = item['seen'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => item['seen'] = true);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: StoryJobTheme.cardSurfaceElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(color: ringColor.withValues(alpha: 0.4)),
                            ),
                            title: Text(
                              '${item['name']} • ${item['time']}',
                              style: const TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: Text(
                              item['text'] as String,
                              style: const TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  'Schließen',
                                  style: TextStyle(color: ringColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 68,
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSeen
                                    ? null
                                    : LinearGradient(
                                        colors: [ringColor, StoryJobTheme.pinkMagenta],
                                      ),
                                border: isSeen
                                    ? Border.all(color: StoryJobTheme.cardBorder)
                                    : null,
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: StoryJobTheme.cardSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    (item['name'] as String).substring(0, 1),
                                    style: TextStyle(
                                      color: ringColor,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSeen
                                    ? StoryJobTheme.textMuted
                                    : StoryJobTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: isSeen ? FontWeight.w500 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Persönliche Ich-Karte (Aktueller Fokus + Sichtbarkeits-Steuerung)
          GlassCard(
            borderRadius: 22,
            borderGradient: const LinearGradient(colors: [StoryJobTheme.cyanAccent, StoryJobTheme.primaryViolet]),
            hasNeonGlow: true,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Dein aktueller DNA-Status',
                        style: TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openPulseComposer,
                      style: TextButton.styleFrom(
                        foregroundColor: StoryJobTheme.cyanAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      child: const Text('Bearbeiten', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '„$_currentPulseMessage“',
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Wer darf deine DNA & Werte-Passungen sehen?',
                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildVisibilityChip('network', 'Netzwerk & Matches'),
                    const SizedBox(width: 6),
                    _buildVisibilityChip('teams', 'Nur Teams'),
                    const SizedBox(width: 6),
                    _buildVisibilityChip('private', 'Nur Ich'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Gesammelte Werte-Passungen („Echo-Chronik“)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GESAMMELTE RESONANZEN',
                style: TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
              TextButton.icon(
                onPressed: _openAddEchoDialog,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                label: const Text('Werte-Passung ergänzen', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: StoryJobTheme.pinkMagenta,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ..._echoes.map((echo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                echo.fromName,
                                style: const TextStyle(
                                  color: StoryJobTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${echo.contextTag} • ${echo.timeAgo}',
                                style: const TextStyle(
                                  color: StoryJobTheme.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            echo.valueBadge,
                            style: const TextStyle(
                              color: StoryJobTheme.pinkMagenta,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '„${echo.message}“',
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
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

  Widget _buildVisibilityChip(String scopeKey, String label) {
    final bool selected = _visibilityScope == scopeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _visibilityScope = scopeKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? StoryJobTheme.cyanAccent.withValues(alpha: 0.18)
                : StoryJobTheme.cardSurfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? StoryJobTheme.cyanAccent : StoryJobTheme.cardBorder,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? count,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: StoryJobTheme.textPrimary,
              ),
            ),
            if (count != null)
              Text(
                count,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: StoryJobTheme.cyanAccent,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: StoryJobTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildChipCloud({
    required List<String> items,
    required Set<String> selectedSet,
    required Color activeColor,
    required Function(String) onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedSet.contains(item);
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.18)
                  : StoryJobTheme.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? activeColor : StoryJobTheme.cardBorder,
                width: isSelected ? 1.4 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check, size: 14, color: activeColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}