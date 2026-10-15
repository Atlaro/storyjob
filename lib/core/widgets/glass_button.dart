// lib/core/widgets/glass_button.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimaryGlow;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimaryGlow = false,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 52,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: isPrimaryGlow ? StoryJobTheme.brandGradient : null,
            color: isPrimaryGlow
                ? null
                : (backgroundColor ?? StoryJobTheme.cardSurfaceElevated),
            border: Border.all(
              color: isPrimaryGlow
                  ? Colors.white.withValues(alpha: 0.25)
                  : StoryJobTheme.cardBorder,
              width: 1.0,
            ),
            boxShadow: isPrimaryGlow
                ? [
                    BoxShadow(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: textColor ?? StoryJobTheme.textPrimary,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            onPressed: isLoading
                ? null
                : () {
                    if (isPrimaryGlow) {
                      HapticFeedback.mediumImpact();
                    } else {
                      HapticFeedback.lightImpact();
                    }
                    onPressed();
                  },
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor ?? StoryJobTheme.textPrimary, size: 19),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: textColor ?? StoryJobTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}