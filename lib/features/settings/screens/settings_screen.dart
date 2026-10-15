// lib/features/settings/screens/settings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/auth/screens/login_screen.dart';
import 'package:storyjob/features/profile/screens/personal_data_screen.dart';
import 'package:storyjob/features/settings/screens/login_security_screen.dart';
import 'package:storyjob/features/settings/screens/widgets/feedback_dialog.dart';
import 'package:storyjob/features/settings/screens/widgets/legal_licenses_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _matchAlerts = true;
  bool _voiceAutoPlay = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsPreferences();
  }

  Future<void> _loadSettingsPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('settings_push') ?? true;
      _matchAlerts = prefs.getBool('settings_alerts') ?? true;
      _voiceAutoPlay = prefs.getBool('settings_autoplay') ?? false;
    });
  }

  Future<void> _updatePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showLogoutDialog() {
    HapticFeedback.heavyImpact();
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
                border: Border.all(color: StoryJobTheme.cardBorder),
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
                        child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Abmelden?',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Möchtest du dich wirklich aus deinem StoryJob-Account abmelden?',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13, height: 1.4),
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
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Abmelden', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

  void _showHelpAndContactDialog(BuildContext context) {
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
                        child: const Icon(Icons.help_outline_rounded, color: StoryJobTheme.cyanAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hilfe & Kontakt',
                          style: TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Fragen, Impulse oder technischer Support? Schreib uns jederzeit direkt auf Augenhöhe:',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: const Text(
                      'story.job@outlook.de',
                      style: TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryJobTheme.textSecondary,
                            side: const BorderSide(color: StoryJobTheme.cardBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Schließen', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await Clipboard.setData(const ClipboardData(text: 'story.job@outlook.de'));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'E-Mail-Adresse kopiert ✨',
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
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryJobTheme.primaryViolet,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Kopieren', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Einstellungen',
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
            // 1. Konto & Sicherheit
            _buildSectionLabel('KONTO & SICHERHEIT'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _buildRowItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Persönlicher Bereich',
                    value: 'Name, Region, Bio',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PersonalDataScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildRowItem(
                    icon: Icons.shield_outlined,
                    title: 'Login & Sicherheit',
                    value: 'Passwort, Schutz',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginSecurityScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Benachrichtigungen & Audio
            _buildSectionLabel('BENACHRICHTIGUNGEN & AUDIO'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _buildSwitchRow(
                    title: 'Push-Mitteilungen',
                    subtitle: 'Direkte Updates zu Resonanzen & Dialogen',
                    value: _pushNotifications,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _pushNotifications = val);
                      _updatePref('settings_push', val);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchRow(
                    title: 'Werte-Resonanz Alerts',
                    subtitle: 'Mitteilung bei hoher Werte-Passung (85%+)',
                    value: _matchAlerts,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _matchAlerts = val);
                      _updatePref('settings_alerts', val);
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchRow(
                    title: 'Voice-Story Autoplay',
                    subtitle: 'Stories beim Scrollen dezent anspielen',
                    value: _voiceAutoPlay,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() => _voiceAutoPlay = val);
                      _updatePref('settings_autoplay', val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Support & Feedback
            _buildSectionLabel('SUPPORT & FEEDBACK'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Column(
                children: [
                  _buildRowItem(
                    icon: Icons.rate_review_outlined,
                    title: 'Feedback & Ideen',
                    value: 'Impulse teilen',
                    onTap: () => FeedbackDialog.show(context),
                  ),
                  _buildDivider(),
                  _buildRowItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Hilfe & Support',
                    value: 'Kontakt',
                    onTap: () => _showHelpAndContactDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Rechtliches
            _buildSectionLabel('RECHTLICHES'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: _buildRowItem(
                icon: Icons.description_outlined,
                title: 'Impressum & Lizenzen',
                value: 'Open Source',
                onTap: () => LegalLicensesModal.show(context),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Abmelden
            Container(
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: ListTile(
                onTap: _showLogoutDialog,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                title: const Text(
                  'Abmelden',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: StoryJobTheme.textMuted, size: 12),
              ),
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text(
                'StoryJob • Version 1.0.0',
                style: TextStyle(color: StoryJobTheme.textMuted, fontSize: 12),
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

  Widget _buildRowItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
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
            Icon(icon, color: StoryJobTheme.cyanAccent, size: 19),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value.isNotEmpty) ...[
              Text(
                value,
                style: const TextStyle(
                  color: StoryJobTheme.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: StoryJobTheme.textMuted,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: StoryJobTheme.cyanAccent,
            activeTrackColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.25),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: StoryJobTheme.cardBorder,
    );
  }
}