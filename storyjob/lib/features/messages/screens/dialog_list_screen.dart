// lib/features/messages/screens/dialog_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';
import 'package:storyjob/features/profile/widgets/security_trust_widget.dart';

class DialogListScreen extends StatefulWidget {
  final int initialTabIndex;
  final bool isTeamView;

  const DialogListScreen({
    super.key,
    this.initialTabIndex = 0,
    this.isTeamView = false,
  });

  @override
  State<DialogListScreen> createState() => _DialogListScreenState();
}

class _DialogListScreenState extends State<DialogListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _buildDialogId(String? currentUserId, String fallbackPartnerKey) {
    final cleanPartner =
        fallbackPartnerKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    if (currentUserId == null || currentUserId.isEmpty) {
      return 'dialog_$cleanPartner';
    }
    final pair = [currentUserId, cleanPartner]..sort();
    return 'dialog_${pair.first}_${pair.last}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: StoryJobTheme.textPrimary,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            const Text(
              'StoryJob Dialoge',
              style: TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (widget.isTeamView
                        ? StoryJobTheme.primaryViolet
                        : StoryJobTheme.cyanAccent)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (widget.isTeamView
                          ? StoryJobTheme.primaryViolet
                          : StoryJobTheme.cyanAccent)
                      .withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                widget.isTeamView ? 'TEAMS' : 'DNA',
                style: TextStyle(
                  color: widget.isTeamView
                      ? StoryJobTheme.primaryViolet
                      : StoryJobTheme.cyanAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Datensicherheit',
            icon: const Icon(
              Icons.shield_outlined,
              color: StoryJobTheme.textSecondary,
              size: 20,
            ),
            onPressed: () => SecurityTrustWidget.show(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => HapticFeedback.selectionClick(),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.45),
                  ),
                ),
                labelColor: StoryJobTheme.textPrimary,
                unselectedLabelColor: StoryJobTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Nachrichten'),
                  Tab(text: 'Benachrichtigungen'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _MessagesTab(
              currentUserId: currentUserId,
              isTeamView: widget.isTeamView,
              buildDialogId: _buildDialogId,
            ),
            _NotificationsTab(
              currentUserId: currentUserId,
              isTeamView: widget.isTeamView,
              buildDialogId: _buildDialogId,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  final String? currentUserId;
  final bool isTeamView;
  final String Function(String? currentUserId, String fallbackPartnerKey)
      buildDialogId;

  const _MessagesTab({
    required this.currentUserId,
    required this.isTeamView,
    required this.buildDialogId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Text(
            isTeamView
                ? 'Gespräche mit Talenten & DNA-Profilen auf Augenhöhe.'
                : 'Gespräche mit Teams & Unternehmen auf deiner Wellenlänge.',
            style: const TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: currentUserId != null
                ? FirebaseFirestore.instance
                    .collection('dialogs')
                    .where('participants', arrayContains: currentUserId)
                    .orderBy('lastMessageTimestamp', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('dialogs')
                    .limit(20)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildLegacyStream(context);
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return _buildLegacyStream(context);
              }
              return _buildDialogListView(context, docs);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyStream(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('story_dialogs').snapshots(),
      builder: (context, legacySnap) {
        if (legacySnap.connectionState == ConnectionState.waiting &&
            !legacySnap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
          );
        }
        final legacyDocs = legacySnap.data?.docs ?? [];
        if (legacyDocs.isEmpty) {
          return const _EmptyInfoState(
            icon: Icons.forum_outlined,
            title: 'Noch keine aktiven Dialoge',
            subtitle:
                'Sobald zwischen DNA und Team echte Resonanz entsteht, startet euer Dialog direkt hier.',
          );
        }
        return _buildDialogListView(context, legacyDocs);
      },
    );
  }

  Widget _buildDialogListView(
    BuildContext context,
    List<QueryDocumentSnapshot> docs,
  ) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>? ?? {};

        final partnerName = data['partnerName'] as String? ??
            data['targetName'] as String? ??
            'StoryJob Kontakt';
        final roleTitle = data['roleTitle'] as String? ??
            data['roleContext'] as String? ??
            'Austausch auf Augenhöhe';
        final matchScore = data['matchScore'] as String? ??
            data['resonanceLevel'] as String? ??
            'Hohe Werte-Passung ✨';
        final lastMessage =
            data['lastMessage'] as String? ?? 'Neuer StoryDialog gestartet';
        final timeStr = data['time'] as String? ?? 'Heute';

        return Container(
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StoryJobTheme.cardBorder),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StoryJobTheme.cardSurface,
                border: Border.all(
                  color: StoryJobTheme.primaryViolet.withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    partnerName,
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: StoryJobTheme.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        roleTitle,
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        matchScore,
                        style: const TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  lastMessage,
                  style: const TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: StoryJobTheme.textMuted,
              size: 12,
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryDialogScreen(
                    chatId: doc.id,
                    targetName: partnerName,
                    roleContext: roleTitle,
                    matchScore: matchScore,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  final String? currentUserId;
  final bool isTeamView;
  final String Function(String? currentUserId, String fallbackPartnerKey)
      buildDialogId;

  const _NotificationsTab({
    required this.currentUserId,
    required this.isTeamView,
    required this.buildDialogId,
  });

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const _EmptyInfoState(
        icon: Icons.notifications_none_rounded,
        title: 'Noch keine Benachrichtigungen',
        subtitle:
            'Favorisierungen, Story-Resonanzen und neue Begegnungen zwischen DNA und Team erscheinen hier.',
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _EmptyInfoState(
            icon: Icons.notifications_none_rounded,
            title: 'Aktivitäten werden vorbereitet',
            subtitle:
                'Sobald Teams oder Talente deine Stories favorisieren oder Resonanz zeigen, siehst du es hier.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyInfoState(
            icon: Icons.favorite_border_rounded,
            title: isTeamView
                ? 'Noch keine Talent-Signale'
                : 'Noch keine Team-Signale',
            subtitle: isTeamView
                ? 'Wenn Talente eure Team-Story favorisieren oder anhören, könnt ihr hier direkt den Dialog starten.'
                : 'Wenn Teams deine StoryDNA favorisieren oder anhören, kannst du hier direkt eine Nachricht senden.',
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>? ?? {};

            final actorName =
                data['actorName'] as String? ?? 'StoryJob Partner';
            final storyTitle =
                data['storyTitle'] as String? ?? data['roleContext'] as String? ?? 'Story';
            final actionType = data['type'] as String? ?? 'favorite';
            final matchScore = data['matchScore'] as String? ?? 'Resonanz ✨';
            final isUnread = data['read'] != true;

            final actionText = actionType == 'favorite'
                ? 'hat deine Story „$storyTitle“ favorisiert.'
                : actionType == 'listen'
                    ? 'hat deine Story „$storyTitle“ angehört.'
                    : 'zeigt Interesse an „$storyTitle“.';

            final ctaLabel =
                isTeamView ? 'Dialog starten' : 'Nachricht senden';

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnread
                      ? StoryJobTheme.cyanAccent.withValues(alpha: 0.40)
                      : StoryJobTheme.cardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          actionType == 'favorite'
                              ? Icons.bookmark_rounded
                              : Icons.graphic_eq_rounded,
                          color: StoryJobTheme.cyanAccent,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: StoryJobTheme.textSecondary,
                              height: 1.35,
                            ),
                            children: [
                              TextSpan(
                                text: actorName,
                                style: const TextStyle(
                                  color: StoryJobTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(text: actionText),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          matchScore,
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        if (isUnread) {
                          await doc.reference.update({'read': true});
                        }
                        if (!context.mounted) return;
                        final targetChatId =
                            (data['chatId'] as String?)?.isNotEmpty == true
                                ? data['chatId'] as String
                                : buildDialogId(currentUserId, actorName);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoryDialogScreen(
                              chatId: targetChatId,
                              targetName: actorName,
                              roleContext: storyTitle,
                              matchScore: matchScore,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.forum_rounded, size: 14),
                      label: Text(
                        ctaLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyInfoState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyInfoState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Icon(
                icon,
                size: 36,
                color: StoryJobTheme.cyanAccent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}