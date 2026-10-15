// lib/features/identity/screens/communities_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class CommunitiesScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity currentIdentity;

  const CommunitiesScreen({
    super.key,
    required this.userId,
    required this.currentIdentity,
  });

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  final TextEditingController _customCommunityController = TextEditingController();

  late List<String> _selectedCommunities;

  final List<Map<String, dynamic>> _suggestedCommunities = [
    {
      'title': 'Feuerwehr, THW & Rettungsdienst',
      'icon': Icons.emergency_rounded,
      'color': Color(0xFFEF4444),
    },
    {
      'title': 'Sport- & Heimatvereine',
      'icon': Icons.sports_soccer_rounded,
      'color': StoryJobTheme.champagneGold,
    },
    {
      'title': 'Soziales Engagement & Nachbarschaft',
      'icon': Icons.volunteer_activism_rounded,
      'color': StoryJobTheme.primaryViolet,
    },
    {
      'title': 'Handwerk, Macher & Gewerbe',
      'icon': Icons.handyman_rounded,
      'color': Color(0xFFF59E0B),
    },
    {
      'title': 'Klima, Natur & Nachhaltigkeit',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Kreativ, Kultur & Musik',
      'icon': Icons.palette_rounded,
      'color': StoryJobTheme.cyanAccent,
    },
    {
      'title': 'Tech, Innovation & Digitales',
      'icon': Icons.devices_rounded,
      'color': Color(0xFF6366F1),
    },
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCommunities = List.from(widget.currentIdentity.communities);
  }

  @override
  void dispose() {
    _customCommunityController.dispose();
    super.dispose();
  }

  void _toggleCommunity(String community) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCommunities.contains(community)) {
        _selectedCommunities.remove(community);
      } else {
        _selectedCommunities.add(community);
      }
    });
  }

  void _addCustomCommunity() {
    final text = _customCommunityController.text.trim();
    if (text.isNotEmpty && !_selectedCommunities.contains(text)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedCommunities.add(text);
        _customCommunityController.clear();
      });
    }
  }

  Future<void> _saveAndReturn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedIdentity = widget.currentIdentity.copyWith(
        communities: _selectedCommunities,
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gemeinschaften & Engagement gespeichert ✨',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF1E222B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: StoryJobTheme.textPrimary),
        title: const Text(
          'Gemeinschaften & Vereine',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Wo schlägt dein Herz?',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gemeinsames Engagement schafft echte Resonanz. Wähle Vereine, Initiativen oder Netzwerke, in denen du aktiv bist.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // FREITEXT: EIGENEN VEREIN / INITIATIVE HINZUFÜGEN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        color: StoryJobTheme.cyanAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _customCommunityController,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Eigenen Verein oder Projekt eintragen...',
                          hintStyle: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomCommunity(),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCustomCommunity,
                      child: const Text(
                        'Hinzufügen',
                        style: TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // VORSCHLAGSLISTE & AKTIVE GEMEINSCHAFTEN
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Individuell hinzugefügte Tags (falls vorhanden)
                    if (_selectedCommunities.any((c) => !_suggestedCommunities.any((s) => s['title'] == c))) ...[
                      const Text(
                        'Deine eigenen Initiativen:',
                        style: TextStyle(
                          fontSize: 12,
                          color: StoryJobTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedCommunities
                            .where((c) => !_suggestedCommunities.any((s) => s['title'] == c))
                            .map((custom) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  custom,
                                  style: const TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _toggleCommunity(custom),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: StoryJobTheme.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ..._suggestedCommunities.map((item) {
                      final title = item['title'] as String;
                      final icon = item['icon'] as IconData;
                      final color = item['color'] as Color;
                      final isSelected = _selectedCommunities.contains(title);

                      return GestureDetector(
                        onTap: () => _toggleCommunity(title),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.14)
                                : StoryJobTheme.cardSurfaceElevated,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? color.withValues(alpha: 0.6)
                                  : StoryJobTheme.cardBorder,
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(alpha: 0.18),
                                ),
                                child: Icon(icon, color: color, size: 19),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : StoryJobTheme.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? color : StoryJobTheme.textMuted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // PILL BUTTON SPEICHERN
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Gemeinschaften sichern ✨',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}