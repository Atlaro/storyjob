// lib/features/settings/widgets/legal_licenses_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class LegalLicensesModal extends StatelessWidget {
  const LegalLicensesModal({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LegalLicensesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: const Border(
                top: BorderSide(color: StoryJobTheme.cardBorder, width: 1.1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 14, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rechtliches & Open Source',
                        style: TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: StoryJobTheme.textMuted, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: TabBar(
                      onTap: (_) => HapticFeedback.selectionClick(),
                      indicator: BoxDecoration(
                        color: StoryJobTheme.primaryViolet,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: StoryJobTheme.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Impressum'),
                        Tab(text: 'Lizenzen'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Impressum
                      ListView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: StoryJobTheme.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'StoryJob',
                                  style: TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Human Opportunity Network • Stand 2026',
                                  style: TextStyle(color: StoryJobTheme.cyanAccent, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'ANGABEN GEMÄSS § 5 TMG / DDG',
                                  style: TextStyle(
                                    color: StoryJobTheme.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'StoryJob Network\n'
                                  'Deutschland\n\n'
                                  'Kontakt:\n'
                                  'E-Mail: story.job@outlook.de\n'
                                  'Web: storyjob.de\n\n'
                                  'Verantwortlich für redaktionelle Inhalte:\n'
                                  'StoryJob Team',
                                  style: TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    height: 1.5,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Tab 2: Lizenzen
                      ListView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildLicenseItem('Flutter SDK', 'Google LLC', 'BSD-3-Clause'),
                          _buildLicenseItem('firebase_core', 'Firebase / Google', 'BSD-3-Clause'),
                          _buildLicenseItem('cloud_firestore', 'Firebase / Google', 'BSD-3-Clause'),
                          _buildLicenseItem('record', 'Lukas Klingsbo', 'MIT'),
                          _buildLicenseItem('audioplayers', 'Blue Fire', 'MIT'),
                          _buildLicenseItem('confetti', 'Funwithflutter', 'MIT'),
                          _buildLicenseItem('shared_preferences', 'Flutter Team', 'BSD-3-Clause'),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                showLicensePage(
                                  context: context,
                                  applicationName: 'StoryJob',
                                  applicationVersion: '1.0.0',
                                );
                              },
                              icon: const Icon(Icons.open_in_new_rounded, size: 15, color: StoryJobTheme.cyanAccent),
                              label: const Text(
                                'Vollständige Lizenztexte öffnen',
                                style: TextStyle(
                                  color: StoryJobTheme.cyanAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildLicenseItem(String name, String author, String license) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  author,
                  style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: Text(
              license,
              style: const TextStyle(
                color: StoryJobTheme.cyanAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}