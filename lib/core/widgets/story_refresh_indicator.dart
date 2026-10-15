// lib/core/widgets/story_refresh_indicator.dart
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class StoryRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const StoryRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: StoryJobTheme.cyanAccent,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      strokeWidth: 2.5,
      child: child,
    );
  }
}