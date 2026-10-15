// lib/features/settings/screens/login_security_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/auth/screens/login_screen.dart';

class LoginSecurityScreen extends StatefulWidget {
  const LoginSecurityScreen({super.key});

  @override
  State<LoginSecurityScreen> createState() => _LoginSecurityScreenState();
}

class _LoginSecurityScreenState extends State<LoginSecurityScreen> {
  bool _isProcessing = false;

  void _showPasswordResetDialog() {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Keine verknüpfte E-Mail-Adresse gefunden.',
            style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.key_rounded, color: StoryJobTheme.cyanAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Passwort zurücksetzen?',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Wir senden einen sicheren Link zum Zurücksetzen deines Passworts an:\n\n$email',
                    style: const TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryJobTheme.textSecondary,
                            side: const BorderSide(color: StoryJobTheme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Abbrechen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            final success = await AppServices.sendPasswordReset(email);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Link wurde an $email gesendet ✨'
                                      : 'Fehler beim Senden. Bitte versuche es später.',
                                  style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13),
                                ),
                                backgroundColor: StoryJobTheme.cardSurfaceElevated,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: StoryJobTheme.cardBorder),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryJobTheme.primaryViolet,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Link senden', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.45)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Konto unwiderruflich löschen?',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Gemäß DSGVO werden alle deine Profildaten, Sprachaufnahmen, Stories, Match-Resonanzen und Chat-Verläufe unwiderruflich entfernt.',
                    style: TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryJobTheme.textSecondary,
                            side: const BorderSide(color: StoryJobTheme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Abbrechen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            setState(() => _isProcessing = true);

                            try {
                              await AppServices.deleteUserAccountCascade();

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Dein Konto wurde vollständig gelöscht.', style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 13)),
                                  backgroundColor: StoryJobTheme.cardSurfaceElevated,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(color: StoryJobTheme.cardBorder),
                                  ),
                                ),
                              );

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Fehler beim Löschen: $e', style: const TextStyle(fontSize: 13)),
                                  backgroundColor: StoryJobTheme.cardSurfaceElevated,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isProcessing = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Endgültig löschen', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        backgroundColor: StoryJobTheme.backgroundBase,
        body: Center(
          child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Keine E-Mail hinterlegt';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Login & Sicherheit',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 40.0),
          children: [
            // Status-Karte: Aktives Konto
            _buildSectionLabel('AKTIVES KONTO'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: StoryJobTheme.cardSurface,
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: const Icon(Icons.person_outline_rounded, color: StoryJobTheme.cyanAccent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userEmail,
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Angemeldet',
                          style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Zugangsdaten
            _buildSectionLabel('ZUGANGSDATEN'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _buildActionRow(
                    icon: Icons.key_outlined,
                    title: 'Passwort ändern',
                    onTap: _showPasswordResetDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Datenverwaltung / DSGVO
            _buildSectionLabel('KONTO & DATENVERWALTUNG'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: _buildActionRow(
                icon: Icons.delete_outline_rounded,
                title: 'Konto löschen',
                isDestructive: true,
                onTap: _showDeleteAccountDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: StoryJobTheme.textMuted,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? const Color(0xFFEF4444) : StoryJobTheme.cyanAccent,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? const Color(0xFFEF4444) : StoryJobTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: StoryJobTheme.textMuted,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}