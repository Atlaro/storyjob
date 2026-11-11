// lib/features/match/widgets/resonance_match_card.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

enum MatchAura { culture, workstyle, vision }

class ResonanceMatchCard extends StatefulWidget {
  final String companyName;
  final String matchPercentage;
  final MatchAura auraType;
  final String voiceImpulseTitle;

  // Dynamische Felder für das Smart Reveal Panel (Hard-Facts)
  final String locationStr;
  final String salaryStr;
  final String benefitsStr;
  final List<String> sharedValues;

  final VoidCallback onMatch;
  final VoidCallback onPass;

  const ResonanceMatchCard({
    super.key,
    required this.companyName,
    required this.matchPercentage,
    required this.auraType,
    required this.voiceImpulseTitle,
    required this.locationStr,
    required this.salaryStr,
    required this.benefitsStr,
    required this.sharedValues,
    required this.onMatch,
    required this.onPass,
  });

  @override
  State<ResonanceMatchCard> createState() => _ResonanceMatchCardState();
}

class _ResonanceMatchCardState extends State<ResonanceMatchCard> with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isPlaying = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _auraColor {
    switch (widget.auraType) {
      case MatchAura.culture:
        return StoryJobTheme.primaryViolet; // Fokus: Team & Augenhöhe
      case MatchAura.workstyle:
        return StoryJobTheme.cyanAccent; // Fokus: Autonomie & Macher
      case MatchAura.vision:
        return StoryJobTheme.amberEnergy; // Fokus: Haltung & Sinnstiftung
    }
  }

  String get _auraLabel {
    switch (widget.auraType) {
      case MatchAura.culture:
        return 'Team-Fit';
      case MatchAura.workstyle:
        return 'Workstyle-Fit';
      case MatchAura.vision:
        return 'Werte-Match';
    }
  }

  double _parsePercentage(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final val = double.tryParse(clean) ?? 94.0;
    return val.clamp(0.0, 100.0);
  }

  void _togglePlay() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleExpand() {
    HapticFeedback.selectionClick();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double numericScore = _parsePercentage(widget.matchPercentage);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        gradient: StoryJobTheme.dnaCardBorder,
        boxShadow: [
          BoxShadow(
            color: _auraColor.withValues(alpha: 0.20),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.2), // Subtiler 1.2px Neon-Rand
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: StoryJobTheme.cardSurface.withValues(alpha: 0.92),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- VORDERSEITE (TEAM-FIT & KULTUR) ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22.0, 20.0, 22.0, 18.0),
                    child: Column(
                      children: [
                        // Top-Bar: Tag & Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _auraColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _auraColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _auraLabel,
                                style: TextStyle(
                                  color: _auraColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _auraColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _auraColor.withValues(alpha: 0.8),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.matchPercentage} Match',
                                  style: const TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Neon-Halbbogen aus den Screenshots
                        SizedBox(
                          width: 110,
                          height: 60,
                          child: CustomPaint(
                            painter: _CardArcPainter(
                              progress: numericScore / 100.0,
                              accentColor: _auraColor,
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                "${numericScore.toInt()}%",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Team- & Werte-Fit',
                          style: TextStyle(fontSize: 11, color: StoryJobTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),

                        // Unternehmensname & Voice-Impuls Titel
                        Text(
                          widget.companyName,
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.voiceImpulseTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Integrierte Audio-Story Bar
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.cardSurfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isPlaying ? _auraColor : StoryJobTheme.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _auraColor.withValues(alpha: 0.18),
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: _auraColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(20, (i) {
                                        final h = [8, 14, 20, 12, 24, 18, 10, 22, 16, 26, 12, 18, 14, 20, 10, 14, 18, 12, 8, 14];
                                        return Container(
                                          width: 2.5,
                                          height: h[i % h.length].toDouble(),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Team-Impuls',
                                  style: TextStyle(
                                    color: StoryJobTheme.textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- AUFKLAPP-BEREICH (HARD-FACTS) ---
                  AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: _isExpanded
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFF13151D),
                              border: Border(
                                top: BorderSide(color: StoryJobTheme.cardBorder, width: 1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFactRow(Icons.location_on_rounded, widget.locationStr),
                                const SizedBox(height: 10),
                                _buildFactRow(Icons.account_balance_wallet_rounded, widget.salaryStr),
                                const SizedBox(height: 10),
                                _buildFactRow(Icons.card_giftcard_rounded, widget.benefitsStr),
                                const SizedBox(height: 16),
                                const Text(
                                  'Gemeinsames Werte-Fundament:',
                                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: widget.sharedValues.map((v) => _buildValueChip(v)).toList(),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Smart Reveal Toggle Button
                  GestureDetector(
                    onTap: _toggleExpand,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: StoryJobTheme.cardBorder, width: 1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isExpanded ? 'Fakten ausblenden' : 'Hard-Facts ansehen',
                            style: const TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: StoryJobTheme.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- WELLENLÄNGEN-TUNER ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.backgroundBase.withValues(alpha: 0.6),
                      border: const Border(top: BorderSide(color: StoryJobTheme.cardBorder, width: 1)),
                    ),
                    child: _WavelengthTuner(
                      auraColor: _auraColor,
                      onMatchTriggered: widget.onMatch,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: StoryJobTheme.textMuted, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _auraColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _auraColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _auraColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTER: NEON-HALBBOGEN
// ============================================================================
class _CardArcPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _CardArcPainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 5;
    const strokeWidth = 5.0;

    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, bgPaint);

    final sweepGradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [StoryJobTheme.cyanAccent, accentColor, StoryJobTheme.pinkMagenta],
    );

    final activePaint = Paint()
      ..shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi * progress.clamp(0.0, 1.0), false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _CardArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accentColor != accentColor;
}

// ============================================================================
// DER WELLENLÄNGEN-TUNER
// ============================================================================
class _WavelengthTuner extends StatefulWidget {
  final Color auraColor;
  final VoidCallback onMatchTriggered;

  const _WavelengthTuner({
    required this.auraColor,
    required this.onMatchTriggered,
  });

  @override
  State<_WavelengthTuner> createState() => _WavelengthTunerState();
}

class _WavelengthTunerState extends State<_WavelengthTuner> with SingleTickerProviderStateMixin {
  double _dragProgress = 0.0;
  bool _isMatched = false;
  late AnimationController _snapController;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _dragProgress = _snapController.value;
        });
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isMatched) return;

    setState(() {
      _dragProgress += details.delta.dx / (maxWidth - 56);
      _dragProgress = _dragProgress.clamp(0.0, 1.0);
    });

    if (_dragProgress > 0.3 && _dragProgress < 0.32) HapticFeedback.selectionClick();
    if (_dragProgress > 0.6 && _dragProgress < 0.62) HapticFeedback.selectionClick();
    if (_dragProgress > 0.9 && _dragProgress < 0.92) HapticFeedback.mediumImpact();
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isMatched) return;

    if (_dragProgress >= 0.85) {
      HapticFeedback.heavyImpact();
      _snapController.value = _dragProgress;
      _snapController.animateTo(1.0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      setState(() {
        _isMatched = true;
      });
      Future.delayed(const Duration(milliseconds: 400), widget.onMatchTriggered);
    } else {
      HapticFeedback.lightImpact();
      _snapController.value = _dragProgress;
      _snapController.animateTo(0.0, curve: Curves.easeOutBack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const thumbWidth = 54.0;
        final trackWidth = maxWidth - thumbWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isMatched ? 'Team-Fit bestätigt!' : 'Stimmt die Wellenlänge?',
                  style: TextStyle(
                    color: _isMatched ? widget.auraColor : StoryJobTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: _isMatched ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (!_isMatched)
                  const Text(
                    'Ziehen für Match',
                    style: TextStyle(
                      color: StoryJobTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onPanUpdate: (details) => _onPanUpdate(details, maxWidth),
              onPanEnd: _onPanEnd,
              child: Container(
                width: maxWidth,
                height: 54,
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _dragProgress > 0
                          ? (_dragProgress * (trackWidth / maxWidth) + (thumbWidth / maxWidth))
                          : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(27),
                          gradient: LinearGradient(
                            colors: [
                              widget.auraColor.withValues(alpha: 0.1),
                              widget.auraColor.withValues(alpha: 0.4 + (_dragProgress * 0.4)),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _dragProgress * trackWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: thumbWidth,
                        height: thumbWidth,
                        decoration: BoxDecoration(
                          color: _isMatched ? widget.auraColor : StoryJobTheme.cardSurfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isMatched
                                ? Colors.transparent
                                : widget.auraColor.withValues(alpha: 0.5 + (_dragProgress * 0.5)),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.auraColor.withValues(alpha: _dragProgress * 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _isMatched ? Icons.check_rounded : Icons.graphic_eq_rounded,
                            color: _isMatched ? Colors.white : widget.auraColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}