import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/Teams/screens/team_dashboard_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';

class DnaAuthScreen extends StatefulWidget {
  final String selectedRole;

  const DnaAuthScreen({super.key, this.selectedRole = 'talent'});

  @override
  State<DnaAuthScreen> createState() => _DnaAuthScreenState();
}

class _DnaAuthScreenState extends State<DnaAuthScreen> {
  bool _isLogin = false;
  bool _showEmailForm = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool get _isTeam => widget.selectedRole == 'team';

  Color get _roleAccent =>
      _isTeam ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchAuthMode(bool toLogin) {
    HapticFeedback.selectionClick();
    setState(() {
      _isLogin = toLogin;
      _formKey.currentState?.reset();
    });
  }

  void _showLegalNotice(String title, String bodyText) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: const TextStyle(
            color: StoryJobTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          bodyText,
          style: const TextStyle(
            color: StoryJobTheme.textSecondary,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Schließen',
              style: TextStyle(
                color: _roleAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ensureUserBackbone(User user, {String? customName}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'displayName': customName ??
            user.displayName ??
            (user.isAnonymous
                ? 'Gast-Entdecker'
                : (_isTeam ? 'Neues StoryJob™ Team' : 'StoryJob™ Mitglied')),
        'email': user.email ?? '',
        'role': widget.selectedRole,
        'isGuest': user.isAnonymous,
        'dnaVerified': false,
        'signatureCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'isGuest': user.isAnonymous,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _navigateByRole(User user) async {
    await _ensureUserBackbone(user);
    if (!mounted) return;

    if (_isTeam) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TeamDashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TalentNavigationScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _continueAsGuest() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      if (credential.user != null) {
        await _navigateByRole(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapFirebaseError(e.code, e.message));
    } catch (_) {
      _showErrorSnackBar('Gastzugang ist aktuell nicht verfügbar.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      UserCredential credential;
      final password = _passwordController.text;

      if (_isLogin) {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: password,
        );
      } else {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: password,
        );

        final user = credential.user;
        if (user != null) {
          final cleanName = _nameController.text.trim();
          await user.updateDisplayName(cleanName);
          await _ensureUserBackbone(user, customName: cleanName);
        }
      }

      if (credential.user != null) {
        await _navigateByRole(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapFirebaseError(e.code, e.message));
    } catch (_) {
      _showErrorSnackBar('Ein unerwarteter Fehler ist aufgetreten.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showErrorSnackBar('Bitte gib zuerst oben deine E-Mail-Adresse ein.');
      return;
    }

    HapticFeedback.lightImpact();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link zum Zurücksetzen wurde an $email gesendet.'),
          backgroundColor: StoryJobTheme.cyanAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapFirebaseError(e.code, e.message));
    }
  }

  String _createNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

    final random = Random.secure();

    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<void> _signInWithApple() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final rawNonce = _createNonce();

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: _sha256OfString(rawNonce),
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'apple-missing-id-token',
          message: 'Apple hat kein gültiges Anmelde-Token zurückgegeben.',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user == null) return;

      final givenName = appleCredential.givenName?.trim() ?? '';
      final familyName = appleCredential.familyName?.trim() ?? '';
      final appleName = '$givenName $familyName'.trim();

      if (appleName.isNotEmpty && (user.displayName?.trim().isEmpty ?? true)) {
        await user.updateDisplayName(appleName);
        await user.reload();
      }

      await _navigateByRole(FirebaseAuth.instance.currentUser ?? user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) {
        _showErrorSnackBar('Die Anmeldung mit Apple ist fehlgeschlagen.');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapFirebaseError(e.code, e.message));
    } catch (_) {
      _showErrorSnackBar('Die Anmeldung mit Apple ist fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    try {
      UserCredential credential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()..addScope('email');
        credential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        if (googleAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'google-missing-id-token',
            message: 'Google hat kein gültiges ID-Token zurückgegeben.',
          );
        }

        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential =
            await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      }

