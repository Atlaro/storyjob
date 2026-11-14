// lib/features/recruiter/screens/company_dna_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/recruiter/models/company_dna.dart';

class CompanyDnaScreen extends StatefulWidget {
  final bool isInitialSetup;

  const CompanyDnaScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  State<CompanyDnaScreen> createState() => _CompanyDnaScreenState();
}

class _CompanyDnaScreenState extends State<CompanyDnaScreen> {
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _missionController = TextEditingController();
  final _purposeController = TextEditingController();

  bool _isLoading = false;
  bool _isVerified = false;
  bool _publishAsPulseStatus = true;
  String? _videoUrl;
  String? _audioUrl;
  String? _logoUrl;

  // Wählbare Kultur- & Team-Werte (gespiegelt zur Talent-DNA)
  final List<String> _availableCultureValues = [
    'Teamgeist',
    'Eigenverantwortung',
    'Augenhöhe',
    'Handwerk & Praxis',
    'Tüftlergeist',
    'Gemeinwohl',
  ];
  final Set<String> _selectedCultureValues = {
    'Teamgeist',
    'Eigenverantwortung',
    'Augenhöhe',
  };

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _industryController.addListener(_onFieldChanged);
    _loadCompanyData();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _industryController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _missionController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('companies').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final dna = CompanyDna.fromMap(data, doc.id);
      if (!mounted) return;
      setState(() {
        _nameController.text = dna.name;
        _websiteController.text = dna.website;
        _industryController.text = dna.industry;
        _missionController.text = dna.missionQuote;
        _purposeController.text = dna.purposeVision;
        _videoUrl = dna.videoStoryUrl;
        _audioUrl = dna.audioStoryUrl;
        _logoUrl = dna.logoUrl;
        _isVerified = dna.isVerified;

        if (data['cultureTags'] is List) {
          final tags = List<String>.from(data['cultureTags']);
          if (tags.isNotEmpty) {
            _selectedCultureValues
              ..clear()
              ..addAll(tags);
          }
        }
      });
    }
  }

  void _showMediaOptions() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mic_rounded, color: StoryJobTheme.cyanAccent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Firmen-DNA & Voice-Story',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Gebt Talenten und Machern einen authentischen Höreindruck.',
                            style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.mic_none_rounded, color: StoryJobTheme.cyanAccent),
                  title: const Text(
                    'Audio-Impuls aufnehmen (30 Sek.)',
                    style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: StoryJobTheme.cardSurface,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _audioUrl = 'https://storyjob.de/demo_audio.aac';
                    });
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.video_call_outlined, color: StoryJobTheme.primaryViolet),
                  title: const Text(
                    'Video-Impuls verknüpfen',
                    style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: StoryJobTheme.cardSurface,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _videoUrl = 'https://storyjob.de/demo_story.mp4';
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final resolvedName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'KRAFTWERK Feinmechanik';
    final resolvedIndustry = _industryController.text.trim().isNotEmpty
        ? _industryController.text.trim()
        : 'Handwerk & Präzision';

    try {
      final dna = CompanyDna(
        companyId: user.uid,
        name: resolvedName,
        website: _websiteController.text.trim(),
        industry: resolvedIndustry,
        missionQuote: _missionController.text.trim(),
        purposeVision: _purposeController.text.trim(),
        logoUrl: _logoUrl,
        videoStoryUrl: _videoUrl,
        audioStoryUrl: _audioUrl,
        isVerified: _isVerified,
      );

      final Map<String, dynamic> payload = {
        ...dna.toMap(),
        'cultureTags': _selectedCultureValues.toList(),
        'ecosystemBrand': 'StoryJob Teams',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.uid)
          .set(payload, SetOptions(merge: true));

      // Optional direkt als 24h Pulse-Status für Talente veröffentlichen
      if (_publishAsPulseStatus) {
        final statusText = _missionController.text.trim().isNotEmpty
            ? _missionController.text.trim()
            : 'Wir haben unsere StoryJob DNA aktualisiert (${_selectedCultureValues.take(2).join(' & ')}) ✨';

        await FirebaseFirestore.instance.collection('pulse_statuses').doc(user.uid).set({
          'authorId': user.uid,
          'authorRole': 'recruiter',
          'name': resolvedName,
          'roleOrTag': '$resolvedIndustry • StoryJob Teams',
          'message': statusText,
          'ecosystemBadge': 'StoryJob Teams',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _publishAsPulseStatus
                ? 'Firmen-DNA gespeichert & als 24h-Status geteilt ✨'
                : 'Firmen-DNA erfolgreich gespeichert ✨',
            style: const TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w500),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCustomInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: StoryJobTheme.textMuted, fontSize: 13),
          prefixIcon: Icon(prefixIcon, color: StoryJobTheme.cyanAccent, size: 19),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyName = _nameController.text.isNotEmpty ? _nameController.text : 'KRAFTWERK Feinmechanik';
    final industry = _industryController.text.isNotEmpty ? _industryController.text : 'Präzision, Tüftlergeist & Team';
    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'Firmen-DNA & Team-Kultur',
          style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===============================================================
            // 1. LIVE-PREVIEW KARTE (Talente-Sicht)
            // ===============================================================
            const Text(
              'SO SEHEN TALENTE EUER TEAM',
              style: TextStyle(
                color: StoryJobTheme.cyanAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            GlassCard(
              borderRadius: 24,
              borderGradient: StoryJobTheme.dnaCardBorder,
              hasNeonGlow: true,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _logoUrl = 'https://storyjob.de/assets/sample_logo.png');
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cardSurfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.6), width: 1.5),
                          ),
                          child: const Icon(Icons.precision_manufacturing_rounded, color: StoryJobTheme.cyanAccent, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: StoryJobTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              industry,
                              style: const TextStyle(
                                fontSize: 12,
                                color: StoryJobTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Aktive Kultur-Chips in der Live-Vorschau
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: _selectedCultureValues.map((tag) {
                      return _PreviewChip(
                        label: tag,
                        color: StoryJobTheme.cyanAccent,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Match-Halbbogen
                  SizedBox(
                    width: 120,
                    height: 64,
                    child: CustomPaint(
                      painter: _MiniArcPainter(progress: 0.96),
                      child: const Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "96%",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Werte-Match mit Talent-DNA",
                    style: TextStyle(fontSize: 11, color: StoryJobTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Voice-Story Leiste
                  GestureDetector(
                    onTap: _showMediaOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(16, (i) {
                                  final h = [10, 16, 24, 14, 28, 20, 12, 22, 18, 26, 12, 18, 14, 20, 10, 14];
                                  return Container(
                                    width: 3,
                                    height: h[i].toDouble(),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('0:24', style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===============================================================
            // 2. KULTUR- & WERTE-MERKMALE (Abgleich mit Talent-DNA)
            // ===============================================================
            const Text(
              'GELEBTE TEAM-WERTE AUSWÄHLEN',
              style: TextStyle(
                color: StoryJobTheme.cyanAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableCultureValues.map((value) {
                  final isSelected = _selectedCultureValues.contains(value);
                  return FilterChip(
                    label: Text(value),
                    selected: isSelected,
                    selectedColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.2),
                    backgroundColor: StoryJobTheme.cardSurfaceElevated,
                    checkmarkColor: StoryJobTheme.cyanAccent,
                    side: BorderSide(
                      color: isSelected
                          ? StoryJobTheme.cyanAccent.withValues(alpha: 0.6)
                          : StoryJobTheme.cardBorder,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (selected) {
                          _selectedCultureValues.add(value);
                        } else if (_selectedCultureValues.length > 1) {
                          _selectedCultureValues.remove(value);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),

            // ===============================================================
            // 3. BASIS-DATEN EINGABE
            // ===============================================================
            const Text(
              'TEAM-PROFIL BEARBEITEN',
              style: TextStyle(
                color: StoryJobTheme.cyanAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),

            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCustomInputField(
                    controller: _nameController,
                    hintText: 'Unternehmens- oder Teamname',
                    prefixIcon: Icons.apartment_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomInputField(
                    controller: _industryController,
                    hintText: 'Schwerpunkt & Branche (z.B. Feinmechanik)',
                    prefixIcon: Icons.category_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomInputField(
                    controller: _websiteController,
                    hintText: 'Website (z.B. https://storyjob.de)',
                    prefixIcon: Icons.language_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomInputField(
                    controller: _missionController,
                    hintText: 'Team-Motto („Wofür wir gemeinsam anpacken“)',
                    prefixIcon: Icons.format_quote_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCustomInputField(
                    controller: _purposeController,
                    hintText: 'Gelebte Werte & Teamgeist im Werkstatt-/Büroalltag',
                    prefixIcon: Icons.auto_awesome_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 24h Pulse-Status Verknüpfung
            GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: StoryJobTheme.cyanAccent,
                title: const Text(
                  'Direkt als 24h-Team-Status teilen',
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Erscheint sofort in der Pulse-Leiste passender Talente.',
                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11.5),
                ),
                value: _publishAsPulseStatus,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _publishAsPulseStatus = val);
                },
              ),
            ),
            const SizedBox(height: 20),

            // SPEICHERN BUTTON
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryJobTheme.primaryViolet,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: Text(
                  _isLoading ? 'Wird gespeichert...' : 'Firmen-DNA sichern ✨',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final String label;
  final Color color;

  const _PreviewChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MiniArcPainter extends CustomPainter {
  final double progress;
  _MiniArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 6;
    const strokeWidth = 5.5;

    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, bgPaint);

    const sweepGradient = SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: [
        StoryJobTheme.cyanAccent,
        StoryJobTheme.primaryViolet,
        StoryJobTheme.pinkMagenta,
      ],
    );

    final activePaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi * progress, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniArcPainter oldDelegate) => oldDelegate.progress != progress;
}