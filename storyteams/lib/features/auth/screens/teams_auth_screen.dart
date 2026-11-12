// lib/features/auth/screens/teams_auth_screen.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/teams/screens/teams_landing_screen.dart';

class TeamsAuthScreen extends StatefulWidget {
  const TeamsAuthScreen({super.key});

  @override
  State<TeamsAuthScreen> createState() => _TeamsAuthScreenState();
}

class _TeamsAuthScreenState extends State<TeamsAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;
  bool _isLeaderEntry = true; // true = Leitung/Vorstand, false = Mitglied/Neuling
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _syncProfile(
    User user, {
    String? customName,
    bool isGuest = false,
    String? inviteCode,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email ?? _emailController.text.trim(),
        'displayName': customName ??
            user.displayName ??
            (isGuest ? 'Gast-Besucher (Demo)' : 'Team-Mitglied'),
        'role': isGuest ? 'guest' : (_isLeaderEntry ? 'company' : 'talent'),
        'isGuestDemo': isGuest,
        if (inviteCode != null && inviteCode.isNotEmpty)
          'pendingInviteCode': inviteCode.toUpperCase(),
        'ecosystemOrigin': 'StoryJob Teams',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else if (inviteCode != null && inviteCode.isNotEmpty) {
      await ref.set({
        'pendingInviteCode': inviteCode.toUpperCase(),
      }, SetOptions(merge: true));
    }
  }

  void _openLanding() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TeamsLandingScreen()),
      (route) => false,
    );
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isRegister) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (cred.user != null) {
          final name = _nameController.text.trim();
          if (name.isNotEmpty) await cred.user!.updateDisplayName(name);
          await _syncProfile(cred.user!, customName: name.isNotEmpty ? name : null);
          _openLanding();
        }
      } else {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (cred.user != null) {
          await _syncProfile(cred.user!);
          _openLanding();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Anmeldung fehlgeschlagen.');
    } catch (e) {
      setState(() => _error = 'Fehler: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInProvider(AuthProvider provider, String label) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cred = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(provider)
          : await FirebaseAuth.instance.signInWithProvider(provider);
      if (cred.user != null) {
        await _syncProfile(cred.user!);
        _openLanding();
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (!msg.contains('canceled') && !msg.contains('aborted')) {
        setState(() => _error = '$label-Anmeldung aktuell nicht verfügbar.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final isAppleNative = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS);

      if (isAppleNative) {
        final rawNonce = _generateNonce();
        final hashedNonce = _sha256ofString(rawNonce);
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode,
        );

        final cred = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
        if (cred.user != null) {
          final fullName = [
            appleCredential.givenName,
            appleCredential.familyName,
          ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

          if (fullName.isNotEmpty) {
            await cred.user!.updateDisplayName(fullName);
          }
          await _syncProfile(
            cred.user!,
            customName: fullName.isNotEmpty ? fullName : null,
          );
          _openLanding();
        }
      } else {
        final provider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        await _signInProvider(provider, 'Apple');
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (!msg.contains('canceled') && !msg.contains('aborted') && !msg.contains('1001')) {
        setState(() => _error = 'Apple-Anmeldung aktuell nicht verfügbar.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAsGuest({String? inviteCode}) async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final user = currentUser ?? (await FirebaseAuth.instance.signInAnonymously()).user;
      if (user != null) {
        await _syncProfile(
          user,
          customName: inviteCode != null && inviteCode.isNotEmpty
              ? 'Mitglied ($inviteCode)'
              : 'Gast-Besucher (Demo)',
          isGuest: inviteCode == null || inviteCode.isEmpty,
          inviteCode: inviteCode,
        );
        _openLanding();
      }
    } catch (e) {
      setState(() => _error = 'Gastzugang konnte nicht gestartet werden: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showInviteCodeDialog() async {
    final codeController = TextEditingController();
    final enteredCode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Mit Einladungscode beitreten',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gib den 6-stelligen Team-Code deines Vereins, deiner Wehr oder deines Betriebs ein.',
              style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                hintText: 'z. B. FF-2026',
                prefixIcon: Icon(Icons.vpn_key_outlined, size: 19),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen', style: TextStyle(color: StoryJobTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(codeController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: StoryJobTheme.cyanAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Beitreten', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    codeController.dispose();

    if (enteredCode != null && enteredCode.isNotEmpty) {
      setState(() => _isLeaderEntry = false);
      await _signInAsGuest(inviteCode: enteredCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isLeaderEntry ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StoryJobTheme.cardSurfaceElevated,
                        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Icon(Icons.groups_rounded, color: accent, size: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      children: [
                        TextSpan(text: 'StoryJob ', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'Teams', style: TextStyle(color: StoryJobTheme.cyanAccent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Echte Kameradschaft. Live-Status, Dienstplan & Kultur für Vereine, Blaulicht und Betriebe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5, height: 1.35),
                  ),
                  const SizedBox(height: 20),

                  // Perspektiv-Umschalter: Leitung/Vorstand vs. Mitglied/Neuling
                  Row(
                    children: [
                      Expanded(
                        child: _buildRolePill(
                          selected: _isLeaderEntry,
                          label: 'Leitung & Vorstand',
                          icon: Icons.shield_outlined,
                          color: StoryJobTheme.primaryViolet,
                          onTap: () => setState(() => _isLeaderEntry = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRolePill(
                          selected: !_isLeaderEntry,
                          label: 'Mitglied & Anwärter',
                          icon: Icons.person_add_alt_1_outlined,
                          color: StoryJobTheme.cyanAccent,
                          onTap: () => setState(() => _isLeaderEntry = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Apple Sign-In (App Store Guideline 4.8 konform)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithApple,
                    icon: const Icon(Icons.apple, size: 22),
                    label: const Text('Mit Apple fortfahren'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Google Sign-In
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _signInProvider(GoogleAuthProvider(), 'Google'),
                    icon: const Text(
                      'G',
                      style: TextStyle(color: Color(0xFFEA4335), fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                    label: const Text('Mit StoryJob-Google-Konto fortfahren'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_isRegister) ...[
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Dein Name / Rufname im Team',
                                prefixIcon: Icon(Icons.badge_outlined, size: 19),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'E-Mail-Adresse',
                              prefixIcon: Icon(Icons.email_outlined, size: 19),
                            ),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Gültige E-Mail eingeben' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Passwort',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 19),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6) ? 'Mindestens 6 Zeichen' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: _isLeaderEntry ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      _isLoading
                          ? 'Verbinde...'
                          : (_isRegister ? 'Team-Konto erstellen' : 'In StoryJob Teams starten'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gastmodus (Demo-Einblick) & Einladungscode getrennt zugänglich
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => _signInAsGuest(),
                          icon: const Icon(Icons.explore_outlined, size: 16),
                          label: const Text('Als Gast testen', style: TextStyle(fontSize: 12.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryJobTheme.textSecondary,
                            side: const BorderSide(color: StoryJobTheme.cardBorder),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _showInviteCodeDialog,
                          icon: const Icon(Icons.vpn_key_outlined, size: 16),
                          label: const Text('Einladungscode', style: TextStyle(fontSize: 12.5)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryJobTheme.cyanAccent,
                            side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.45)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRegister ? 'Bereits im Ökosystem?' : 'Noch kein Konto?',
                        style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isRegister = !_isRegister),
                        child: Text(
                          _isRegister ? 'Einloggen' : 'Registrieren',
                          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
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

  Widget _buildRolePill({
    required bool selected,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : StoryJobTheme.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : StoryJobTheme.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : StoryJobTheme.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : StoryJobTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}