      if (credential.user != null) {
        await _navigateByRole(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_mapFirebaseError(e.code, e.message));
    } catch (_) {
      _showErrorSnackBar('Die Anmeldung mit Google ist fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String code, String? fallback) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'E-Mail oder Passwort ist nicht korrekt.';
      case 'email-already-in-use':
        return 'Diese E-Mail-Adresse ist bereits registriert.';
      case 'weak-password':
        return 'Bitte wähle ein stärkeres Passwort (mind. 6 Zeichen).';
      case 'network-request-failed':
        return 'Keine Internetverbindung verfügbar.';
      default:
        return fallback ?? 'Authentifizierung fehlgeschlagen.';
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: StoryJobTheme.pinkMagenta,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _showEmailForm
            ? Text(
                _isLogin ? 'Anmelden' : 'Registrieren',
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              )
            : null,
        leading: IconButton(
          tooltip: _showEmailForm ? 'Zurück zur Auswahl' : 'Bereich wechseln',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (_showEmailForm) {
              setState(() => _showEmailForm = false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Über StoryJob™',
            icon: const Icon(
              Icons.help_outline_rounded,
              color: StoryJobTheme.textSecondary,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'StoryJob™ — Potenzial sichtbar machen. Entfalte deine Story. Auf Augenhöhe.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: GlowOrb(color: _roleAccent, size: 280),
          ),
          const Positioned(
            bottom: -80,
            left: -60,
            child: GlowOrb(color: StoryJobTheme.primaryViolet, size: 280),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                  child: _showEmailForm
                      ? _buildEmailFormView()
                      : _buildGatewayView(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Hero(
            tag: _isTeam
                ? 'storyjob_role_logo_team'
                : 'storyjob_role_logo_talent',
            child: Image.asset(
              _isTeam
                  ? 'assets/images/Auth/Team.png'
                  : 'assets/images/Auth/DNA.png',
              height: 84,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _isLogin
              ? (_isTeam
                  ? 'StoryJob™ Teams — Wer sind wir?'
                  : 'StoryJob™ DNA — Wer bin ich?')
              : (_isTeam
                  ? 'Potenzial sichtbar machen. StoryJob™ Teams anlegen.'
                  : 'Potenzial sichtbar machen. Konto anlegen und starten.'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: StoryJobTheme.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? (_isTeam
                  ? 'Melde dich an, um eure Team-Kultur und Resonanzen fortzuführen.'
                  : 'Willkommen zurück. Melde dich an, um fortzufahren.')
              : (_isTeam
                  ? 'Zeigt eure Werte, Zusammenarbeit und Zukunftsfähigkeit auf Augenhöhe.'
                  : 'Entfalte deine Story. Auf Augenhöhe — für echte Teilhabe und Potenzial.'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: StoryJobTheme.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),

        // 1. E-Mail registrieren / anmelden
        Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: _isTeam
                  ? [
                      StoryJobTheme.primaryViolet,
                      const Color(0xFF9D4EDD),
                    ]
                  : [
                      StoryJobTheme.cyanAccent,
                      const Color(0xFF00B4D8),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: _roleAccent.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () => setState(() => _showEmailForm = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor:
                  _isTeam ? Colors.white : StoryJobTheme.backgroundBase,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              _isLogin ? 'Mit E-Mail anmelden' : 'Mit E-Mail registrieren',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Weiter mit Apple
        SizedBox(
          height: 52,
          child: SignInWithAppleButton(
            text: 'Weiter mit Apple',
            onPressed: _isLoading ? () {} : _signInWithApple,
            style: SignInWithAppleButtonStyle.white,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Weiter mit Google
        InkWell(
          onTap: _isLoading ? null : _signInWithGoogle,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: SvgPicture.asset(
                    'assets/icons/google-color.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Weiter mit Google',
                  style: TextStyle(
                    color: Color(0xFF0B1120),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!_isTeam) ...[
          const SizedBox(height: 20),
          const Text(
            'oder',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StoryJobTheme.textSecondary,
              fontSize: 13.5,
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _continueAsGuest,
            child: Text(
              'Als Gast fortfahren',
              style: TextStyle(
                color: _roleAccent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Wechsel Registrieren <-> Anmelden
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin
                  ? 'Neu bei StoryJob™? '
                  : 'Du bist bereits registriert? ',
              style: const TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 13.5,
              ),
            ),
            GestureDetector(
              onTap: _isLoading ? null : () => _switchAuthMode(!_isLogin),
              child: Text(
                _isLogin ? 'Registrieren' : 'Anmelden',
                style: TextStyle(
                  color: _roleAccent,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Nutzungsbedingungen & Datenschutz
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            const Text(
              'Durch die Nutzung von StoryJob™ stimmst du unseren ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            GestureDetector(
              onTap: () => _showLegalNotice(
                'Nutzungsbedingungen',
                'StoryJob™ unterstützt Menschen und Teams dabei, Potenziale, Werte und Perspektiven sichtbar zu machen — unter storyjob.de/impressum/ einsehbar.',
              ),
              child: Text(
                'Nutzungsbedingungen',
                style: TextStyle(
                  color: _roleAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              ' und ',
              style: TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () => _showLegalNotice(
                'Datenschutz-Bestimmungen',
                'Informationen zum Umgang mit deinen Daten findest du unter storyjob.de/datenschutz/ sowie in den App-Einstellungen.',
              ),
              child: Text(
                'Datenschutz-Bestimmungen',
                style: TextStyle(
                  color: _roleAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              ' zu.',
              style: TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailFormView() {
    return Container(
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: StoryJobTheme.cardBorder,
          width: 1.1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isLogin) ...[
                    _buildTextField(
                      controller: _nameController,
                      hintText: _isTeam
                          ? 'Name des Teams / Vereins / Unternehmens'
                          : 'Vollständiger Name',
                      icon: _isTeam
                          ? Icons.groups_outlined
                          : Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      validator: (val) => val != null && val.trim().isEmpty
                          ? 'Bitte Namen eingeben'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'E-Mail Adresse',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val != null && !val.contains('@')
                        ? 'Gültige E-Mail eingeben'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Passwort',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (val) => val != null && val.length < 6
                        ? 'Mindestens 6 Zeichen'
                        : null,
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Passwort wiederholen',
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Bitte Passwort wiederholen';
                        }
                        if (val != _passwordController.text) {
                          return 'Passwörter stimmen nicht überein';
                        }
                        return null;
                      },
                    ),
                  ],
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Passwort vergessen?',
                          style: TextStyle(
                            color: StoryJobTheme.textSecondary
                                .withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: _isTeam
                            ? [
                                StoryJobTheme.primaryViolet,
                                const Color(0xFF9D4EDD),
                              ]
                            : [
                                StoryJobTheme.cyanAccent,
                                const Color(0xFF00B4D8),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _roleAccent.withValues(alpha: 0.3),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: _isTeam
                            ? Colors.white
                            : StoryJobTheme.backgroundBase,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: _isTeam
                                    ? Colors.white
                                    : StoryJobTheme.backgroundBase,
                                strokeWidth: 2.2,
                              ),
                            )
                          : Text(
                              _isLogin
                                  ? (_isTeam
                                      ? 'Als Team anmelden'
                                      : 'StoryJob™ öffnen')
                                  : (_isTeam
                                      ? 'StoryJob™ Teams starten'
                                      : 'StoryJob™ DNA starten'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? 'Neu bei StoryJob™? '
                            : 'Du bist bereits registriert? ',
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => _switchAuthMode(!_isLogin),
                        child: Text(
                          _isLogin ? 'Registrieren' : 'Anmelden',
                          style: TextStyle(
                            color: _roleAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5),
        prefixIcon: Icon(icon, color: StoryJobTheme.textSecondary, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: StoryJobTheme.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: StoryJobTheme.backgroundBase.withValues(alpha: 0.65),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _roleAccent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StoryJobTheme.pinkMagenta),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StoryJobTheme.pinkMagenta),
        ),
      ),
      validator: validator,
    );
  }
}