// lib/core/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? highlightColor;
  final Gradient? borderGradient; // Neu: Für die leuchtenden Neon-Verläufe
  final bool hasNeonGlow;         // Neu: Schaltet den Cyber-Glow ein/aus

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 18,
    this.backgroundColor,
    this.borderColor,
    this.highlightColor,
    this.borderGradient,
    this.hasNeonGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = highlightColor != null
        ? highlightColor!.withValues(alpha: 0.40)
        : (borderColor ?? StoryJobTheme.cardBorder);

    // Innere Karten-Inhalte mit Blur und Klick-Feedback
    Widget innerCard = ClipRRect(
      borderRadius: BorderRadius.circular(
        borderGradient != null ? (borderRadius - 1.2).clamp(0.0, double.infinity) : borderRadius,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? StoryJobTheme.cardSurface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(
              borderGradient != null ? (borderRadius - 1.2).clamp(0.0, double.infinity) : borderRadius,
            ),
            border: borderGradient == null
                ? Border.all(
                    color: effectiveBorderColor,
                    width: 1.0,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              if (highlightColor != null)
                BoxShadow(
                  color: highlightColor!.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.04),
              onTap: onTap != null
                  ? () {
                      HapticFeedback.lightImpact();
                      onTap!();
                    }
                  : null,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    // Wenn ein borderGradient übergeben wurde, wickeln wir die Karte in einen leuchtenden 1.2px-Rahmen
    Widget finalCard = borderGradient != null
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: borderGradient,
              boxShadow: hasNeonGlow
                  ? StoryJobTheme.neonGlow(StoryJobTheme.primaryViolet, intensity: 0.25)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.2), // Subtiler Gradient-Rand
              child: innerCard,
            ),
          )
        : (hasNeonGlow
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: StoryJobTheme.neonGlow(
                    highlightColor ?? StoryJobTheme.primaryViolet,
                    intensity: 0.20,
                  ),
                ),
                child: innerCard,
              )
            : innerCard);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      child: finalCard,
    );
  }
}