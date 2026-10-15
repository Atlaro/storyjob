// lib/features/identity/screens/story_dna_circles_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/story_level_tracker_widget.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';
import 'package:storyjob/features/record/screens/story_recording_screen.dart';

class StoryDnaCirclesScreen extends StatefulWidget {
  final VoidCallback? onOpenMatches;
  final bool isRecruiter;

  const StoryDnaCirclesScreen({
    super.key,
    this.onOpenMatches,
    this.isRecruiter = false,
  });

  @override
  State<StoryDnaCirclesScreen> createState() => _StoryDnaCirclesScreenState();
}

class _StoryDnaCirclesScreenState extends State<StoryDnaCirclesScreen>
    with TickerProviderStateMixin {
  final StoryIdentityService _identityService = StoryIdentityService();
  bool _isPlayingAudioDna = false;
  bool _isLoading = true;
  bool _showDnaDetails = false;
  late StoryIdentity _identity;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final AnimationController _radarController;

  final StoryIdentity _fallbackIdentity = const StoryIdentity(
    interests: ['Ehrenamt & Hilfsorganisation', 'Handwerk & Bauen', 'Coding & Systeme'],
    values: ['Augenhöhe', 'Eigenverantwortung', 'Verlässlichkeit', 'Hands-on-Mentalität'],
    goals: ['Etwas Sinnvolles bewegen', 'Projekte mit echter Wirkung leiten'],
    workstyle: ['Hands-on anpacken', 'Autonom tüfteln', 'Im Team auf Augenhöhe'],
    motivators: ['Sinnstiftende Aufgaben', 'Miteinander auf Augenhöhe', 'Werte-Einklang'],
    strengths: ['Analytisches Denken', 'Einsatzbereitschaft', 'Kommunikation'],
    communities: ['Ehrenamt & Katastrophenschutz', 'Regionale Macher'],
    learningInterests: ['Zukunftstechnologien', 'Praxis-Führung'],
    impactVision: 'Arbeit, Menschlichkeit und echte Werte im Einklang gestalten.',
  );

  final List<Map<String, dynamic>> _resonanceCircles = [
    {
      'title': 'Nachhaltigkeit & Energie',
      'tag': '🌱',
      'reason': 'Basiert auf deinen Werten & Wirkungszielen',
      'joined': true,
      'color': StoryJobTheme.emeraldGreen,
    },
    {
      'title': 'Ehrenamt, Einsatz & Vereine',
      'tag': '🚒',
      'reason': 'Basiert auf Verlässlichkeit, Schutz & Haltung',
      'joined': true,
      'color': StoryJobTheme.champagneGold,
    },
    {
      'title': 'Zukunftstechnologie & Handwerk',
      'tag': '⚡',
      'reason': 'Basiert auf Wachstumsfeldern & Innovation',
      'joined': false,
      'color': StoryJobTheme.cyanAccent,
    },
    {
      'title': 'Regionale Initiativen & Macher',
      'tag': '🏡',
      'reason': 'Basiert auf lokaler Verwurzelung & Hands-on-Spirit',
      'joined': false,
      'color': StoryJobTheme.primaryViolet,
    },
  ];

  @override
  void initState() {
    super.initState();
    _identity = _fallbackIdentity;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _loadUserIdentity();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    if (_isPlayingAudioDna) {
      AudioService.stopAudio();
    }
    super.dispose();
  }

  Future<void> _loadUserIdentity() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final loaded = await _identityService.loadIdentity(uid);
      if (loaded != null && mounted) {
        setState(() {
          _identity = loaded;
        });
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAudioDna() async {
    HapticFeedback.lightImpact();
    if (_isPlayingAudioDna) {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlayingAudioDna = false);
    } else {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlayingAudioDna = true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'StoryJob DNA Audio-Impuls wird wiedergegeben...',
                style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareStoryResume() {
    HapticFeedback.mediumImpact();
    final user = FirebaseAuth.instance.currentUser;
    final handle = user?.displayName != null
        ? user!.displayName!.toLowerCase().replaceAll(' ', '')
        : 'macher';

    Clipboard.setData(ClipboardData(text: 'https://storyjob.de/@$handle'));

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profil-Link kopiert: storyjob.de/@$handle',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: StoryJobTheme.textPrimary),
        ),
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: StoryJobTheme.cardBorder),
        ),
      ),
    );
  }

  Future<void> _toggleTagInList(
    List<String> currentList,
    String tag,
    Function(List<String>) onUpdate,
  ) async {
    HapticFeedback.selectionClick();
    final updated = List<String>.from(currentList);
    if (updated.contains(tag)) {
      if (updated.length > 1) {
        updated.remove(tag);
      }
    } else {
      updated.add(tag);
    }
    onUpdate(updated);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _identityService.saveIdentity(uid, _identity);
    }
  }

  void _showAddCustomTagSheet() {
    HapticFeedback.lightImpact();
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(22, 20, 22, MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Eigenen Werte-Anker ergänzen',
                style: TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Benenne eine Facette, die dich ausmacht (z. B. Krisenfestigkeit, Mentoring).',
                style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: StoryJobTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Z. B. Krisenfestigkeit',
                  hintStyle: const TextStyle(color: StoryJobTheme.textMuted),
                  filled: true,
                  fillColor: StoryJobTheme.cardSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: StoryJobTheme.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      _toggleTagInList(_identity.values, text, (vals) {
                        setState(() => _identity = _identity.copyWith(values: vals));
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Anker sichern', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: StoryJobTheme.backgroundBase,
        body: Center(child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent)),
      );
    }

    final completeness = _identity.completenessPercent;

    // Rollen-Texte
    final radarTitle = widget.isRecruiter ? 'Kultur-Radar' : 'Werte-Radar';
    final chip1 = widget.isRecruiter ? 'Präzision' : 'Verlässlichkeit';
    final chip2 = widget.isRecruiter ? 'Hands-on' : 'Teamgeist';
    final toggleLabelLeft = widget.isRecruiter ? 'Team-Stories' : 'Audio-Stories';
    final toggleLabelRight = widget.isRecruiter ? 'Talent-Passung' : 'DNA-Entfaltung';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 110.0),
          children: [
            // 1. Header mit StoryJob DNA Badge & Teilen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fingerprint_rounded, color: StoryJobTheme.cyanAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            radarTitle,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _shareStoryResume,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.share_outlined, color: StoryJobTheme.cyanAccent, size: 15),
                        SizedBox(width: 6),
                        Text(
                          'Teilen',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ===============================================================
            // 2. RADAR-HERO AUS DEM STORE-MOCKUP
            // ===============================================================
            Center(
              child: SizedBox(
                width: 310,
                height: 310,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtiler Glow im Hintergrund
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.20),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.20),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Konzentrische animierte Ringe
                    AnimatedBuilder(
                      animation: _radarController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(300, 300),
                          painter: _RadarCirclesPainter(
                            rotationAngle: _radarController.value * 2 * math.pi,
                          ),
                        );
                      },
                    ),

                    // Floating Chip 1
                    Positioned(
                      top: 130,
                      right: 30,
                      child: _buildRadarTag(chip1, StoryJobTheme.cyanAccent),
                    ),

                    // Floating Chip 2
                    Positioned(
                      bottom: 90,
                      left: 24,
                      child: _buildRadarTag(chip2, StoryJobTheme.pinkMagenta),
                    ),

                    // Floating Frequenz-Box
                    Positioned(
                      bottom: 55,
                      right: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Frequenz',
                              style: TextStyle(
                                color: StoryJobTheme.cyanAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            CustomPaint(
                              size: const Size(54, 14),
                              painter: _MiniSineWavePainter(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ===============================================================
            // 3. AUDIO-PROFIL LEISTE MIT SOUNDWELLE
            // ===============================================================
            GlassCard(
              borderRadius: 22,
              borderGradient: StoryJobTheme.dnaCardBorder,
              hasNeonGlow: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isRecruiter ? 'Team-Impuls' : 'Audio-Profile',
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.mic_none_rounded, color: StoryJobTheme.textSecondary, size: 19),
                        tooltip: 'Neu aufnehmen',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const StoryRecordingScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Soundwave
                  ShaderMask(
                    shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(24, (i) {
                        const h = [6, 12, 18, 28, 14, 22, 34, 18, 24, 12, 16, 26, 32, 18, 10, 22, 14, 18, 24, 12, 8, 14, 10, 6];
                        return Container(
                          width: 2.5,
                          height: h[i % h.length].toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('30 s', style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11)),
                      GestureDetector(
                        onTap: _toggleAudioDna,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                            border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5)),
                          ),
                          child: Icon(
                            _isPlayingAudioDna ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: StoryJobTheme.cyanAccent,
                            size: 22,
                          ),
                        ),
                      ),
                      const Text('30 s', style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===============================================================
            // 4. UMSCHALTER UNTEN (Stories <-> DNA-Entfaltung)
            // ===============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: StoryJobTheme.cyanAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      toggleLabelLeft,
                      style: TextStyle(
                        color: !_showDnaDetails ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: _showDnaDetails,
                  activeColor: StoryJobTheme.pinkMagenta,
                  activeTrackColor: StoryJobTheme.pinkMagenta.withValues(alpha: 0.35),
                  inactiveThumbColor: StoryJobTheme.cyanAccent,
                  inactiveTrackColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.25),
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _showDnaDetails = val);
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  toggleLabelRight,
                  style: TextStyle(
                    color: _showDnaDetails ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===============================================================
            // 5. DETAIL-BEREICH (Einklappbar über den Switch)
            // ===============================================================
            if (_showDnaDetails) ...[
              StoryLevelTrackerWidget(
                dnaCompleteness: completeness,
                storiesRecorded: _identity.interests.length,
                activeValuesCount: _identity.values.length,
                onDeepenStory: _showAddCustomTagSheet,
              ),
              const SizedBox(height: 18),

              // Werte & menschliche Haltung
              _buildInteractivePillSection(
                title: 'Werte & menschliche Haltung',
                subtitle: 'Das Fundament: Wonach entscheidest und handelst du?',
                accentColor: StoryJobTheme.primaryViolet,
                currentItems: _identity.values,
                suggestions: const [
                  'Augenhöhe',
                  'Eigenverantwortung',
                  'Verlässlichkeit',
                  'Hands-on-Mentalität',
                  'Fehlerkultur',
                  'Transparenz',
                  'Echtheit',
                  'Krisenfestigkeit',
                ],
                onToggle: (tag) => _toggleTagInList(_identity.values, tag, (list) {
                  setState(() => _identity = _identity.copyWith(values: list));
                }),
                onAddCustom: _showAddCustomTagSheet,
              ),
              const SizedBox(height: 18),

              // Echte Leidenschaften & Machen
              _buildInteractivePillSection(
                title: 'Echte Leidenschaften & Machen',
                subtitle: 'Wo brennt dein Feuer abseits von Zertifikaten?',
                accentColor: StoryJobTheme.cyanAccent,
                currentItems: _identity.interests,
                suggestions: const [
                  'Ehrenamt & Hilfsorganisation',
                  'Handwerk & Bauen',
                  'Coding & Systeme',
                  'Erneuerbare Energien',
                  'Teamführung im Verein',
                  'Kreatives Schaffen',
                  'Ausdauersport',
                  'Regionale Macher',
                ],
                onToggle: (tag) => _toggleTagInList(_identity.interests, tag, (list) {
                  setState(() => _identity = _identity.copyWith(interests: list));
                }),
              ),
              const SizedBox(height: 18),

              // Wirkungsmodus & Arbeitsstil
              _buildInteractivePillSection(
                title: 'Wirkungsmodus & Arbeitsstil',
                subtitle: 'In welchem Umfeld entfaltest du deine volle Energie?',
                accentColor: StoryJobTheme.champagneGold,
                currentItems: _identity.workstyle,
                suggestions: const [
                  'Hands-on anpacken',
                  'Autonom tüfteln',
                  'Im Team auf Augenhöhe',
                  'Flexible Arbeitsweise',
                  'Struktur schaffen',
                  'Verantwortung übernehmen',
                ],
                onToggle: (tag) => _toggleTagInList(_identity.workstyle, tag, (list) {
                  setState(() => _identity = _identity.copyWith(workstyle: list));
                }),
              ),
              const SizedBox(height: 22),

              // Resonanz-Kreise
              _buildSectionLabel('Resonanz-Kreise'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Column(
                  children: List.generate(_resonanceCircles.length, (index) {
                    final circle = _resonanceCircles[index];
                    final bool isJoined = circle['joined'] as bool;
                    final Color circleColor = circle['color'] as Color? ?? StoryJobTheme.cyanAccent;
                    final bool isLast = index == _resonanceCircles.length - 1;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text(circle['tag'] as String, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      circle['title'] as String,
                                      style: const TextStyle(
                                        color: StoryJobTheme.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      circle['reason'] as String,
                                      style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    circle['joined'] = !isJoined;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isJoined
                                        ? circleColor.withValues(alpha: 0.16)
                                        : StoryJobTheme.backgroundBase,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isJoined
                                          ? circleColor.withValues(alpha: 0.5)
                                          : StoryJobTheme.cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    isJoined ? 'Aktiv' : 'Verbinden',
                                    style: TextStyle(
                                      color: isJoined ? circleColor : StoryJobTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                            color: StoryJobTheme.cardBorder,
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadarTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: StoryJobTheme.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInteractivePillSection({
    required String title,
    required String subtitle,
    required Color accentColor,
    required List<String> currentItems,
    required List<String> suggestions,
    required Function(String) onToggle,
    VoidCallback? onAddCustom,
  }) {
    final allChips = {...currentItems, ...suggestions}.toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...allChips.map((chip) {
                final isSelected = currentItems.contains(chip);
                return GestureDetector(
                  onTap: () => onToggle(chip),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.20)
                          : StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.65)
                            : StoryJobTheme.cardBorder,
                        width: isSelected ? 1.3 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.15),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(Icons.check_rounded, size: 13, color: accentColor),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          chip,
                          style: TextStyle(
                            color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              if (onAddCustom != null)
                GestureDetector(
                  onTap: onAddCustom,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          'Eigener Anker',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTER: KONZENTRISCHE NEON-KREISE
// ============================================================================
class _RadarCirclesPainter extends CustomPainter {
  final double rotationAngle;

  _RadarCirclesPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 55, linePaint);
    canvas.drawCircle(center, 95, linePaint);
    canvas.drawCircle(center, 135, linePaint);

    final neonRingPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          StoryJobTheme.cyanAccent,
          StoryJobTheme.primaryViolet,
          StoryJobTheme.pinkMagenta,
          StoryJobTheme.cyanAccent,
        ],
        transform: GradientRotation(rotationAngle),
      ).createShader(Rect.fromCircle(center: center, radius: 135))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, 135, neonRingPaint);

    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [StoryJobTheme.pinkMagenta, StoryJobTheme.cyanAccent],
      ).createShader(Rect.fromLTWH(center.dx - 90, center.dy - 100, 180, 50))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(center.dx - 80, center.dy - 20);
    path.quadraticBezierTo(center.dx - 40, center.dy - 70, center.dx, center.dy - 40);
    path.quadraticBezierTo(center.dx + 40, center.dy - 10, center.dx + 80, center.dy - 50);

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarCirclesPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle;
}

class _MiniSineWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = StoryJobTheme.pinkMagenta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 + math.sin(x * 0.3) * (size.height / 2.2);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}