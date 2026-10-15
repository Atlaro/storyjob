// lib/features/community/screens/community_network_screen.dart
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';

class CommunityNetworkScreen extends StatelessWidget {
  const CommunityNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Resonanz-Kreise™',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.3),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.2),
              size: 260,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Gemeinsam mehr bewirken',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Resonanz-Kreise verbinden Menschen, Initiativen und Vereine über gelebte Werte und Engagement – nicht über Reichweite.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: StoryJobTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // KREIS 1: EHRENAMT & EINSATZKRÄFTE
                  _buildResonanceCircleCard(
                    title: '🚒 Ehrenamt & Einsatzkräfte',
                    subtitle: 'Feuerwehr, BRK, Rettungsdienst & Katastrophenschutz.',
                    tag: 'Werte: Krisenfestigkeit & Verantwortung',
                    accentColor: StoryJobTheme.neonPink,
                    memberCount: 'Regional aktiv',
                  ),
                  const SizedBox(height: 14),

                  // KREIS 2: INNOVATION & TECH
                  _buildResonanceCircleCard(
                    title: '🚀 Innovation & Zukunft',
                    subtitle: 'Macher, Developer & Pioniere mit Gestaltungsdrang.',
                    tag: 'Werte: Mut, Eigeninitiative & Neugier',
                    accentColor: StoryJobTheme.cyanAccent,
                    memberCount: 'Ecosystem',
                  ),
                  const SizedBox(height: 14),

                  // KREIS 3: NACHHALTIGKEIT & REGION
                  _buildResonanceCircleCard(
                    title: '🌱 Nachhaltigkeit & Region',
                    subtitle: 'Gemeinschaftsprojekte und ökologischer Weitblick vor Ort.',
                    tag: 'Werte: Weitsicht & Zusammenhalt',
                    accentColor: StoryJobTheme.emeraldGreen,
                    memberCount: 'Regional aktiv',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResonanceCircleCard({
    required String title,
    required String subtitle,
    required String tag,
    required Color accentColor,
    required String memberCount,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: StoryJobTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  memberCount,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: StoryJobTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}