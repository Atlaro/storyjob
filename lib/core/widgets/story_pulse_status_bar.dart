// lib/core/widgets/story_pulse_status_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class PulseStatusItem {
  final String id;
  final String name;
  final String roleOrTag;
  final String timeAgo;
  final String message;
  final String ecosystemBadge; // z. B. "StoryJob DNA" oder "StoryJob Teams"
  final Color accentColor;
  bool isSeen;

  PulseStatusItem({
    required this.id,
    required this.name,
    required this.roleOrTag,
    required this.timeAgo,
    required this.message,
    required this.ecosystemBadge,
    required this.accentColor,
    this.isSeen = false,
  });
}

class StoryPulseStatusBar extends StatefulWidget {
  final bool isRecruiter;
  final String currentUserName;

  const StoryPulseStatusBar({
    super.key,
    required this.isRecruiter,
    required this.currentUserName,
  });

  @override
  State<StoryPulseStatusBar> createState() => _StoryPulseStatusBarState();
}

class _StoryPulseStatusBarState extends State<StoryPulseStatusBar> {
  PulseStatusItem? _ownStatus;
  late List<PulseStatusItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.isRecruiter ? _recruiterFeedItems() : _talentFeedItems();
  }

  // Für Talente: Einblicke von Betrieben, Vereinen & Teams
  List<PulseStatusItem> _talentFeedItems() => [
        PulseStatusItem(
          id: 'status_bright_minds',
          name: 'Bright Minds',
          roleOrTag: 'München • Team-Kultur',
          timeAgo: 'Vor 1 Std.',
          message:
              'Heute Morgen gemeinsames Kick-off auf der Terrasse – bei uns zählt jede Idee auf Augenhöhe! 🚀',
          ecosystemBadge: 'StoryJob Teams',
          accentColor: StoryJobTheme.cyanAccent,
        ),
        PulseStatusItem(
          id: 'status_innovatech',
          name: 'Innovatech',
          roleOrTag: 'Hamburg • Technik',
          timeAgo: 'Vor 3 Std.',
          message:
              'Frischer Kaffee, neues Zukunftsprojekt in der Region – wir suchen Macher mit Hands-on-Mentalität.',
          ecosystemBadge: 'StoryJob DNA • 88%',
          accentColor: StoryJobTheme.primaryViolet,
        ),
        PulseStatusItem(
          id: 'status_future_systems',
          name: 'Future Systems',
          roleOrTag: 'Berlin • Handwerk',
          timeAgo: 'Vor 5 Std.',
          message:
              'Fertigstellung unserer neuesten regenerativen Anlage – stolz auf unser eingespieltes Team!',
          ecosystemBadge: 'StoryJob Teams',
          accentColor: StoryJobTheme.pinkMagenta,
        ),
      ];

  // Für Recruiter & Teams: Aktive Talente & DNA-Impulse
  List<PulseStatusItem> _recruiterFeedItems() => [
        PulseStatusItem(
          id: 'talent_lukas',
          name: 'Lukas M.',
          roleOrTag: 'Projektleitung • 94% DNA',
          timeAgo: 'Vor 45 Min.',
          message:
              'Habe gerade meine StoryJob DNA geschärft: Suche ein Team mit klarer Haltung und Gestaltungsspielraum.',
          ecosystemBadge: 'StoryJob DNA • 94%',
          accentColor: StoryJobTheme.cyanAccent,
        ),
        PulseStatusItem(
          id: 'talent_sarah',
          name: 'Sarah K.',
          roleOrTag: 'Organisation & Ehrenamt',
          timeAgo: 'Vor 2 Std.',
          message:
              'Verantwortung übernehmen und gemeinsam anpacken – offen für Kennenlernen im deiner Region.',
          ecosystemBadge: 'StoryJob DNA • 91%',
          accentColor: StoryJobTheme.pinkMagenta,
        ),
        PulseStatusItem(
          id: 'talent_markus',
          name: 'Markus W.',
          roleOrTag: 'System- & Handwerkstechnik',
          timeAgo: 'Vor 4 Std.',
          message:
              'Neue 30-Sekunden-Voice-Story aufgenommen – hört gerne rein, wofür ich brenne!',
          ecosystemBadge: 'StoryJob DNA • 87%',
          accentColor: StoryJobTheme.primaryViolet,
        ),
      ];

  void _openComposer() {
    HapticFeedback.mediumImpact();
    final TextEditingController controller = TextEditingController(
      text: _ownStatus?.message ?? '',
    );

    final List<String> quickTemplates = widget.isRecruiter
        ? [
            'Einblick aus unserem Team-Alltag heute 👋',
            'Wir suchen Verstärkung mit Herz & Haltung ✨',
            'Offen für ein unverbindliches Kennenlernen ☕',
          ]
        : [
            'Offen für spannende Gespräche & Projekte 👋',
            'Habe meine StoryJob DNA aktualisiert 🧬',
            'Suche ein Team auf gleicher Wellenlänge ✨',
          ];

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
              top: BorderSide(
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.4),
                width: 1.2,
              ),
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
              const SizedBox(height: 18),
              Text(
                widget.isRecruiter ? '24h Team-Status teilen' : '24h Vibe-Status teilen',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isRecruiter
                    ? 'Zeigt Talenten, was euer Team gerade bewegt.'
                    : 'Zeige Betrieben & Teams deinen aktuellen Fokus.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: StoryJobTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickTemplates.map((tpl) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.text = tpl;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                      ),
                      child: Text(
                        tpl,
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 160,
                style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Kurzer Impuls für 24 Stunden...',
                  hintStyle: const TextStyle(color: StoryJobTheme.textMuted),
                  filled: true,
                  fillColor: StoryJobTheme.backgroundBase,
                  counterStyle: const TextStyle(color: StoryJobTheme.textMuted, fontSize: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: StoryJobTheme.cyanAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _ownStatus = PulseStatusItem(
                        id: 'own_status',
                        name: widget.currentUserName,
                        roleOrTag: widget.isRecruiter ? 'Euer Team • Live' : 'Dein Status • Live',
                        timeAgo: 'Gerade eben',
                        message: text,
                        ecosystemBadge: widget.isRecruiter ? 'StoryJob Teams' : 'StoryJob DNA',
                        accentColor: StoryJobTheme.cyanAccent,
                        isSeen: false,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.cyanAccent,
                    foregroundColor: const Color(0xFF0A0B10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Status für 24 Std. veröffentlichen',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openStatusViewer(PulseStatusItem item, {bool isOwn = false}) {
    HapticFeedback.lightImpact();
    setState(() {
      item.isSeen = true;
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _PulseStatusViewerOverlay(
          item: item,
          isOwn: isOwn,
          isRecruiterViewer: widget.isRecruiter,
          onEditOwn: () {
            Navigator.pop(context);
            _openComposer();
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isRecruiter ? 'Aktive Talente & Impulse' : 'Live aus Teams & Kultur',
                style: const TextStyle(
                  color: StoryJobTheme.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '24h Pulse',
                style: TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Eigener Status-Kreis
              _buildOwnCircle(),
              const SizedBox(width: 14),
              // 2. Feed-Status-Kreise
              ..._items.map((item) => Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: _buildFeedCircle(item),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnCircle() {
    final bool hasStatus = _ownStatus != null;
    return GestureDetector(
      onTap: () {
        if (hasStatus) {
          _openStatusViewer(_ownStatus!, isOwn: true);
        } else {
          _openComposer();
        }
      },
      onLongPress: _openComposer,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasStatus
                        ? const LinearGradient(
                            colors: [
                              StoryJobTheme.cyanAccent,
                              StoryJobTheme.primaryViolet,
                              StoryJobTheme.pinkMagenta,
                            ],
                          )
                        : null,
                    border: hasStatus
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isRecruiter ? Icons.groups_rounded : Icons.person_rounded,
                      color: StoryJobTheme.textPrimary,
                      size: 26,
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: _openComposer,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: StoryJobTheme.backgroundBase, width: 2),
                      ),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF0A0B10), size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.isRecruiter ? 'Team-Status' : 'Dein Status',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCircle(PulseStatusItem item) {
    return GestureDetector(
      onTap: () => _openStatusViewer(item),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: item.isSeen
                    ? null
                    : const LinearGradient(
                        colors: [
                          StoryJobTheme.cyanAccent,
                          StoryJobTheme.primaryViolet,
                          StoryJobTheme.pinkMagenta,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: item.isSeen
                    ? Border.all(color: StoryJobTheme.cardBorder, width: 1.5)
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: StoryJobTheme.backgroundBase, width: 2),
                ),
                child: Center(
                  child: Text(
                    item.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: item.accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: item.isSeen ? StoryJobTheme.textMuted : StoryJobTheme.textPrimary,
                fontSize: 11,
                fontWeight: item.isSeen ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VOLLBILD STATUS-VIEWER MIT FORTSCHRITTSBALKEN & DIREKT-REAKTION
// ============================================================================
class _PulseStatusViewerOverlay extends StatefulWidget {
  final PulseStatusItem item;
  final bool isOwn;
  final bool isRecruiterViewer;
  final VoidCallback onEditOwn;

  const _PulseStatusViewerOverlay({
    required this.item,
    required this.isOwn,
    required this.isRecruiterViewer,
    required this.onEditOwn,
  });

  @override
  State<_PulseStatusViewerOverlay> createState() => _PulseStatusViewerOverlayState();
}

class _PulseStatusViewerOverlayState extends State<_PulseStatusViewerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _replyWithImpulse(String quickReply) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDialogScreen(
          chatId: 'status_${widget.item.id}',
          targetName: widget.item.name,
          roleContext: 'Antwort auf Status: „$quickReply“',
          matchScore: widget.item.ecosystemBadge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quickReplies = widget.isRecruiterViewer
        ? [
            'Starker Impuls! Lust auf Kennenlernen? 👋',
            'Passt super zu unserer Team-DNA ✨',
          ]
        : [
            'Cooler Einblick ins Team! 👋',
            'Das passt genau zu meinen Werten ✨',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFF07090F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fortschrittsbalken oben
              AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressController.value,
                    minHeight: 3,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.item.accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header mit Absender & Schließen
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: widget.item.accentColor.withValues(alpha: 0.2),
                    child: Text(
                      widget.item.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: widget.item.accentColor,
                        fontWeight: FontWeight.w800,
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
                              widget.item.name,
                              style: const TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.item.timeAgo,
                              style: const TextStyle(
                                color: StoryJobTheme.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.item.roleOrTag,
                          style: const TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: StoryJobTheme.textPrimary),
                  ),
                ],
              ),

              const Spacer(),

              // Zentrale Status-Karte
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: widget.item.accentColor.withValues(alpha: 0.45),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.item.accentColor.withValues(alpha: 0.16),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.item.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.item.ecosystemBadge,
                        style: TextStyle(
                          color: widget.item.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '„${widget.item.message}“',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.38,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Interaktion unten
              if (widget.isOwn)
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: widget.onEditOwn,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Eigenen Status aktualisieren'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StoryJobTheme.textPrimary,
                      side: const BorderSide(color: StoryJobTheme.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Direkt auf diesen Impuls reagieren:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...quickReplies.map((reply) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () => _replyWithImpulse(reply),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StoryJobTheme.cardSurfaceElevated,
                              foregroundColor: StoryJobTheme.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: widget.item.accentColor.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            child: Text(
                              reply,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}