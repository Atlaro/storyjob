// lib/features/recruiter/widgets/recruiter_upgrade_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class RecruiterUpgradeModal extends StatefulWidget {
  final VoidCallback? onUnlocked;

  const RecruiterUpgradeModal({
    super.key,
    this.onUnlocked,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onUnlocked}) {
    HapticFeedback.heavyImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RecruiterUpgradeModal(onUnlocked: onUnlocked),
    );
  }

  @override
  State<RecruiterUpgradeModal> createState() => _RecruiterUpgradeModalState();
}

class _RecruiterUpgradeModalState extends State<RecruiterUpgradeModal> {
  int _selectedTierIndex = 1; // Standard: Silber / Team-Abo

  final List<Map<String, dynamic>> _tiers = [
    {
      'title': 'Bronze • Sofort-Zugang',
      'price': '29 €',
      'sub': 'Einmalig für dieses Profil',
      'badge': '1 Resonanz',
      'color': const Color(0xFFD97706), // Warm Bronze
      'icon': Icons.military_tech_rounded,
      'benefits': [
        'Priorisierter Zugang für dieses 90%+ Werte-Match',
        'Audio-Story Vollzugriff & direkter Dialogstart',
      ],
    },
    {
      'title': 'Silber • Pro Partner',
      'price': '149 €',
      'sub': 'monatlich • jederzeit flexibel anpassbar',
      'badge': 'Beliebt',
      'color': const Color(0xFF94A3B8), // Slate Silver
      'icon': Icons.workspace_premium_rounded,
      'benefits': [
        'Alle 90%+ Resonanzen 24h priorisiert einsehen',
        'Unbegrenzt Story-Dialoge auf Augenhöhe starten',
        'Ausführliche Team-Story (bis zu 3 Min.) hinterlegen',
      ],
    },
    {
      'title': 'Gold • Enterprise Resonanz',
      'price': '349 €',
      'sub': 'monatlich • maximale Sichtbarkeit',
      'badge': 'Exklusiv',
      'color': StoryJobTheme.champagneGold,
      'icon': Icons.stars_rounded,
      'benefits': [
        'Alles aus Silber + erweiterter Kultur-Abgleich',
        'Priorisierte Ausspielung eurer Team-Stories',
        'Persönlicher StoryJob Sparringspartner',
      ],
    },
  ];

  void _handlePurchase() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    widget.onUnlocked?.call();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: StoryJobTheme.cyanAccent),
            const SizedBox(width: 10),
            Text(
              '${_tiers[_selectedTierIndex]['title']} erfolgreich aktiviert ✨',
              style: const TextStyle(fontWeight: FontWeight.w600, color: StoryJobTheme.textPrimary),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final selectedTier = _tiers[_selectedTierIndex];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: const Border(
              top: BorderSide(color: StoryJobTheme.cardBorder, width: 1.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
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

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.champagneGold.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.champagneGold, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priorisierten Zugang aktivieren',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Erlebe Top-Macher und Kultur-Matches ohne Verzögerung.',
                          style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Medaillen / Stufen Karten
              ...List.generate(_tiers.length, (index) {
                final tier = _tiers[index];
                final isSelected = _selectedTierIndex == index;
                final Color medalColor = tier['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTierIndex = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? medalColor.withValues(alpha: 0.12)
                          : StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? medalColor : StoryJobTheme.cardBorder,
                        width: isSelected ? 1.6 : 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medaille Symbol
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: medalColor.withValues(alpha: 0.18),
                            border: Border.all(color: medalColor.withValues(alpha: 0.5), width: 1.2),
                          ),
                          child: Icon(tier['icon'] as IconData, color: medalColor, size: 22),
                        ),
                        const SizedBox(width: 14),

                        // Titel & Vorteile
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tier['title'] as String,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : StoryJobTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    tier['price'] as String,
                                    style: TextStyle(
                                      color: isSelected ? medalColor : StoryJobTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tier['sub'] as String,
                                style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              ...(tier['benefits'] as List<String>).map((b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check_rounded, color: medalColor, size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            b,
                                            style: const TextStyle(
                                              color: StoryJobTheme.textSecondary,
                                              fontSize: 11.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // Pill Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _handlePurchase,
                  child: Text(
                    'Für ${selectedTier['price']} aktivieren ✨',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
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