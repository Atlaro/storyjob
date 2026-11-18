// lib/features/match/screens/story_match_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/match/screens/match_screen.dart';

typedef MatchItem = Map<String, dynamic>;

class StoryMatchScreen extends StatefulWidget {
  final int initialFilterIndex;
  final bool isteam;
  final VoidCallback? onOpenDna;

  const StoryMatchScreen({
    super.key,
    this.initialFilterIndex = 0,
    this.isteam = false,
    this.onOpenDna,
  });

  @override
  State<StoryMatchScreen> createState() => _StoryMatchScreenState();
}

class _StoryMatchScreenState extends State<StoryMatchScreen> {
  late int _selectedFilterIndex;

  List<String> get _filters => widget.isteam
      ? ['Für euch', 'Top-Match ✨', 'Ehrenamt', 'Region']
      : ['Für dich', 'Top-Match ✨', 'Kultur', 'Flexibel'];

  late List<MatchItem> _visibleMatches;

  final List<MatchItem> _initialMatches = [
    {
      'id': 'match_bright_minds',
      'team': 'Bright Minds Team',
      'role': 'Projekt- & Teamkoordination (m/w/d)',
      'location': 'München & Hybrid',
      'timeAgo': 'Neu heute',
      'score': 94,
      'matchScore': '94%',
      'tags': <String>['Vollzeit', 'Teamgeist', 'Sinnstiftend'],
      'resonanceReason': 'Gleiche Haltung zu Eigenverantwortung und flachen Hierarchien.',
      'resonancePillars': <String>['Transparenz', 'Eigenverantwortung', 'Miteinander'],
      'benefits': <String>['Flexible Arbeitszeiten', 'Remote Option', 'Weiterbildungsbudget'],
      'category': 'kultur',
      'isRemote': true,
      'saved': false,
    },
    {
      'id': 'match_innovatech',
      'team': 'Innovatech Gemeinschaft',
      'role': 'Initiativen- & Transformationsleitung',
      'location': 'Hamburg / Remote',
      'timeAgo': 'Vor 1d',
      'score': 88,
      'matchScore': '88%',
      'tags': <String>['Führung', 'Gestaltung', 'Innovation'],
      'resonanceReason': 'Dein Engagement passt genau zu den Zukunftsprojekten des Teams.',
      'resonancePillars': <String>['Gestaltungsfreiraum', 'Agilität', 'Innovationskraft'],
      'benefits': <String>['Home-Office-Pauschale', 'Modern Stack', 'Mentoring'],
      'category': 'workstyle',
      'isRemote': true,
      'saved': false,
    },
    {
      'id': 'match_future_systems',
      'team': 'Future Systems Handwerk & Tech',
      'role': 'Macher für regenerative Systeme',
      'location': 'München',
      'timeAgo': 'Vor 2d',
      'score': 82,
      'matchScore': '82%',
      'tags': <String>['Praxis', 'Nachhaltigkeit', 'Region'],
      'resonanceReason': 'Gemeinsame Vision über zukunftsorientierte Lösungen in der Region.',
      'resonancePillars': <String>['Nachhaltigkeit', 'Regionale Wirkung', 'Handwerk trifft Tech'],
      'benefits': <String>['Fahrtkostenzuschuss', 'Kantine', 'Öko-Strom'],
      'category': 'vision',
      'isRemote': false,
      'saved': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    _visibleMatches = List<MatchItem>.from(_initialMatches);
  }

  List<MatchItem> _getFilteredMatches() {
    if (_selectedFilterIndex == 1) {
      return _visibleMatches.where((m) => (m['score'] as int) >= 90).toList();
    } else if (_selectedFilterIndex == 2) {
      return _visibleMatches.where((m) => m['category'] == 'kultur').toList();
    }
    return _visibleMatches;
  }

  void _openDetail(MatchItem match) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryMatchDetailScreen(matchData: match),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _getFilteredMatches();

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kompakter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Werte-Matches',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Semantics(
                    label: 'DNA Status aktiv. Tippen zum Öffnen.',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onOpenDna?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: StoryJobTheme.primaryViolet.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.fingerprint_rounded, color: StoryJobTheme.cyanAccent, size: 15),
                            SizedBox(width: 6),
                            Text(
                              'DNA aktiv',
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
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: StoryJobTheme.cardBorder, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Semantics(
                    label: 'Filter ${_filters[index]}',
                    selected: isSelected,
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFilterIndex = index);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? StoryJobTheme.cyanAccent : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Match-Kartenliste
            Expanded(
              child: filteredMatches.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                      itemCount: filteredMatches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final match = filteredMatches[index];
                        final int score = match['score'] as int;
                        final bool isSaved = match['saved'] as bool;
                        final List<String> tags = match['tags'] as List<String>;
                        final String teamName = match['team'] as String;

                        return InkWell(
                          onTap: () => _openDetail(match),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: StoryJobTheme.cardBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Linke Spalte: Score & Bookmark
                                Column(
                                  children: [
                                    Container(
                                      width: 64,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.bolt_rounded,
                                            color: StoryJobTheme.cyanAccent,
                                            size: 16,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$score%',
                                            style: const TextStyle(
                                              color: StoryJobTheme.cyanAccent,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const Text(
                                            'Match',
                                            style: TextStyle(
                                              color: StoryJobTheme.textSecondary,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Semantics(
                                      label: isSaved ? 'Aus Merkliste entfernen' : 'Merken',
                                      button: true,
                                      child: IconButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            match['saved'] = !isSaved;
                                          });
                                        },
                                        icon: Icon(
                                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                          color: isSaved ? StoryJobTheme.amberEnergy : StoryJobTheme.textMuted,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 14),

                                // Rechte Spalte: Details & Kennenlernen-Button
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            match['location'] as String,
                                            style: const TextStyle(
                                              color: StoryJobTheme.textSecondary,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: StoryJobTheme.cardSurfaceElevated,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              match['timeAgo'] as String,
                                              style: const TextStyle(
                                                color: StoryJobTheme.textMuted,
                                                fontSize: 10.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        match['role'] as String,
                                        style: const TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        teamName,
                                        style: const TextStyle(
                                          color: StoryJobTheme.primaryViolet,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: StoryJobTheme.cardSurfaceElevated,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(
                                                color: StoryJobTheme.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        match['resonanceReason'] as String,
                                        style: const TextStyle(
                                          color: StoryJobTheme.textSecondary,
                                          fontSize: 12,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Semantics(
                                        label: 'Kennenlernen und Details zu $teamName öffnen',
                                        button: true,
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 40,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _openDetail(match),
                                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                                            label: const Text(
                                              'Kennenlernen',
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: StoryJobTheme.cyanAccent,
                                              foregroundColor: const Color(0xFF0A0B10),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.graphic_eq_rounded, size: 42, color: StoryJobTheme.cyanAccent),
          SizedBox(height: 14),
          Text(
            'Alle aktuellen Matches angesehen',
            style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Schau später wieder vorbei für neue Vorschläge.',
            style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}