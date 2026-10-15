// lib/features/recruiter/screens/recruiter_dashboard_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/recruiter/screens/company_dna_screen.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  final String recruiterId;

  const RecruiterDashboardScreen({
    super.key,
    this.recruiterId = 'recruiter_demo',
  });

  @override
  State<RecruiterDashboardScreen> createState() => _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  String _selectedFilter = 'Alle';
  final List<String> _filters = ['Alle', 'Hohe Wellenlänge ✨', 'Engagement & Ehrenamt', 'Technik & Impact'];

  String get _effectiveCompanyId {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return (currentUid != null && currentUid.isNotEmpty) ? currentUid : widget.recruiterId;
  }

  void _openCompanyIdentity() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CompanyDnaScreen(),
      ),
    );
  }

  void _manageTeamStory(String? currentVideoUrl) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: StoryJobTheme.cyanAccent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '60s Team- & Kultur-Impuls',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Zeigt Talenten und Machern eure gelebten Werte vorab.',
                            style: TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.video_call_rounded, color: StoryJobTheme.cyanAccent),
                  title: const Text(
                    'Impuls aufnehmen (max. 60 Sek.)',
                    style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kamera nutzen für einen ungestellten, echten Einblick.',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: StoryJobTheme.cardSurface,
                  onTap: () {
                    Navigator.pop(context);
                    _openCompanyIdentity();
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: StoryJobTheme.primaryViolet),
                  title: const Text(
                    'Bestehendes Video (MP4) hochladen',
                    style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Fertig bearbeitetes Team- oder Kultur-Video einbinden.',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: StoryJobTheme.cardSurface,
                  onTap: () {
                    Navigator.pop(context);
                    _openCompanyIdentity();
                  },
                ),
                if (currentVideoUrl != null && currentVideoUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.play_circle_fill_rounded, color: StoryJobTheme.cyanAccent),
                    title: const Text(
                      'Aktuellen Impuls ansehen',
                      style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(_effectiveCompanyId)
            .snapshots(),
        builder: (context, companySnapshot) {
          final companyData = companySnapshot.data?.data() as Map<String, dynamic>?;
          final companyName = companyData?['name'] as String? ?? 'Team-Profil konfigurieren';
          final websiteUrl = companyData?['website'] as String? ?? 'Website & Werte verbinden';
          final logoUrl = companyData?['logoUrl'] as String?;
          final videoStoryUrl = companyData?['videoStoryUrl'] ?? companyData?['videoPitchUrl'] as String?;
          final bool hasVideo = videoStoryUrl != null && videoStoryUrl.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 110.0),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. App-Header mit leuchtendem Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: StoryJobTheme.cardBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/branding/app_icon_dark.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.corporate_fare_rounded,
                            color: StoryJobTheme.cyanAccent,
                            size: 20,
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Unternehmens-DNA',
                        icon: const Icon(Icons.tune_rounded, color: StoryJobTheme.cyanAccent),
                        onPressed: _openCompanyIdentity,
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: StoryJobTheme.textSecondary),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Begrüßung & Status
              const Text(
                'Willkommen auf Augenhöhe',
                style: TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: StoryJobTheme.cyanAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Aktive Werte-Resonanzen mit passenden Machern.',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Unternehmens-Identitäts-Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _openCompanyIdentity,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                          border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: ClipOval(
                          child: logoUrl != null && logoUrl.isNotEmpty
                              ? Image.network(
                                  logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.business_rounded,
                                    color: StoryJobTheme.cyanAccent,
                                    size: 24,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: StoryJobTheme.cyanAccent,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.link_rounded, size: 14, color: StoryJobTheme.cyanAccent),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  websiteUrl,
                                  style: const TextStyle(
                                    color: StoryJobTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: StoryJobTheme.cyanAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _openCompanyIdentity,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Anpassen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Team-Story / Kultur-Impuls Banner
              GestureDetector(
                onTap: () => _manageTeamStory(videoStoryUrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        StoryJobTheme.primaryViolet.withValues(alpha: 0.30),
                        StoryJobTheme.cardSurfaceElevated,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: hasVideo
                          ? StoryJobTheme.cyanAccent.withValues(alpha: 0.5)
                          : StoryJobTheme.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasVideo ? Icons.play_arrow_rounded : Icons.videocam_rounded,
                          color: StoryJobTheme.cyanAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  hasVideo ? 'Team-Impuls aktiv' : 'Kein Team-Impuls hinterlegt',
                                  style: const TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'max. 60 Sek.',
                                    style: TextStyle(color: StoryJobTheme.cyanAccent, fontSize: 10.5, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasVideo
                                  ? 'Macher & Talente erleben eure Kultur vor der ersten Nachricht.'
                                  : 'Stelle euer Team und eure Mission in 60 Sekunden vor.',
                              style: const TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: StoryJobTheme.textMuted, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. KPI-Übersicht im Slate-Dark-Format
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Macher-Stories',
                      value: '24',
                      icon: Icons.mic_rounded,
                      color: StoryJobTheme.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Werte-Resonanz',
                      value: '8',
                      icon: Icons.auto_awesome_rounded,
                      color: StoryJobTheme.primaryViolet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Im Dialog',
                      value: '3',
                      icon: Icons.forum_rounded,
                      color: StoryJobTheme.champagneGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Filter Chips
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                        backgroundColor: StoryJobTheme.cardSurfaceElevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? StoryJobTheme.cyanAccent.withValues(alpha: 0.4) : StoryJobTheme.cardBorder,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? StoryJobTheme.cyanAccent : StoryJobTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 6. Resonanz-Pool (Kandidaten)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'talent')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Noch keine Profile im Resonanz-Pool.',
                          style: TextStyle(color: StoryJobTheme.textSecondary),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final candidateName = data['displayName'] ?? data['name'] ?? 'Macher';
                      final roleTitle = data['bio'] ?? data['tagline'] ?? 'Offen für Werte-Matches';
                      final matchScore = data['matchScore'] ?? '96% Resonanz';
                      final chatId = 'chat_${docs[index].id}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cardSurfaceElevated,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: StoryJobTheme.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: StoryJobTheme.cardSurface,
                                      child: Icon(Icons.person_rounded, color: StoryJobTheme.cyanAccent),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          candidateName,
                                          style: const TextStyle(
                                            color: StoryJobTheme.textPrimary,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          roleTitle,
                                          style: const TextStyle(
                                            color: StoryJobTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
                                  ),
                                  child: Text(
                                    matchScore,
                                    style: const TextStyle(
                                      color: StoryJobTheme.cyanAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const Icon(Icons.graphic_eq_rounded, color: StoryJobTheme.primaryViolet, size: 16),
                                const SizedBox(width: 6),
                                const Text(
                                  'StoryJob DNA™ aktiv',
                                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: StoryJobTheme.cyanAccent,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => StoryDialogScreen(
                                          chatId: chatId,
                                          targetName: candidateName,
                                          roleContext: roleTitle,
                                          matchScore: matchScore,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.forum_rounded, size: 16),
                                  label: const Text('Dialog auf Augenhöhe', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}