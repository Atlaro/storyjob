// lib/features/teams/screens/company_public_profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/story_symbiosis_service.dart';
import 'package:storyjob/core/services/story_symbiosis_telemetry.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';

class CompanyPublicProfileScreen extends StatefulWidget {
  final String companyId;
  final String teamId;
  final String talentUid;

  const CompanyPublicProfileScreen({
    super.key,
    required this.companyId,
    required this.teamId,
    required this.talentUid,
  });

  @override
  State<CompanyPublicProfileScreen> createState() =>
      _CompanyPublicProfileScreenState();
}

class _CompanyPublicProfileScreenState
    extends State<CompanyPublicProfileScreen> {
  bool _isSending = false;
  bool _hasRequested = false;

  Future _loadTeamProfileData() async {
    final publicDoc = await FirebaseFirestore.instance
        .collection('company_public')
        .doc(widget.companyId)
        .get();

    if (publicDoc.exists && publicDoc.data() != null) {
      return publicDoc.data();
    }

    final fallbackDoc = await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .get();

    if (fallbackDoc.exists && fallbackDoc.data() != null) {
      return fallbackDoc.data();
    }

    return null;
  }

  Future _sendAccessRequest(
    BuildContext context,
    Map profileData,
  ) async {
    if (_isSending || _hasRequested) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSending = true);

    final teamName =
        (profileData['name'] as String?)?.trim().isNotEmpty == true
            ? (profileData['name'] as String).trim()
            : 'StoryJob Team';
    final industry =
        (profileData['industry'] as String?)?.trim().isNotEmpty == true
            ? (profileData['industry'] as String).trim()
            : 'Team & Kultur';
    final welcomesCareerChangers =
        profileData['welcomesCareerChangers'] as bool? ?? true;
    final rawValues = profileData['cultureValues'] ?? profileData['values'];
    final sharedValues = rawValues is List
        ? rawValues.map((e) => e.toString()).toList()
        : <String>[];

    try {
      final requestDocId =
          '${widget.talentUid}_${widget.companyId}_${widget.teamId}';
      await FirebaseFirestore.instance
          .collection('access_requests')
          .doc(requestDocId)
          .set({
        'talentUid': widget.talentUid,
        'companyId': widget.companyId,
        'teamId': widget.teamId,
        'teamName': teamName,
        'status': 'pending',
        'isCareerChangerBridge': welcomesCareerChangers,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await StorySymbiosisService.sendStoryImpulse(
        recipientId: widget.companyId,
        targetName: teamName,
        storyTitle: industry,
        matchScore: 'Werte-Impuls ✨',
        type: 'dialog_request',
      );

      await StorySymbiosisTelemetry.recordEcosystemEvent(
        eventName: 'company_profile_access_requested',
        roleContext: 'talent',
        targetId: widget.companyId,
        category: industry,
        sharedValues: sharedValues,
        isCareerChangerBridge: welcomesCareerChangers,
      );

      if (!context.mounted) return;
      setState(() => _hasRequested = true);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impuls an $teamName gesendet – das Team wurde benachrichtigt ✨',
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impuls konnte gerade nicht gesendet werden: $e',
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
          ),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future _openDirectDialog(
    BuildContext context,
    Map profileData,
  ) async {
    HapticFeedback.mediumImpact();
    final teamName =
        (profileData['name'] as String?)?.trim().isNotEmpty == true
            ? (profileData['name'] as String).trim()
            : 'StoryJob Team';
    final roleContext =
        (profileData['industry'] as String?)?.trim().isNotEmpty == true
            ? (profileData['industry'] as String).trim()
            : 'Team & Kultur';
    final welcomesCareerChangers =
        profileData['welcomesCareerChangers'] as bool? ?? true;

    await StorySymbiosisTelemetry.recordEcosystemEvent(
      eventName: 'company_profile_dialog_opened',
      roleContext: 'talent',
      targetId: widget.companyId,
      category: roleContext,
      isCareerChangerBridge: welcomesCareerChangers,
    );

    if (!context.mounted) return;
    await StorySymbiosisService.openOrCreateDialog(
      context,
      recipientId: widget.companyId,
      targetName: teamName,
      roleContext: roleContext,
      matchScore: 'Dialog auf Augenhöhe ✨',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        title: const Text(
          'StoryJob™ Teams Schaufenster',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: FutureBuilder(
        future: _loadTeamProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: StoryJobTheme.cyanAccent,
                strokeWidth: 2,
              ),
            );
          }

          final raw = snapshot.data;
          if (snapshot.hasError || raw is! Map) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Team-Schaufenster konnte aktuell nicht geladen werden.',
                  style: TextStyle(color: StoryJobTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final name = (raw['name'] as String?)?.trim().isNotEmpty == true
              ? (raw['name'] as String).trim()
              : 'StoryJob Team';
          final tagline = (raw['tagline'] as String?)?.trim().isNotEmpty == true
              ? (raw['tagline'] as String).trim()
              : ((raw['missionQuote'] as String?)?.trim() ?? '');
          final teamSpirit =
              (raw['teamSpiritQuote'] as String?)?.trim().isNotEmpty == true
                  ? (raw['teamSpiritQuote'] as String).trim()
                  : ((raw['purposeVision'] as String?)?.trim() ?? '');
          final location = (raw['location'] as String?)?.trim() ?? '';
          final industry = (raw['industry'] as String?)?.trim() ?? '';
          final welcomesCareerChangers =
              raw['welcomesCareerChangers'] as bool? ?? true;
          final bridgeText =
              (raw['careerChangerBridgeText'] as String?)?.trim().isNotEmpty ==
                      true
                  ? (raw['careerChangerBridgeText'] as String).trim()
                  : 'Offen für Quereinsteiger & Menschen im Wandel – Haltung, Lernbereitschaft und echte Praxis zählen vor starren Lebensläufen.';

          final rawValues = raw['cultureValues'] ?? raw['values'];
          final cultureValues = rawValues is List
              ? rawValues.map((e) => e.toString()).toList()
              : <String>[];

          final rawBenefits = raw['benefits'];
          final benefits = rawBenefits is List
              ? rawBenefits.map((e) => e.toString()).toList()
              : <String>[];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  borderRadius: 24,
                  borderGradient: StoryJobTheme.dnaCardBorder,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StoryJobTheme.primaryViolet
                              .withValues(alpha: 0.18),
                          border: Border.all(
                            color: StoryJobTheme.primaryViolet
                                .withValues(alpha: 0.65),
                            width: 1.6,
                          ),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          size: 34,
                          color: StoryJobTheme.primaryViolet,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (industry.isNotEmpty || location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          [industry, location]
                              .where((e) => e.isNotEmpty)
                              .join(' • '),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: StoryJobTheme.cyanAccent,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (tagline.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          '„$tagline“',
                          style: const TextStyle(
                            fontSize: 14,
                            color: StoryJobTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (welcomesCareerChangers) ...[
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StoryJobTheme.emeraldGreen
                                .withValues(alpha: 0.16),
                          ),
                          child: const Icon(
                            Icons.handshake_rounded,
                            color: StoryJobTheme.emeraldGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Niedrigschwellige Quereinsteiger-Brücke',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: StoryJobTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bridgeText,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: StoryJobTheme.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (teamSpirit.isNotEmpty || cultureValues.isNotEmpty) ...[
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Team-Spirit & Kultur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.cyanAccent,
                          ),
                        ),
                        if (teamSpirit.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            teamSpirit,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: StoryJobTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (cultureValues.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: cultureValues.map((value) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: StoryJobTheme.primaryViolet
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: StoryJobTheme.primaryViolet
                                        .withValues(alpha: 0.40),
                                  ),
                                ),
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (benefits.isNotEmpty) ...[
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Benefits & Rahmenbedingungen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.champagneGold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: benefits.map((b) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: StoryJobTheme.champagneGold
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: StoryJobTheme.champagneGold
                                      .withValues(alpha: 0.38),
                                ),
                              ),
                              child: Text(
                                b,
                                style: const TextStyle(
                                  color: StoryJobTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openDirectDialog(context, raw),
                    icon: const Icon(Icons.forum_rounded, size: 18),
                    label: const Text(
                      'Dialog auf Augenhöhe starten ✨',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryJobTheme.primaryViolet,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: (_isSending || _hasRequested)
                        ? null
                        : () => _sendAccessRequest(context, raw),
                    icon: _isSending
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: StoryJobTheme.cyanAccent,
                            ),
                          )
                        : Icon(
                            _hasRequested
                                ? Icons.check_circle_rounded
                                : Icons.bolt_rounded,
                            size: 18,
                          ),
                    label: Text(
                      _isSending
                          ? 'Impuls wird gesendet...'
                          : (_hasRequested
                              ? 'Interesse & Impuls gesendet ✓'
                              : 'Interesse & Impuls senden'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _hasRequested
                          ? StoryJobTheme.emeraldGreen
                          : StoryJobTheme.cyanAccent,
                      side: BorderSide(
                        color: (_hasRequested
                                ? StoryJobTheme.emeraldGreen
                                : StoryJobTheme.cyanAccent)
                            .withValues(alpha: 0.45),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}