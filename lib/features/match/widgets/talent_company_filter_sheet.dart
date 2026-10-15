// lib/features/match/widgets/talent_company_filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class TalentCompanyFilterSheet extends StatefulWidget {
  final Function(List<String> selectedBenefits) onApplyFilters;

  const TalentCompanyFilterSheet({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<TalentCompanyFilterSheet> createState() => _TalentCompanyFilterSheetState();
}

class _TalentCompanyFilterSheetState extends State<TalentCompanyFilterSheet> {
  final List<String> _availableBenefits = [
    'bKV (Gesundheitsvorsorge & Budget)',
    'bAV (Zukunft & Altersvorsorge)',
    'Sachbezug (Gutscheine/Card)',
    '30 Tage Urlaub',
    'Flexible Arbeitszeiten / Gleitzeit',
    'Vier-Tage-Woche / Freiraum',
    'Mobilitätsbudget / E-Bike',
    'Weiterbildung & Wissensbudget',
  ];

  final Set<String> _selectedBenefits = {
    'bKV (Gesundheitsvorsorge & Budget)',
    '30 Tage Urlaub',
  };

  void _toggleBenefit(String benefit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedBenefits.contains(benefit)) {
        _selectedBenefits.remove(benefit);
      } else {
        _selectedBenefits.add(benefit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag-Handle
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
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rahmenbedingungen & Werte',
                style: TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: StoryJobTheme.textSecondary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Finde Teams, die dir echte Wertschätzung und planbare Absicherung bieten.',
            style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableBenefits.map((benefit) {
              final isSelected = _selectedBenefits.contains(benefit);
              return FilterChip(
                label: Text(benefit),
                selected: isSelected,
                selectedColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.16),
                backgroundColor: StoryJobTheme.cardSurface,
                labelStyle: TextStyle(
                  color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.cardBorder,
                  ),
                ),
                onSelected: (_) => _toggleBenefit(benefit),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryJobTheme.primaryViolet,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onApplyFilters(_selectedBenefits.toList());
                Navigator.of(context).pop();
              },
              child: const Text(
                'Filter anwenden ✨',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}