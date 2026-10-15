// lib/features/navigation/widgets/story_app_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/messages/screens/dialog_list_screen.dart';

class StoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showChatAction;

  const StoryAppBar({
    super.key,
    this.actions,
    this.showChatAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: StoryJobTheme.backgroundBase.withValues(alpha: 0.75),
            border: Border(
              bottom: BorderSide(
                color: StoryJobTheme.cardBorder.withValues(alpha: 0.6),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 18,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo-Container mit zartem Cyan-Glow
                Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.45),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.20),
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/branding/app_icon_dark.png',
                      height: 28,
                      width: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome_rounded,
                        color: StoryJobTheme.cyanAccent,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'StoryJob',
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            actions: actions ??
                (showChatAction
                    ? [
                        StreamBuilder<QuerySnapshot>(
                          stream: currentUserId != null
                              ? FirebaseFirestore.instance
                                  .collection('dialogs')
                                  .where('participants', arrayContains: currentUserId)
                                  .where('hasUnread', isEqualTo: true)
                                  .snapshots()
                              : const Stream.empty(),
                          builder: (context, snapshot) {
                            final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: StoryJobTheme.cardSurfaceElevated,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: hasUnread
                                            ? StoryJobTheme.cyanAccent.withValues(alpha: 0.6)
                                            : StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                                        width: 1.1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (hasUnread
                                                  ? StoryJobTheme.cyanAccent
                                                  : StoryJobTheme.primaryViolet)
                                              .withValues(alpha: 0.22),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.forum_rounded,
                                      color: StoryJobTheme.cyanAccent,
                                      size: 18,
                                    ),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const DialogListScreen(),
                                      ),
                                    );
                                  },
                                  tooltip: 'Meine StoryDialoge',
                                ),
                                if (hasUnread)
                                  Positioned(
                                    top: 10,
                                    right: 12,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: StoryJobTheme.cyanAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: StoryJobTheme.backgroundBase,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.8),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ]
                    : null),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}