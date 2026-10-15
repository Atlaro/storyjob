// lib/features/auth/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/core/widgets/glass_input.dart';
import 'package:storyjob/features/auth/screens/register_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';
import 'package:storyjob/features/recruiter/screens/recruiter_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _routeUserByRole(User user) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    String role = 'talent';
    if (userDoc.exists && userDoc.data() != null) {
      role = userDoc.data()!['role'] as String? ?? 'talent';
    } else {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'fullName': user.displayName ?? 'StoryJob Talent',
        'role': 'talent',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (!mounted) return;

    if (role == 'company') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RecruiterDashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TalentNavigationScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (credential.user != null) {
        await _routeUserByRole(credential.user!);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            _errorMessage = 'E-Mail oder Passwort ist nicht korrekt.';
            break;
          case 'invalid-email':
            _errorMessage = 'Bitte gib eine gültige E-Mail-Adresse ein.';
            break;
          case 'user-disabled':
            _errorMessage = 'Dieses Konto wurde vorübergehend deaktiviert.';
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

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final googleProvider = GoogleAuthProvider();
      final userCredential =
          await FirebaseAuth.instance.signInWithProvider(googleProvider);

      if (userCredential.user != null) {
        await _routeUserByRole(userCredential.user!);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Google-Anmeldung fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final OAuthCredential oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      if (result.user != null) {
        await _routeUserByRole(result.user!);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Apple-Anmeldung fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _continueAsGuest() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TalentNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -50,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.28),
              size: 290,
            ),
          ),
          Positioned(
            bottom: -60,
            right: -50,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.20),
              size: 270,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: StoryJobTheme.cardSurfaceElevated,
                                border: Border.all(
                                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.40),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 28,
                                color: StoryJobTheme.cyanAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'Willkommen zurück',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              color: StoryJobTheme.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Deine Story. Echte Matches auf Augenhöhe.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: StoryJobTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),

                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          _buildSocialPillButton(
                            label: 'Mit Google fortfahren',
                            icon: const _GoogleGIcon(),
                            onTap: _isLoading ? null : _loginWithGoogle,
                          ),
                          const SizedBox(height: 12),
                          _buildSocialPillButton(
                            label: 'Mit Apple fortfahren',
                            icon: const Icon(Icons.apple_rounded, color: Colors.white, size: 21),
                            onTap: _isLoading ? null : _loginWithApple,
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              const Expanded(child: Divider(color: StoryJobTheme.cardBorder, height: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'oder mit E-Mail',
                                  style: TextStyle(
                                    color: StoryJobTheme.textSecondary.withValues(alpha: 0.7),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: StoryJobTheme.cardBorder, height: 1)),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                GlassInput(
                                  controller: _emailController,
                                  label: 'E-Mail-Adresse',
                                  hintText: 'name@beispiel.de',
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) => (v == null || !v.contains('@'))
                                      ? 'Gültige E-Mail erforderlich.'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                GlassInput(
                                  controller: _passwordController,
                                  label: 'Passwort',
                                  hintText: 'Mindestens 6 Zeichen',
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  prefixIcon: Icons.lock_outline_rounded,
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
                                  validator: (v) => (v == null || v.length < 6)
                                      ? 'Mindestens 6 Zeichen.'
                                      : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          GlassButton(
                            label: 'Einloggen',
                            isPrimaryGlow: true,
                            isLoading: _isLoading,
                            height: 52,
                            borderRadius: 26,
                            onPressed: _login,
                          ),

                          const SizedBox(height: 12),

                          GlassButton(
                            label: 'Als Gast erkunden',
                            isPrimaryGlow: false,
                            height: 48,
                            borderRadius: 24,
                            icon: Icons.explore_outlined,
                            onPressed: _isLoading ? () {} : _continueAsGuest,
                          ),

                          const SizedBox(height: 22),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Noch kein Konto?',
                                style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                  );
                                },
                                child: const Text(
                                  'Registrieren',
                                  style: TextStyle(
                                    color: StoryJobTheme.cyanAccent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialPillButton({
    required String label,
    required Widget icon,
    required VoidCallback? onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: StoryJobTheme.cardBorder, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 14.5,
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

class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFFEA4335),
          fontWeight: FontWeight.w900,
          fontSize: 18,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}