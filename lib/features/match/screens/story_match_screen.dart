// lib/features/match/screens/story_match_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/match/widgets/resonance_match_card.dart';

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
          'Höchstes Werte-Match ✨',
          'Ehrenamt & Macher',
          'Regionale Verwurzelung',
        ]
      : [
          'Alle Chancen',
          'Höchstes Werte-Match ✨',
          'Kultur & Teamgeist',
          'Flexibel & Frei',
        ];

  late List<Map<String, dynamic>> _visibleMatches;

  final List<Map<String, dynamic>> _initialMatches = [
    {
      'id': 'match_bright_minds',
      'company': 'Bright Minds Team',
      'role': 'Projekt- & Teamkoordination (m/w/d)',
      'resonanceLabel': '94%',
      'resonanceReason':
          'Ihr sucht beide sinnstiftende Wirkung vor starren Hierarchien. Das Team schätzt deine Hands-on-Mentalität.',
      'resonancePillars': ['Eigenverantwortung', 'Sinnstiftung', 'Miteinander'],
      'voiceImpulseTitle': '„Warum echte Fehlerkultur bei uns kein Bullshit-Bingo ist.“',
      'benefits': ['Flexible Einteilung', 'Gesundheitsvorsorge', '30 Tage Urlaub', 'Gestaltungsfreiraum'],
      'location': 'Region Passau / Remote',
      'salary': '55.000 € – 65.000 € p.a.',
      'isRemote': true,
      'category': 'kultur',
    },
    {
      'id': 'match_innovatech',
      'company': 'Innovatech Gemeinschaft',
      'role': 'Initiativen- & Transformationsleitung',
      'resonanceLabel': '88%',
      'resonanceReason':
          'Dein Engagement und deine Ausdauer passen genau zu den anspruchsvollen Projekten des Teams.',
      'resonancePillars': ['Krisenfestigkeit', 'Ehrenamt', 'Verlässlichkeit'],
      'voiceImpulseTitle': '„Wie wir asynchron und zu 100% remote entwickeln.“',
      'benefits': ['Nachhaltigkeit', 'Vorsorge-Budget', 'Gemeinschaft', 'Weiterbildung'],
      'location': 'Landshut / München',
      'salary': '70.000 € – 85.000 € p.a.',
      'isRemote': false,
      'category': 'workstyle',
    },
    {
      'id': 'match_future_systems',
      'company': 'Future Systems Handwerk & Tech',
      'role': 'Macher für regenerative Systeme',
      'resonanceLabel': '82%',
      'resonanceReason':
          'Ihr teilt dieselbe Vision über zukunftsorientierte Lösungen im Einklang mit Mensch und Natur.',
      'resonancePillars': ['Zukunftstechnologie', 'Hands-on', 'Nachhaltigkeit'],
      'voiceImpulseTitle': '„Unser Impact-Ziel für 2027 und warum wir Macher suchen.“',
      'benefits': ['Sichtbarer Nutzen', 'Moderne Ausstattung', 'Regionale Einsätze'],
      'location': 'Dingolfing / Bad Birnbach',
      'salary': 'Nach Vereinbarung',
      'isRemote': false,
      'category': 'vision',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    _visibleMatches = List.from(_initialMatches);
  }

  MatchAura _getAuraType(String category) {
    switch (category) {
      case 'workstyle':
        return MatchAura.workstyle;
      case 'vision':
        return MatchAura.vision;
      case 'kultur':
      case 'sinn':
      default:
        return MatchAura.culture;
    }
  }

  List<Map<String, dynamic>> _getFilteredMatches() {
    if (_selectedFilterIndex == 1) {
      return _visibleMatches.where((m) => m['resonanceLabel'] == '94%').toList();
    } else if (_selectedFilterIndex == 2) {
      return _visibleMatches.where((m) => m['category'] == 'sinn' || m['category'] == 'kultur').toList();
    } else if (_selectedFilterIndex == 3) {
      return _visibleMatches.where((m) => m['isRemote'] == true).toList();
    }
    return _visibleMatches;
  }

  void _handleMatch(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 18),
            SizedBox(width: 10),
            Text(
              'Team-Fit bestätigt! Dialog gestartet ✨',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: StoryJobTheme.cyanAccent, width: 1.0),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) {
        setState(() {
          _visibleMatches.removeWhere((m) => m['id'] == id);
        });
      }
    });
  }

  void _handlePass(String id) {
    setState(() {
      _visibleMatches.removeWhere((m) => m['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _getFilteredMatches();

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.3,
            colors: [
              Color(0xFF1B1435),
              StoryJobTheme.backgroundBase,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================================================
              // 1. APP-HEADER
              // ===============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 16),
                          SizedBox(width: 8),
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
                            Icon(Icons.fingerprint_rounded, color: StoryJobTheme.cyanAccent, size: 15),
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

              // ===============================================================
              // 2. TITELZEILE
              // ===============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team-Fit & Werte-Match',
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
                          ? 'Menschen, deren Haltung und Werte mit eurem Team matchen'
                          : 'Teams und Chancen auf deiner echten Wellenlänge',
                      style: const TextStyle(
                        fontSize: 13,
                        color: StoryJobTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // ===============================================================
              // 3. FILTER-LEISTE
              // ===============================================================
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
                                ? StoryJobTheme.primaryViolet.withValues(alpha: 0.24)
                                : StoryJobTheme.cardSurfaceElevated,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? StoryJobTheme.primaryViolet
                                  : StoryJobTheme.cardBorder,
                              width: 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : StoryJobTheme.textSecondary,
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

              // ===============================================================
              // 4. FEED DER RESONANCE-MATCH-CARDS
              // ===============================================================
              Expanded(
                child: filteredMatches.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4.0, bottom: 110.0),
                        itemCount: filteredMatches.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final matchData = filteredMatches[index];
                          final String matchId = matchData['id'] as String;

                          return ResonanceMatchCard(
                            key: ValueKey(matchId),
                            companyName: matchData['company'] as String,
                            matchPercentage: matchData['resonanceLabel'] as String,
                            auraType: _getAuraType(matchData['category'] as String),
                            voiceImpulseTitle: matchData['voiceImpulseTitle'] as String,
                            locationStr: matchData['location'] as String,
                            salaryStr: matchData['salary'] as String,
                            benefitsStr: (matchData['benefits'] as List<String>).take(2).join(' & '),
                            sharedValues: matchData['resonancePillars'] as List<String>,
                            onMatch: () => _handleMatch(matchId),
                            onPass: () => _handlePass(matchId),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StoryJobTheme.cardSurfaceElevated,
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              size: 42,
              color: StoryJobTheme.cyanAccent,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Keine offenen Matches',
            style: TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Wir suchen gerade nach Teams,\ndie auf deiner echten Wellenlänge funken.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}