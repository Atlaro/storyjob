// lib/features/auth/screens/dna_auth_screen.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:storydna/core/theme/storyjob_theme.dart';
import 'package:storydna/core/widgets/glass_button.dart';
import 'package:storydna/core/widgets/glass_card.dart';
import 'package:storydna/features/identity/screens/story_dna_screen.dart';

enum DnaAccountPerspective { individual, teamOrCompany }

class DnaAuthScreen extends StatefulWidget {
  const DnaAuthScreen({super.key});

  @override
  State<DnaAuthScreen> createState() => _DnaAuthScreenState();
}

class _DnaAuthScreenState extends State<DnaAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  DnaAccountPerspective _perspective = DnaAccountPerspective.individual;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptedTerms = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _syncUserDocument(
    User user, {
    String? customName,
    bool isGuest = false,
  }) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final existing = await userRef.get();
    final bool isTeam = _perspective == DnaAccountPerspective.teamOrCompany;

    if (!existing.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? _emailController.text.trim(),
        'displayName': customName ??
            user.displayName ??
            (isGuest
                ? 'Gast-Besucher (DNA Demo)'
                : (isTeam ? 'Neues Team' : 'StoryJob DNA Mitglied')),
        'role': isGuest ? 'guest' : (isTeam ? 'company' : 'talent'),
        'isGuestDemo': isGuest,
        'ecosystemOrigin': 'StoryJob DNA',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _navigateToDnaCenter() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const StoryDNAScreen()),
      (route) => false,
    );
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isRegisterMode && !_acceptedTerms) {
      setState(() => _errorMessage = 'Bitte akzeptiere die Nutzungsbedingungen und Datenschutzhinweise.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegisterMode) {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final user = credential.user;
        if (user != null) {
          final enteredName = _nameController.text.trim();
          if (enteredName.isNotEmpty) {
            await user.updateDisplayName(enteredName);
          }
          await _syncUserDocument(user, customName: enteredName.isNotEmpty ? enteredName : null);
          _navigateToDnaCenter();
        }
      } else {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (credential.user != null) {
          await _syncUserDocument(credential.user!);
          _navigateToDnaCenter();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            _errorMessage = 'E-Mail oder Passwort ist nicht korrekt.';
            break;
          case 'email-already-in-use':
            _errorMessage = 'Diese E-Mail-Adresse ist im StoryJob-Ökosystem bereits registriert.';
            break;
          case 'weak-password':
            _errorMessage = 'Das Passwort muss mindestens 6 Zeichen lang sein.';
            break;
          default:
            _errorMessage = e.message ?? 'Anmeldung fehlgeschlagen.';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Unerwarteter Fehler: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithProvider(AuthProvider provider, String label) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final UserCredential userCredential = kIsWeb
          ? await FirebaseAuth.instance.signInWithPopup(provider)
          : await FirebaseAuth.instance.signInWithProvider(provider);

      if (userCredential.user != null) {
        await _syncUserDocument(userCredential.user!);
        _navigateToDnaCenter();
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (!err.contains('canceled') && !err.contains('aborted') && !err.contains('popup_closed')) {
        setState(() => _errorMessage = '$label-Anmeldung aktuell nicht möglich.');
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
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

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
          await _syncUserDocument(
            cred.user!,
            customName: fullName.isNotEmpty ? fullName : null,
          );
          _navigateToDnaCenter();
        }
      } else {
        final provider = AppleAuthProvider()
          ..addScope('email')
          ..addScope('name');
        await _loginWithProvider(provider, 'Apple');
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (!err.contains('canceled') && !err.contains('aborted') && !err.contains('1001')) {
        setState(() => _errorMessage = 'Apple-Anmeldung aktuell nicht möglich.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAsGuest() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final user = currentUser ?? (await FirebaseAuth.instance.signInAnonymously()).user;
      if (user != null) {
        await _syncUserDocument(user, isGuest: true);
        _navigateToDnaCenter();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gastzugang konnte nicht gestartet werden: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTeam = _perspective == DnaAccountPerspective.teamOrCompany;
    final Color activeAccent = isTeam ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & StoryJob DNA™ Header
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StoryJobTheme.cardSurfaceElevated,
                        border: Border.all(color: activeAccent.withValues(alpha: 0.45), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: activeAccent.withValues(alpha: 0.22), blurRadius: 22),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.fingerprint_rounded,
                            size: 34,
                            color: StoryJobTheme.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: 'StoryJob ', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'DNA™', style: TextStyle(color: StoryJobTheme.pinkMagenta)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Dein persönliches Ich-Zentrum. Sammle deine Werte, Stimmen und echten Werte-Passungen an einem Ort.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Perspektiv-Wahl (Mein Ich-Zentrum vs. Team & Kultur-DNA)
                  Row(
                    children: [
                      Expanded(
                        child: _buildPerspectivePill(
                          selected: !isTeam,
                          icon: Icons.person_outline_rounded,
                          label: 'Mein Ich-Zentrum',
                          color: StoryJobTheme.cyanAccent,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _perspective = DnaAccountPerspective.individual);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPerspectivePill(
                          selected: isTeam,
                          icon: Icons.groups_outlined,
                          label: 'Team & Kultur-DNA',
                          color: StoryJobTheme.primaryViolet,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _perspective = DnaAccountPerspective.teamOrCompany);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Apple Sign-In (App Store Guideline 4.8 konform, prominent oben)
                  _buildSocialButton(
                    label: 'Mit Apple fortfahren',
                    icon: const Icon(Icons.apple_rounded, color: Colors.black, size: 22),
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    onTap: _isLoading ? null : _signInWithApple,
                  ),
                  const SizedBox(height: 10),
                  _buildSocialButton(
                    label: 'Mit Google fortfahren',
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFFEA4335),
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    onTap: _isLoading
                        ? null
                        : () => _loginWithProvider(GoogleAuthProvider(), 'Google'),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: StoryJobTheme.cardBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _isRegisterMode ? 'oder neu registrieren' : 'oder mit StoryJob-Konto',
                          style: const TextStyle(color: StoryJobTheme.textMuted, fontSize: 12),
                        ),
                      ),
                      const Expanded(child: Divider(color: StoryJobTheme.cardBorder)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // E-Mail & Passwort Karte
                  GlassCard(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_isRegisterMode) ...[
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: isTeam ? 'Team- oder Vereinsname' : 'Dein Vorname / Rufname',
                                prefixIcon: Icon(
                                  isTeam ? Icons.hub_outlined : Icons.badge_outlined,
                                  color: activeAccent,
                                  size: 19,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'E-Mail-Adresse',
                              prefixIcon: Icon(Icons.email_outlined, color: activeAccent, size: 19),
                            ),
                            validator: (v) =>
                                (v == null || !v.contains('@')) ? 'Bitte gültige E-Mail eingeben.' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Passwort (mind. 6 Zeichen)',
                              prefixIcon: Icon(Icons.lock_outline_rounded, color: activeAccent, size: 19),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: StoryJobTheme.textSecondary,
                                  size: 19,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.length < 6) ? 'Mindestens 6 Zeichen erforderlich.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_isRegisterMode) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: activeAccent,
                          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            'Ich akzeptiere die Nutzungsbedingungen und Datenschutzhinweise von StoryJob™.',
                            style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  GlassButton(
                    label: _isRegisterMode ? 'Ich-Zentrum eröffnen' : 'In meine DNA einloggen',
                    icon: Icons.fingerprint_rounded,
                    isPrimaryGlow: true,
                    isLoading: _isLoading,
                    onPressed: _submitEmailAuth,
                  ),

                  const SizedBox(height: 10),

                  GlassButton(
                    label: 'Ohne Konto als Gast ansehen',
                    icon: Icons.explore_outlined,
                    isPrimaryGlow: false,
                    onPressed: () { if (!_isLoading) _signInAsGuest(); },
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRegisterMode ? 'Schon ein StoryJob-Konto?' : 'Neu im Ökosystem?',
                        style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isRegisterMode ? 'Einloggen' : 'Jetzt erstellen',
                          style: TextStyle(
                            color: activeAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
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

  Widget _buildPerspectivePill({
    required bool selected,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : StoryJobTheme.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : StoryJobTheme.cardBorder,
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: selected ? color : StoryJobTheme.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? StoryJobTheme.textPrimary : StoryJobTheme.textSecondary,
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

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback? onTap,
    Color backgroundColor = StoryJobTheme.cardSurfaceElevated,
    Color textColor = StoryJobTheme.textPrimary,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}