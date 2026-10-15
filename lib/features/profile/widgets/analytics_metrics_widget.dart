// lib/features/profile/widgets/analytics_metrics_widget.dart
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class AnalyticsMetricsWidget extends StatelessWidget {
  final int totalViews;
  final int totalMatches;
  final int scheduledAppointments;
  final String responseTime;

  const AnalyticsMetricsWidget({
    super.key,
    required this.totalViews,
    required this.totalMatches,
    required this.scheduledAppointments,
    required this.responseTime,
  });

  @override
  Widget build(BuildContext context) {
    final double resonanceConversionRate = totalMatches > 0
        ? (scheduledAppointments / totalMatches) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: StoryJobTheme.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'RESONANZ & DIALOG-AKTIVITÄT',
                style: TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Dialog-Quote',
                  value: '${resonanceConversionRate.toStringAsFixed(0)}%',
                  subtitle: 'Resonanz zu Gespräch',
                  icon: Icons.forum_rounded,
                  color: StoryJobTheme.emeraldGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricItem(
                  title: 'Antwortzeit',
                  value: responseTime,
                  subtitle: 'Ø im Austausch',
                  icon: Icons.bolt_rounded,
                  color: StoryJobTheme.primaryViolet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StoryJobTheme.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Audio-Story Resonanzfaktor',
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Text(
                    'Hohe Wellenlänge ✨',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurface,
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
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}