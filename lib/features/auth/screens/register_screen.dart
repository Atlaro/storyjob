// lib/features/auth/screens/register_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glass_input.dart';
import 'package:storyjob/features/auth/screens/login_screen.dart';
import 'package:storyjob/features/talent/screens/talent_navigation_screen.dart';
import 'package:storyjob/features/recruiter/screens/recruiter_dashboard_screen.dart';

enum StoryUserRole { talent, company }

class RegisterScreen extends StatefulWidget {
  final StoryUserRole selectedRole;
  final String? initialRole;
  final Map<String, dynamic>? onboardingData;

  const RegisterScreen({
    super.key,
    this.selectedRole = StoryUserRole.talent,
    this.initialRole,
    this.onboardingData,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late StoryUserRole _activeRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.onboardingData?['email'] as String? ?? '';
    _emailController = TextEditingController(text: initialEmail);

    if (widget.initialRole != null) {
      _activeRole = (widget.initialRole == 'recruiter' || widget.initialRole == 'company')
          ? StoryUserRole.company
          : StoryUserRole.talent;
    } else {
      _activeRole = widget.selectedRole;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      setState(() => _errorMessage = 'Bitte stimme den Nutzungsbedingungen und Datenschutzrichtlinien zu.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Die Passwörter stimmen nicht überein.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = credential.user;
      if (user != null) {
        final String roleString = _activeRole == StoryUserRole.company ? 'company' : 'talent';

        final Map<String, dynamic> userData = {
          'uid': user.uid,
          'email': _emailController.text.trim(),
          'role': roleString,
          'fullName': widget.onboardingData?['firstName'] ??
              (_activeRole == StoryUserRole.company ? 'Neues Team' : 'Neues Profil'),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'acceptedTermsAt': FieldValue.serverTimestamp(),
          'dnaCompleteness': 35, // Start-Entfaltung der StoryJob DNA™
        };

        if (widget.onboardingData != null) {
          userData.addAll(widget.onboardingData!);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));

        if (!mounted) return;

        if (_activeRole == StoryUserRole.company) {
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
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'Diese E-Mail-Adresse wird bereits verwendet.';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Das Passwort muss mindestens 6 Zeichen lang sein.';
        } else {
          _errorMessage = e.message ?? 'Fehler bei der Registrierung.';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = 'Unerwarteter Fehler: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompany = _activeRole == StoryUserRole.company;
    final Color roleColor = isCompany ? StoryJobTheme.primaryViolet : StoryJobTheme.cyanAccent;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: GlowOrb(
              color: roleColor.withValues(alpha: 0.28),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: GlowOrb(
              color: (isCompany ? StoryJobTheme.cyanAccent : StoryJobTheme.primaryViolet).withValues(alpha: 0.22),
              size: 260,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Badge
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StoryJobTheme.cardSurfaceElevated,
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.45),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: roleColor.withValues(alpha: 0.18),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Icon(
                            isCompany ? Icons.hub_outlined : Icons.favorite_border_rounded,
                            size: 28,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        isCompany ? 'Macht eure Kultur erlebbar' : 'Starte deine Story',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isCompany
                            ? 'Begegnet Menschen auf echter Augenhöhe.'
                            : 'Kein Lebenslauf nötig. Zeig, wie du wirklich tickst.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: StoryJobTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 1. Rollenwahl: Menschliche Aussagen statt Recruiter-Begriffe
                      _buildRoleOptionCard(
                        isSelected: !isCompany,
                        title: 'Ich suche ein Umfeld, das zu mir passt.',
                        subtitle: 'Erzähle deine Story, mach deine Werte hörbar und finde Teams mit gleicher Wellenlänge.',
                        icon: Icons.favorite_border_rounded,
                        accentColor: StoryJobTheme.cyanAccent,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _activeRole = StoryUserRole.talent);
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildRoleOptionCard(
                        isSelected: isCompany,
                        title: 'Wir suchen Menschen, die unser Team bereichern.',
                        subtitle: 'Macht eure Arbeitskultur erlebbar und gewinnt Kolleginnen und Kollegen über Werte.',
                        icon: Icons.hub_outlined,
                        accentColor: StoryJobTheme.primaryViolet,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _activeRole = StoryUserRole.company);
                        },
                      ),
                      const SizedBox(height: 22),

                      // Fehlermeldung
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
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
                        const SizedBox(height: 16),
                      ],

                      // 2. Eingabemaske
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        borderRadius: 22,
                        child: Form(
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
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: StoryJobTheme.textSecondary,
                                    size: 19,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Mindestens 6 Zeichen erforderlich.'
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              GlassInput(
                                controller: _confirmPasswordController,
                                label: 'Passwort bestätigen',
                                hintText: 'Passwort wiederholen',
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _register(),
                                prefixIcon: Icons.lock_reset_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: StoryJobTheme.textSecondary,
                                    size: 19,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Bitte Passwort bestätigen.'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // DSGVO / AGB Checkbox
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  activeColor: roleColor,
                                  checkColor: StoryJobTheme.backgroundBase,
                                  side: const BorderSide(color: StoryJobTheme.cardBorder, width: 1.4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Ich akzeptiere die Nutzungsbedingungen und Datenschutzhinweise von StoryJob™.',
                                  style: TextStyle(
                                    color: StoryJobTheme.textSecondary,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // CTA-Pill Button
                      GlassButton(
                        label: isCompany ? 'Team-Profil eröffnen' : 'Story starten & verbinden',
                        isPrimaryGlow: true,
                        isLoading: _isLoading,
                        height: 52,
                        borderRadius: 26,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 18),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Bereits Teil von StoryJob?',
                            style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              'Einloggen',
                              style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 13.5),
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

  // Interaktive Rollen-Karte im Slate-Look
  Widget _buildRoleOptionCard({
    required bool isSelected,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : StoryJobTheme.cardSurfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor.withValues(alpha: 0.55) : StoryJobTheme.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? accentColor.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.05),
              ),
              child: Icon(
                icon,
                color: isSelected ? accentColor : StoryJobTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 2),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}