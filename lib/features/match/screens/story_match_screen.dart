// lib/features/match/screens/story_match_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

typedef MatchItem = Map<String, dynamic>;

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
      ? ['Für euch', 'Top-Match ✨', 'Ehrenamt', 'Region']
      : ['Für dich', 'Top-Match ✨', 'Kultur', 'Flexibel'];

  late List<MatchItem> _visibleMatches;

  final List<MatchItem> _initialMatches = [
    {
      'id': 'match_bright_minds',
      'company': 'Bright Minds Team',
      'role': 'Projekt- & Teamkoordination (m/w/d)',
      'location': 'München & Hybrid',
      'timeAgo': 'Neu heute',
      'score': 94,
      'tags': <String>['Vollzeit', 'Teamgeist', 'Sinnstiftend'],
      'resonanceReason': 'Gleiche Haltung zu Eigenverantwortung und flachen Hierarchien.',
      'category': 'kultur',
      'saved': false,
    },
    {
      'id': 'match_innovatech',
      'company': 'Innovatech Gemeinschaft',
      'role': 'Initiativen- & Transformationsleitung',
      'location': 'Hamburg / Remote',
      'timeAgo': 'Vor 1d',
      'score': 88,
      'tags': <String>['Führung', 'Gestaltung', 'Innovation'],
      'resonanceReason': 'Dein Engagement passt genau zu den Zukunftsprojekten des Teams.',
      'category': 'workstyle',
      'saved': false,
    },
    {
      'id': 'match_future_systems',
      'company': 'Future Systems Handwerk & Tech',
      'role': 'Macher für regenerative Systeme',
      'location': 'München',
      'timeAgo': 'Vor 2d',
      'score': 82,
      'tags': <String>['Praxis', 'Nachhaltigkeit', 'Region'],
      'resonanceReason': 'Gemeinsame Vision über zukunftsorientierte Lösungen in der Region.',
      'category': 'vision',
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

  void _handleMatch(String id, String company) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dialog mit $company gestartet ✨',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: StoryJobTheme.cyanAccent),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _visibleMatches.removeWhere((m) => m['id'] == id);
        });
      }
    });
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
                  GestureDetector(
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
                ],
              ),
            ),

            // Saubere Unterstrich-Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: StoryJobTheme.cardBorder, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return GestureDetector(
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
                  );
                }),
              ),
            ),

            // Kartenliste im aufgeräumten Split-Card-Design
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

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: StoryJobTheme.cardBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LINKE SPALTE: Match-Score & Merken
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
                                  IconButton(
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
                                ],
                              ),

                              const SizedBox(width: 14),

                              // RECHTE SPALTE: Infos & Direkt-Aktion
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
                                      match['company'] as String,
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
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleMatch(
                                          match['id'] as String,
                                          match['company'] as String,
                                        ),
                                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                                        label: const Text(
                                          'Kennenlernen',
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: StoryJobTheme.mintSuccess,
                                          foregroundColor: const Color(0xFF0A0B10),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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