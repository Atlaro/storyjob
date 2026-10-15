// lib/features/profile/screens/personal_data_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _handleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _taglineController;

  bool _isLoading = true;
  bool _isSaving = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;
  String get _uid => _currentUser?.uid ?? 'guest_user';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _handleController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _taglineController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nameController.text = data['displayName'] ?? data['fullName'] ?? data['name'] ?? _currentUser?.displayName ?? 'Peter Alt';
        _handleController.text = data['handle']?.toString().replaceAll('@', '') ?? 'peteralt';
        _emailController.text = data['email'] ?? _currentUser?.email ?? 'peter.alt@storyjob.de';
        _phoneController.text = data['phone'] ?? '';
        _locationController.text = data['location'] ?? 'Niederbayern';
        _taglineController.text = data['bio'] ?? data['tagline'] ?? 'Hands-on Macher mit Fokus auf Menschlichkeit, Eigenverantwortung & moderne Teamkultur.';
      } else {
        _nameController.text = _currentUser?.displayName ?? 'Peter Alt';
        _handleController.text = 'peteralt';
        _emailController.text = _currentUser?.email ?? 'peter.alt@storyjob.de';
        _locationController.text = 'Niederbayern';
        _taglineController.text = 'Hands-on Macher mit Fokus auf Menschlichkeit, Eigenverantwortung & moderne Teamkultur.';
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Profildaten: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedName = _nameController.text.trim();
      final updatedHandle = _handleController.text.trim().toLowerCase().replaceAll('@', '');
      final updatedTagline = _taglineController.text.trim();
      final updatedLocation = _locationController.text.trim();

      final batch = FirebaseFirestore.instance.batch();

      // 1. User Profil updaten
      final userRef = FirebaseFirestore.instance.collection('users').doc(_uid);
      batch.set(userRef, {
        'displayName': updatedName,
        'fullName': updatedName,
        'name': updatedName,
        'handle': '@$updatedHandle',
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': updatedLocation,
        'bio': updatedTagline,
        'tagline': updatedTagline,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. StoryJob DNA Synchronisation
      final identityRef = FirebaseFirestore.instance.collection('user_identities').doc(_uid);
      batch.set(identityRef, {
        'displayName': updatedName,
        'tagline': updatedTagline,
        'location': updatedLocation,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      if (_currentUser != null && _currentUser!.displayName != updatedName) {
        await _currentUser!.updateDisplayName(updatedName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Profilangaben erfolgreich aktualisiert ✨',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: StoryJobTheme.textPrimary),
            ),
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: StoryJobTheme.cardBorder),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = StoryJobTheme.champagneGold;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Persönliche Angaben',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveUserData,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: accentColor),
                  )
                : const Text(
                    'Speichern',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 40.0),
                  children: [
                    const Text(
                      'Diese Angaben bilden dein Werteprofil und die Basis für echte Resonanz-Treffer mit passenden Teams.',
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Gruppe 1: Profil & Sichtbarkeit
                    _buildSectionLabel('Profil & Sichtbarkeit'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFormField(
                            controller: _nameController,
                            label: 'Name',
                            icon: Icons.person_outline_rounded,
                            hint: 'z. B. Peter Alt',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name erforderlich' : null,
                          ),
                          _buildDivider(),
                          _buildFormField(
                            controller: _handleController,
                            label: 'Handle',
                            icon: Icons.alternate_email_rounded,
                            hint: 'peteralt',
                            prefixText: '@',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Handle erforderlich' : null,
                          ),
                          _buildDivider(),
                          _buildFormField(
                            controller: _taglineController,
                            label: 'Fokus & Haltung',
                            icon: Icons.short_text_rounded,
                            hint: 'Kurze Beschreibung deiner Werte',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gruppe 2: Kontakt & Region
                    _buildSectionLabel('Kontakt & Region'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cardSurfaceElevated,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: StoryJobTheme.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFormField(
                            controller: _emailController,
                            label: 'E-Mail',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@')) ? 'Gültige E-Mail erforderlich' : null,
                          ),
                          _buildDivider(),
                          _buildFormField(
                            controller: _phoneController,
                            label: 'Telefon (opt.)',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            hint: '+49 170 ...',
                          ),
                          _buildDivider(),
                          _buildFormField(
                            controller: _locationController,
                            label: 'Standort',
                            icon: Icons.location_on_outlined,
                            hint: 'z. B. Niederbayern / Remote',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoryJobTheme.primaryViolet,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          _isSaving ? 'Wird gespeichert...' : 'Änderungen übernehmen ✨',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: StoryJobTheme.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 8.0 : 0.0),
            child: Icon(icon, color: StoryJobTheme.textSecondary, size: 19),
          ),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 8.0 : 0.0),
            child: SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              maxLines: maxLines,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                prefixText: prefixText,
                prefixStyle: TextStyle(
                  color: StoryJobTheme.champagneGold.withValues(alpha: 0.9),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: const TextStyle(color: StoryJobTheme.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
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