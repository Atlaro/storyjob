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
  String? _videoUrl;
  String? _audioUrl;
  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  @override
  void dispose() {
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
      final dna = CompanyDna.fromMap(doc.data()!, doc.id);
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

    try {
      final dna = CompanyDna(
        companyId: user.uid,
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'KRAFTWERK Feinmechanik',
        website: _websiteController.text.trim(),
        industry: _industryController.text.trim().isNotEmpty ? _industryController.text.trim() : 'Handwerk & Präzision',
        missionQuote: _missionController.text.trim(),
        purposeVision: _purposeController.text.trim(),
        logoUrl: _logoUrl,
        videoStoryUrl: _videoUrl,
        audioStoryUrl: _audioUrl,
        isVerified: _isVerified,
      );

      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.uid)
          .set(dna.toMap(), SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Firmen-DNA erfolgreich gespeichert ✨',
            style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w500),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
      Navigator.of(context).pop();
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

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Firmen-DNA & Team-Kultur',
          style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===============================================================
            // 1. LIVE-PREVIEW KARTE (1:1 aus dem Mockup)
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
                  // Logo / Banner Bereich
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

                  // Kultur-Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: const [
                      _PreviewChip(label: 'Handwerk', color: StoryJobTheme.cyanAccent),
                      _PreviewChip(label: 'Präzision', color: StoryJobTheme.primaryViolet),
                      _PreviewChip(label: 'Tüftlergeist', color: StoryJobTheme.amberEnergy),
                    ],
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
            // 2. BASIS-DATEN EINGABE
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
            const SizedBox(height: 24),

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
            const SizedBox(height: 24),
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

    final sweepGradient = const SweepGradient(
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