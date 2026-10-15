// lib/features/recruiter/screens/recruiter_talent_pool_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class RecruiterTalentPoolScreen extends StatefulWidget {
  const RecruiterTalentPoolScreen({super.key});

  @override
  State<RecruiterTalentPoolScreen> createState() => _RecruiterTalentPoolScreenState();
}

class _RecruiterTalentPoolScreenState extends State<RecruiterTalentPoolScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'Alle Macher (18)',
    '🚒 Feuerwehr & BRK',
    '✨ Höchstes Werte-Match (90%+)',
    '⚡ Macher & Haltung',
    '🌱 Nachhaltigkeit & Impact',
  ];

  final List<Map<String, dynamic>> _talents = [
    {
      'name': 'Peter Alt',
      'handle': 'peter',
      'roleFocus': 'Vertriebsleitung & Projektentwicklung',
      'matchScore': '95%',
      'scoreValue': 95,
      'isProtected': false, // Bereit für direkten Dialog
      'matchReason':
          'Bringt bewiesene Krisenfestigkeit & Führungserfahrung aus dem Ehrenamt (BRK/Feuerwehr) mit. Sucht echte Werte vor starren Hierarchien.',
      'pillars': ['Krisenfestigkeit', 'Ehrenamt', 'Hands-on', 'Führung'],
      'engagement': ['🚒 Feuerwehr', '🚑 BRK Katastrophenschutz'],
      'values': ['Verantwortung', 'Verlässlichkeit', 'Innovation'],
      'audioDuration': '01:43 Min.',
      'audioUrl': 'https://storyjob.de/demo_audio_peter.aac',
      'audioPitchSnippet': '„Warum für mich Verlässlichkeit und echter Teameinsatz an erster Stelle stehen...“',
      'location': 'Niederbayern • Hybrid / Remote',
      'category': 'ehrenamt',
      'accentColor': StoryJobTheme.cyanAccent,
    },
    {
      'name': 'Sarah Lindner',
      'handle': 'sarah_l',
      'roleFocus': 'Scrum Master & Agile Coach',
      'matchScore': '91%',
      'scoreValue': 91,
      'isProtected': true, // Geschütztes, anonymisiertes Profil
      'matchReason':
          'Hohe Empathie und Moderationsstärke. Engagiert in regionalen Bildungsinitiativen und Mentoring.',
      'pillars': ['Teamfit', 'Kommunikation', 'Agilität'],
      'engagement': ['🌱 Bildungs-Initiative', '📚 Mentoring'],
      'values': ['Offenheit', 'Lernbereitschaft', 'Empathie'],
      'audioDuration': '01:12 Min.',
      'audioUrl': 'https://storyjob.de/demo_audio_sarah.aac',
      'audioPitchSnippet': '„Wie wir Teams befähigen, eigenständig Verantwortung zu übernehmen...“',
      'location': 'München • Remote',
      'category': 'macher',
      'accentColor': StoryJobTheme.primaryViolet,
    },
    {
      'name': 'Michael Gruber',
      'handle': 'mgruber',
      'roleFocus': 'GreenTech Ingenieur & Energieberater',
      'matchScore': '88%',
      'scoreValue': 88,
      'isProtected': false,
      'matchReason':
          'Spezialisiert auf Photovoltaik-Großprojekte und Energiespeicher. Sucht Teams mit echtem Nachhaltigkeits-Fokus.',
      'pillars': ['GreenTech', 'Pragmatismus', 'Umsetzung'],
      'engagement': ['🌱 Bürgerenergie', '🔋 Solar-Netzwerk'],
      'values': ['Nachhaltigkeit', 'Qualität', 'Zukunft'],
      'audioDuration': '01:25 Min.',
      'audioUrl': 'https://storyjob.de/demo_audio_michael.aac',
      'audioPitchSnippet': '„Projekte müssen nicht nur auf dem Papier grün sein, sondern in der Praxis funktionieren...“',
      'location': 'Passau / Landshut • Hybrid',
      'category': 'nachhaltig',
      'accentColor': StoryJobTheme.mintSuccess,
    },
  ];

  @override
  void dispose() {
    AudioService.stopAudio();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredTalents() {
    if (_selectedFilterIndex == 1) {
      return _talents.where((t) => t['category'] == 'ehrenamt').toList();
    } else if (_selectedFilterIndex == 2) {
      return _talents.where((t) => (t['scoreValue'] as int) >= 90).toList();
    } else if (_selectedFilterIndex == 3) {
      return _talents.where((t) => (t['pillars'] as List<String>).contains('Führung') || t['category'] == 'macher').toList();
    } else if (_selectedFilterIndex == 4) {
      return _talents.where((t) => t['category'] == 'nachhaltig').toList();
    }
    return _talents;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTalents = _getFilteredTalents();

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App-Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.shield_outlined, color: StoryJobTheme.cyanAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Anonymitäts-Schutz aktiv',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      'Werte-Geprüft ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'TALENT-POOL • WERTE-MATCHING',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Echte Macher entdecken',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFilterIndex = index);
                        }
                      },
                      selectedColor: StoryJobTheme.primaryViolet,
                      backgroundColor: StoryJobTheme.cardSurfaceElevated,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : StoryJobTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? StoryJobTheme.primaryViolet : StoryJobTheme.cardBorder,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredTalents.isEmpty
                  ? const Center(
                      child: Text(
                        'Keine Macher für diese Auswahl gefunden.',
                        style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 110.0),
                      itemCount: filteredTalents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _RecruiterTalentCard(talentData: filteredTalents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecruiterTalentCard extends StatefulWidget {
  final Map<String, dynamic> talentData;

  const _RecruiterTalentCard({required this.talentData});

  @override
  State<_RecruiterTalentCard> createState() => _RecruiterTalentCardState();
}

class _RecruiterTalentCardState extends State<_RecruiterTalentCard> {
  bool _isPlaying = false;
  bool _isBookmarked = false;

  Future<void> _toggleAudio(String? audioUrl) async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await AudioService.stopAudio();
      setState(() => _isPlaying = false);
    } else {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await AudioService.playAudio(audioUrl);
        setState(() => _isPlaying = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isProtected = widget.talentData['isProtected'] ?? false;
    final name = isProtected ? 'Geschütztes Profil' : widget.talentData['name'] as String;
    final handle = isProtected ? 'anonym' : widget.talentData['handle'] as String;
    final roleFocus = widget.talentData['roleFocus'] as String;
    final matchScore = widget.talentData['matchScore'] as String;
    final double numericScore = (widget.talentData['scoreValue'] as int).toDouble();
    final matchReason = widget.talentData['matchReason'] as String;
    final pillars = widget.talentData['pillars'] as List<String>;
    final engagement = widget.talentData['engagement'] as List<String>;
    final values = widget.talentData['values'] as List<String>;
    final audioDuration = widget.talentData['audioDuration'] as String;
    final audioPitchSnippet = widget.talentData['audioPitchSnippet'] as String;
    final String? audioUrl = widget.talentData['audioUrl'] as String?;
    final location = widget.talentData['location'] as String;
    final Color accentColor = widget.talentData['accentColor'] as Color;

    return GlassCard(
      borderRadius: 22,
      borderGradient: isProtected ? null : StoryJobTheme.dnaCardBorder,
      hasNeonGlow: !isProtected,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isProtected ? StoryJobTheme.cardSurfaceElevated : accentColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: isProtected ? StoryJobTheme.cyanAccent : accentColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isProtected ? Icons.shield_rounded : Icons.person_rounded,
                    color: isProtected ? StoryJobTheme.cyanAccent : Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '@$handle',
                          style: const TextStyle(fontSize: 12, color: StoryJobTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleFocus,
                      style: const TextStyle(fontSize: 13, color: StoryJobTheme.cyanAccent, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(location, style: const TextStyle(fontSize: 11.5, color: StoryJobTheme.textSecondary)),
                  ],
                ),
              ),
              // Halbbogen Anzeige für den Match-Score
              Column(
                children: [
                  SizedBox(
                    width: 48,
                    height: 26,
                    child: CustomPaint(
                      painter: _MiniCardArcPainter(progress: numericScore / 100.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          matchScore,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Team-Fit', style: TextStyle(fontSize: 9, color: StoryJobTheme.textSecondary)),
                ],
              ),
              IconButton(
                padding: const EdgeInsets.only(left: 6),
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _isBookmarked ? StoryJobTheme.amberEnergy : StoryJobTheme.textSecondary,
                  size: 22,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isBookmarked = !_isBookmarked);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Werte-Match Begründung
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StoryJobTheme.primaryViolet.withValues(alpha: 0.30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Werte-Match für euer Team',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: StoryJobTheme.cyanAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(matchReason, style: const TextStyle(fontSize: 12.5, color: StoryJobTheme.textPrimary, height: 1.4)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: pillars.map((pillar) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 12, color: StoryJobTheme.cyanAccent),
                        const SizedBox(width: 3),
                        Text(pillar, style: const TextStyle(color: StoryJobTheme.cyanAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Audio-Leiste mit Wellenform
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _toggleAudio(audioUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _isPlaying ? StoryJobTheme.cyanAccent : StoryJobTheme.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      audioPitchSnippet,
                      style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 12, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(audioDuration, style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...engagement.map((eng) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.mintSuccess.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StoryJobTheme.mintSuccess.withValues(alpha: 0.35)),
                    ),
                    child: Text(eng, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: StoryJobTheme.mintSuccess)),
                  )),
              ...values.map((val) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: StoryJobTheme.textSecondary)),
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Buttons je nach Schutz-Status
          if (isProtected)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Freigabe-Anfrage an das Talent gesendet ✨'),
                      backgroundColor: StoryJobTheme.cardSurfaceElevated,
                    ),
                  );
                },
                icon: const Icon(Icons.lock_open_rounded, size: 16),
                label: const Text('Profil-Freigabe anfragen', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                  foregroundColor: StoryJobTheme.cyanAccent,
                  side: const BorderSide(color: StoryJobTheme.cyanAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StoryDialogScreen(
                            chatId: 'chat_$handle',
                            targetName: name,
                            roleContext: roleFocus,
                            matchScore: matchScore,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.forum_rounded, size: 15),
                    label: const Text('Dialog auf Augenhöhe ✨', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryJobTheme.primaryViolet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

class _MiniCardArcPainter extends CustomPainter {
  final double progress;
  _MiniCardArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 3;
    const strokeWidth = 3.5;

    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, bgPaint);

    final sweepGradient = const SweepGradient(
      startAngle: pi,
      endAngle: 2 * pi,
      colors: [StoryJobTheme.cyanAccent, StoryJobTheme.primaryViolet],
    );

    final activePaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi * progress, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniCardArcPainter oldDelegate) => oldDelegate.progress != progress;
}