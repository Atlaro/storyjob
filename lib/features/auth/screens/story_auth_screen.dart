// lib/features/auth/screens/story_auth_screen.dart
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/features/auth/screens/login_screen.dart';
import 'package:storyjob/features/auth/screens/register_screen.dart';
import 'package:storyjob/features/recruiter/screens/recruiter_dashboard_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';

class StoryAuthScreen extends StatefulWidget {
  const StoryAuthScreen({super.key});

  @override
  State<StoryAuthScreen> createState() => _StoryAuthScreenState();
}

class _StoryAuthScreenState extends State<StoryAuthScreen> {
  String _selectedRole = 'talent';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _routeUserByRole(User user, {String? forcedRole}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    String role = forcedRole ?? _selectedRole;

    if (userDoc.exists && userDoc.data() != null) {
      role = userDoc.data()!['role'] as String? ?? role;
    } else {
      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'fullName': user.displayName ?? (role == 'recruiter' ? 'Neues Team' : 'Neues Talent'),
        'role': role,
        'isAnonymous': user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (!mounted) return;

    if (role == 'company' || role == 'recruiter') {
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

  // 1. Gast-Zugang
  Future<void> _continueAsGuest() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      if (credential.user != null) {
        await _routeUserByRole(credential.user!, forcedRole: _selectedRole);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Gast-Zugang aktuell nicht möglich: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Google-Authentifizierung
  Future<void> _signInWithGoogle() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final credential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        if (credential.user != null) {
          await _routeUserByRole(credential.user!);
        }
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final result = await FirebaseAuth.instance.signInWithCredential(credential);
        if (result.user != null) {
          await _routeUserByRole(result.user!);
        }
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (!err.contains('canceled') && !err.contains('aborted') && !err.contains('popup_closed')) {
        setState(() => _errorMessage = 'Google-Anmeldung fehlgeschlagen.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. Apple-Authentifizierung
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<void> _signInWithApple() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        final AppleAuthProvider appleProvider = AppleAuthProvider();
        final credential = await FirebaseAuth.instance.signInWithPopup(appleProvider);
        if (credential.user != null) {
          await _routeUserByRole(credential.user!);
        }
      } else {
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: nonce,
        );

        final OAuthCredential credential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        final result = await FirebaseAuth.instance.signInWithCredential(credential);
        if (result.user != null) {
          await _routeUserByRole(result.user!);
        }
      }
    } catch (e) {
      final err = e.toString().toLowerCase();
      if (!err.contains('canceled') && !err.contains('cancelled') && !err.contains('1001')) {
        setState(() => _errorMessage = 'Apple-Anmeldung fehlgeschlagen.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A12),
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -50,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.32),
              size: 340,
            ),
          ),
          Positioned(
            bottom: -70,
            right: -50,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.22),
              size: 320,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 24),

                      _buildRoleToggle(),

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
                        const SizedBox(height: 20),
                      ],

                      _buildPillButton(
                        label: 'Mit E-Mail registrieren',
                        backgroundColor: StoryJobTheme.cyanAccent,
                        textColor: const Color(0xFF070A12),
                        isGlow: true,
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(
                                      initialRole: _selectedRole,
                                    ),
                                  ),
                                );
                              },
                      ),

                      const SizedBox(height: 12),

                      _buildPillButton(
                        label: 'Weiter mit Apple',
                        icon: const Icon(Icons.apple_rounded, color: Colors.white, size: 23),
                        backgroundColor: StoryJobTheme.cardSurfaceElevated,
                        textColor: Colors.white,
                        hasBorder: true,
                        onTap: _isLoading ? null : _signInWithApple,
                      ),

                      const SizedBox(height: 12),

                      _buildPillButton(
                        label: 'Weiter mit Google',
                        customIcon: const _GoogleGIcon(),
                        backgroundColor: StoryJobTheme.cardSurfaceElevated,
                        textColor: Colors.white,
                        hasBorder: true,
                        onTap: _isLoading ? null : _signInWithGoogle,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Expanded(child: Divider(color: StoryJobTheme.cardBorder, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'oder',
                              style: TextStyle(
                                color: StoryJobTheme.textSecondary.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: StoryJobTheme.cardBorder, height: 1)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _isLoading ? null : _continueAsGuest,
                        child: Text(
                          _selectedRole == 'recruiter' ? 'Als Gast-Betrieb umsehen' : 'Als Gast fortfahren',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.cyanAccent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Du bist bereits registriert? ',
                            style: TextStyle(fontSize: 13.5, color: StoryJobTheme.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Anmelden',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: StoryJobTheme.cyanAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Durch die Nutzung von StoryJob stimmst du den Nutzungsbedingungen und der Datenschutzerklärung zu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: StoryJobTheme.textSecondary.withValues(alpha: 0.65),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // StoryJob-Banner im Querformat mit nahtlosem Hintergrund
        Image.asset(
          'assets/images/storyjob_banner.jpg',
          width: 250,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/storyjob_banner.png',
            width: 250,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/branding_onboarding.png',
              width: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Konto erstellen, um fortzufahren',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: StoryJobTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StoryJobTheme.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleTab(
              title: 'Mensch & Talent',
              icon: Icons.person_outline_rounded,
              isSelected: _selectedRole == 'talent',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRole = 'talent');
              },
            ),
          ),
          Expanded(
            child: _buildRoleTab(
              title: 'Betrieb & Verein',
              icon: Icons.business_outlined,
              isSelected: _selectedRole == 'recruiter',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedRole = 'recruiter');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? StoryJobTheme.primaryViolet : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : StoryJobTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : StoryJobTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    Widget? icon,
    Widget? customIcon,
    required Color backgroundColor,
    required Color textColor,
    bool isGlow = false,
    bool hasBorder = false,
    required VoidCallback? onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: hasBorder ? Border.all(color: StoryJobTheme.cardBorder, width: 1.0) : null,
        boxShadow: isGlow
            ? [
                BoxShadow(
                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) icon,
              if (customIcon != null) customIcon,
              if (icon != null || customIcon != null) const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFFEA4335),
          fontWeight: FontWeight.w900,
          fontSize: 17,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}