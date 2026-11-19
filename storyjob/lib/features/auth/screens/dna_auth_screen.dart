import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';
import 'package:storyjob/features/Teams/screens/team_dashboard_screen.dart';

class DnaAuthScreen extends StatefulWidget {
  final String selectedRole;

  const DnaAuthScreen({super.key, this.selectedRole = 'talent'});

  @override
  State<DnaAuthScreen> createState() => _DnaAuthScreenState();
}

class _DnaAuthScreenState extends State<DnaAuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get _isTeam => widget.selectedRole == 'team';

  Color get _roleAccent =>
      _isTeam ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _ensureUserBackbone(User user, {String? customName}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'displayName': customName ??
            user.displayName ??
            (_isTeam ? 'Neues StoryTeam' : 'StoryJob Mitglied'),
        'email': user.email ?? '',
        'role': widget.selectedRole,
        'dnaVerified': false,
        'signatureCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
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
        leading: IconButton(
          tooltip: 'Rolle wechseln',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
            child: GlowOrb(color: StoryJobTheme.primaryViolet, size: 260),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Hero(
                          tag: 'storyjob_role_logo',
                          child: Image.asset(
                            _isTeam
                                ? 'assets/images/Auth/Team.png'
                                : 'assets/images/Auth/DNA.png',
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isLogin
                            ? (_isTeam
                                ? 'Team-Zugang öffnen'
                                : 'Willkommen zurück')
                            : (_isTeam
                                ? 'StoryTeam erstellen'
                                : 'Deine StoryDNA starten'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? (_isTeam
                                ? 'Melde dich für dein Unternehmen, deinen Verein oder dein Projekt an.'
                                : 'Greife auf deine StoryJob DNA™ und deine Chancen zu.')
                            : (_isTeam
                                ? 'Zeigt eure gemeinsamen Werte und verbindet euch mit den richtigen Menschen.'
                                : 'Dein Fundament für Werte, Persönlichkeit, Voice Story & echte Resonanz.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: StoryJobTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cardSurfaceElevated
                              .withValues(alpha: 0.72),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    height: 46,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: StoryJobTheme.backgroundBase
                                          .withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (!_isLogin) _toggleAuthMode();
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              decoration: BoxDecoration(
                                                color: _isLogin
                                                    ? StoryJobTheme
                                                        .cardSurfaceElevated
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                                border: _isLogin
                                                    ? Border.all(
                                                        color: _roleAccent
                                                            .withValues(
                                                                alpha: 0.45),
                                                      )
                                                    : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Anmelden',
                                                style: TextStyle(
                                                  color: _isLogin
                                                      ? _roleAccent
                                                      : StoryJobTheme
                                                          .textSecondary,
                                                  fontWeight: _isLogin
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_isLogin) _toggleAuthMode();
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              decoration: BoxDecoration(
                                                color: !_isLogin
                                                    ? StoryJobTheme
                                                        .cardSurfaceElevated
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(11),
                                                border: !_isLogin
                                                    ? Border.all(
                                                        color: _roleAccent
                                                            .withValues(
                                                                alpha: 0.45),
                                                      )
                                                    : null,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Registrieren',
                                                style: TextStyle(
                                                  color: !_isLogin
                                                      ? _roleAccent
                                                      : StoryJobTheme
                                                          .textSecondary,
                                                  fontWeight: !_isLogin
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        if (!_isLogin) ...[
                                          _buildTextField(
                                            controller: _nameController,
                                            hintText: _isTeam
                                                ? 'Name des Teams / Vereins / Unternehmens'
                                                : 'Dein Vor- und Nachname',
                                            icon: _isTeam
                                                ? Icons.groups_outlined
                                                : Icons.person_outline_rounded,
                                            keyboardType: TextInputType.name,
                                            validator: (val) =>
                                                val != null &&
                                                        val.trim().isEmpty
                                                    ? 'Bitte Namen eingeben'
                                                    : null,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        _buildTextField(
                                          controller: _emailController,
                                          hintText: 'E-Mail Adresse',
                                          icon: Icons.email_outlined,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (val) =>
                                              val != null && !val.contains('@')
                                                  ? 'Gültige E-Mail eingeben'
                                                  : null,
                                        ),
                                        const SizedBox(height: 12),
                                        _buildTextField(
                                          controller: _passwordController,
                                          hintText: 'Passwort',
                                          icon: Icons.lock_outline_rounded,
                                          isPassword: true,
                                          validator: (val) =>
                                              val != null && val.length < 6
                                                  ? 'Mindestens 6 Zeichen'
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isLogin)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _resetPassword,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
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
                                          color:
                                              _roleAccent.withValues(alpha: 0.3),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _submitAuth,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: _isTeam
                                            ? Colors.white
                                            : StoryJobTheme.backgroundBase,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: _isTeam
                                                    ? Colors.white
                                                    : StoryJobTheme
                                                        .backgroundBase,
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : Text(
                                              _isLogin
                                                  ? (_isTeam
                                                      ? 'Als Team anmelden'
                                                      : 'StoryJob öffnen')
                                                  : (_isTeam
                                                      ? 'StoryTeam starten'
                                                      : 'StoryDNA erstellen'),
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: StoryJobTheme.cardBorder,
                              thickness: 1,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0),
                            child: Text(
                              'oder direkt fortfahren',
                              style: TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: StoryJobTheme.cardBorder,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: SignInWithAppleButton(
                                text: 'Apple',
                                onPressed:
                                    _isLoading ? () {} : _signInWithApple,
                                style: SignInWithAppleButtonStyle.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCustomSocialButton(
                              text: 'Google',
                              assetPath: 'assets/icons/google-color.svg',
                              onTap: _isLoading ? () {} : _signInWithGoogle,
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
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
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: StoryJobTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
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

  Widget _buildCustomSocialButton({
    required String text,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StoryJobTheme.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}