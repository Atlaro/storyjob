// lib/features/match/screens/story_match_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';
import 'package:storyjob/features/match/screens/match_screen.dart';

class StoryMatchScreen extends StatefulWidget {
  final int initialFilterIndex;
  final bool isRecruiter;
  final VoidCallback? onOpenDna;

  const StoryMatchScreen({
    super.key,
    this.initialFilterIndex = 0,
    this.isRecruiter = false,
    this.onOpenDna,
  });

  @override
  State<StoryMatchScreen> createState() => _StoryMatchScreenState();
}

class _StoryMatchScreenState extends State<StoryMatchScreen> {
  late int _selectedFilterIndex;

  List<String> get _filters => widget.isRecruiter
      ? [
          'Alle Begegnungen',
          'Hohe Resonanz ✨',
          'Ehrenamt & Macher',
          'Regionale Verwurzelung',
        ]
      : [
          'Alle Chancen',
          'Hohe Resonanz ✨',
          'Sinn & Kultur',
          'Flexibel & Frei',
        ];

  final List<Map<String, dynamic>> _talentMatches = [
    {
      'id': 'match_bright_minds',
      'company': 'Bright Minds Team',
      'role': 'Marketing & Community Lead (m/w/d)',
      'matchScore': '94%',
      'scoreValue': 94,
      'resonanceReason':
          'Ihr sucht beide sinnstiftende Wirkung vor starren Hierarchien. Bright Minds schätzt deine Hands-on-Mentalität.',
      'resonancePillars': ['Eigenverantwortung', 'Sinnstiftung', 'Teamfit'],
      'cultureAudioSnippet': '„Hör dir unseren Gründer-Pitch zu flexibler Führung an...“',
      'cultureAudioDuration': '0:35',
      'audioUrl': '',
      'benefits': ['Remote', 'bKV Gesundheit', '30 Tage', 'Flexible Zeit'],
      'location': 'Remote • Berlin',
      'accentColor': StoryJobTheme.cyanAccent,
      'isRemote': true,
      'category': 'sinn',
    },
    {
      'id': 'match_innovatech',
      'company': 'Innovatech Gemeinschaft',
      'role': 'Projektmanager Transformation (m/w/d)',
      'matchScore': '89%',
      'scoreValue': 89,
      'resonanceReason':
          'Dein Engagement und deine Ausdauer passen genau zu den Transformationsprojekten des Teams.',
      'resonancePillars': ['Krisenfestigkeit', 'Ehrenamt', 'Lernbereitschaft'],
      'cultureAudioSnippet': '„Wie wir als Team bei neuen Wegen zusammenstehen...“',
      'cultureAudioDuration': '0:26',
      'audioUrl': '',
      'benefits': ['Nachhaltigkeit', 'bAV Vorsorge', 'Hybrid', 'Weiterbildung'],
      'location': 'München • Hybrid',
      'accentColor': StoryJobTheme.primaryViolet,
      'isRemote': false,
      'category': 'kultur',
    },
    {
      'id': 'match_future_systems',
      'company': 'Future Systems',
      'role': 'Product Owner GreenTech (m/w/d)',
      'matchScore': '84%',
      'scoreValue': 84,
      'resonanceReason':
          'Ihr teilt dieselbe Vision über zukunftsorientierte Technologie im Einklang mit der Natur.',
      'resonancePillars': ['GreenTech', 'Teamfit', 'Innovation'],
      'cultureAudioSnippet': '„Unsere Vision für nachhaltige Software & offene Teamstrukturen...“',
      'cultureAudioDuration': '0:42',
      'audioUrl': '',
      'benefits': ['Echter Impact', 'E-Auto Budget', '30 Tage'],
      'location': 'Dingolfing / Landshut',
      'accentColor': StoryJobTheme.champagneGold,
      'isRemote': false,
      'category': 'sinn',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
  }

  @override
  void dispose() {
    AudioService.stopAudio();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredMatches() {
    if (_selectedFilterIndex == 1) {
      return _talentMatches.where((m) => (m['scoreValue'] as int) >= 85).toList();
    } else if (_selectedFilterIndex == 2) {
      return _talentMatches.where((m) => m['category'] == 'sinn' || m['category'] == 'kultur').toList();
    } else if (_selectedFilterIndex == 3) {
      return _talentMatches.where((m) => m['isRemote'] == true).toList();
    }
    return _talentMatches;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _getFilteredMatches();

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: StoryJobTheme.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: StoryJobTheme.cyanAccent,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'StoryJob',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onOpenDna?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.fingerprint_rounded, color: StoryJobTheme.primaryViolet, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'StoryJob DNA aktiv',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
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
            ),

            // Titel
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Werte-Resonanz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.isRecruiter
                        ? 'Menschen, deren Haltung exakt zu euch passt'
                        : 'Teams und Chancen auf deiner Wellenlänge',
                    style: const TextStyle(
                      fontSize: 13,
                      color: StoryJobTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Segmentierte Filter-Leiste
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilterIndex = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? StoryJobTheme.primaryViolet.withValues(alpha: 0.22)
                              : StoryJobTheme.cardSurfaceElevated,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? StoryJobTheme.primaryViolet.withValues(alpha: 0.50)
                                : StoryJobTheme.cardBorder,
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredMatches.isEmpty
                  ? const Center(
                      child: Text(
                        'Keine Chancen für diesen Filter gefunden.',
                        style: TextStyle(color: StoryJobTheme.textMuted, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 18.0, 100.0),
                      itemCount: filteredMatches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _MatchCardItem(matchData: filteredMatches[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCardItem extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const _MatchCardItem({required this.matchData});

  @override
  State<_MatchCardItem> createState() => _MatchCardItemState();
}

class _MatchCardItemState extends State<_MatchCardItem> {
  bool _isPlaying = false;
  bool _isBookmarked = false;

  Future<void> _toggleAudio() async {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlaying = false);
    } else {
      final audioUrl = widget.matchData['audioUrl'] as String?;
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await AudioService.playAudio(audioUrl);
      }
      if (mounted) setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.matchData['role'] as String;
    final company = widget.matchData['company'] as String;
    final matchScoreStr = widget.matchData['matchScore'] as String;
    final resonanceReason = widget.matchData['resonanceReason'] as String;
    final resonancePillars = widget.matchData['resonancePillars'] as List<String>? ?? [];
    final cultureAudioSnippet = widget.matchData['cultureAudioSnippet'] as String;
    final cultureAudioDuration = widget.matchData['cultureAudioDuration'] as String;
    final benefits = widget.matchData['benefits'] as List<String>;
    final location = widget.matchData['location'] as String;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isPlaying
              ? StoryJobTheme.cyanAccent.withValues(alpha: 0.45)
              : StoryJobTheme.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StoryJobTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$company  •  $location',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: StoryJobTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
                ),
                child: Text(
                  matchScoreStr,
                  style: const TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isBookmarked = !_isBookmarked);
                },
                child: Icon(
                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: _isBookmarked ? StoryJobTheme.champagneGold : StoryJobTheme.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Erklärung
          Text(
            resonanceReason,
            style: const TextStyle(
              fontSize: 13,
              color: StoryJobTheme.textPrimary,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),

          if (resonancePillars.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: resonancePillars.map((pillar) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 12, color: StoryJobTheme.cyanAccent),
                    const SizedBox(width: 4),
                    Text(
                      pillar,
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          // Audio Snippet
          GestureDetector(
            onTap: _toggleAudio,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _isPlaying
                    ? StoryJobTheme.cyanAccent.withValues(alpha: 0.12)
                    : StoryJobTheme.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isPlaying
                      ? StoryJobTheme.cyanAccent.withValues(alpha: 0.40)
                      : StoryJobTheme.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cultureAudioSnippet,
                      style: TextStyle(
                        color: _isPlaying ? StoryJobTheme.cyanAccent : StoryJobTheme.textPrimary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cultureAudioDuration,
                    style: const TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Benefits
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: benefits.map((benefit) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Text(
                  benefit,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: StoryJobTheme.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryMatchDetailScreen(matchData: widget.matchData),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StoryJobTheme.textPrimary,
                    side: const BorderSide(color: StoryJobTheme.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Chance ansehen', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final company = widget.matchData['company'] as String;
                    final role = widget.matchData['role'] as String;
                    final matchScore = widget.matchData['matchScore'] as String;
                    final cleanChatId = 'chat_${company.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_')}';

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StoryDialogScreen(
                          chatId: cleanChatId,
                          targetName: company,
                          roleContext: role,
                          matchScore: matchScore,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.forum_rounded, size: 15),
                  label: const Text('Dialog starten', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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