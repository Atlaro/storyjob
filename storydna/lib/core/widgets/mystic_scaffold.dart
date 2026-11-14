// lib/core/widgets/mystic_scaffold.dart
import 'package:flutter/material.dart';
import 'package:storydna/core/widgets/glow_orb.dart';

class MysticScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showGlow;
  final Widget? bottomNavigationBar;

  const MysticScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.showGlow = true,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 100% True Black für OLED-Tiefe
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Subtiler, performanter Hintergrund-Glow als Ambient Light
          if (showGlow)
            const Positioned(
              top: -60,
              right: -60,
              child: GlowOrb(
                color: Colors.orange,
                size: 280,
                opacity: 0.15,
              ),
            ),
          // Hauptinhalt
          SafeArea(child: body),
        ],
      ),
    );
  }
}