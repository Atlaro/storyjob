// lib/features/profile/widgets/story_profile_header.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

enum AuraPreset {
  cyanFocus,
  champagneExcellence,
  emeraldCraft,
  violetValues,
}

class StoryProfileHeader extends StatelessWidget {
  final String? bannerImageUrl;
  final String? avatarImageUrl;
  final String initials;
  final AuraPreset aura;
  final Color tierColor;
  final bool isEditable;
  final VoidCallback? onEditBanner;
  final VoidCallback? onEditAvatar;
  final double bannerHeight;

  const StoryProfileHeader({
    super.key,
    this.bannerImageUrl,
    this.avatarImageUrl,
    this.initials = 'SJ',
    this.aura = AuraPreset.cyanFocus,
    this.tierColor = StoryJobTheme.cyanAccent,
    this.isEditable = false,
    this.onEditBanner,
    this.onEditAvatar,
    this.bannerHeight = 220.0,
  });

  Color get _auraColor {
    switch (aura) {
      case AuraPreset.cyanFocus:
        return StoryJobTheme.cyanAccent;
      case AuraPreset.champagneExcellence:
        return StoryJobTheme.champagneGold;
      case AuraPreset.emeraldCraft:
        return StoryJobTheme.emeraldGreen;
      case AuraPreset.violetValues:
        return StoryJobTheme.primaryViolet;
    }
  }

  LinearGradient get _defaultAuraGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _auraColor.withValues(alpha: 0.40),
        StoryJobTheme.cardSurfaceElevated,
        StoryJobTheme.backgroundBase,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 48.0;
    const double overlap = 40.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomLeft,
      children: [
        // 1. TITELBILD / BANNER MIT MULTI-STOP SCRIM
        Container(
          width: double.infinity,
          height: bannerHeight,
          margin: const EdgeInsets.only(bottom: overlap),
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated,
            gradient: bannerImageUrl == null ? _defaultAuraGradient : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Echtes Bild (falls hinterlegt)
              if (bannerImageUrl != null && bannerImageUrl!.isNotEmpty)
                Image.network(
                  bannerImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(gradient: _defaultAuraGradient),
                  ),
                ),

              // Vertikaler Scrim (Abdunklung oben & Übergang nach unten)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.40), // Oben für Status-Icons
                        Colors.transparent,                   // Mitte klar
                        StoryJobTheme.backgroundBase.withValues(alpha: 0.75),
                        StoryJobTheme.backgroundBase,         // Unten 100% Slate Dark
                      ],
                      stops: const [0.0, 0.35, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // Werte-Aura Schimmer (Subtiler Farbraum am unteren Rand)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 75,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _auraColor.withValues(alpha: 0.0),
                        _auraColor.withValues(alpha: 0.16),
                      ],
                    ),
                  ),
                ),
              ),

              // Banner-Bearbeiten-Button (Glass-Pill)
              if (isEditable)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: StoryJobTheme.cardBorder,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onEditBanner?.call();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined, color: Colors.white, size: 15),
                                  SizedBox(width: 6),
                                  Text(
                                    'Titelbild',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 2. PROFILBILD MIT RESONANZ-RING (OVERLAP)
        Positioned(
          left: 20,
          bottom: 0,
          child: Stack(
            children: [
              // Äußerer Glow-Ring
              Container(
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StoryJobTheme.backgroundBase,
                  boxShadow: [
                    BoxShadow(
                      color: tierColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: tierColor,
                      width: 2.2,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarImageUrl != null && avatarImageUrl!.isNotEmpty
                        ? Image.network(
                            avatarImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitials(),
                          )
                        : _buildInitials(),
                  ),
                ),
              ),

              // Avatar-Bearbeiten-Icon
              if (isEditable)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onEditAvatar?.call();
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: StoryJobTheme.cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: StoryJobTheme.textPrimary,
                        size: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitials() {
    return Container(
      color: StoryJobTheme.cardSurfaceElevated,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: StoryJobTheme.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}