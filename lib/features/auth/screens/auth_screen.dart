import 'package:flutter/material.dart';

import '../../../core/theme/storyjob_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
      _navigateToMainScreen();
    }
  }

  void _continueAsGuest() {
    _navigateToMainScreen();
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [Color(0xFF1D1438), StoryJobTheme.backgroundBase],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      size: 48,
                      color: StoryJobTheme.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'StoryJob',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: StoryJobTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Willkommen zurück! Anmelden zum Fortfahren.'
                        : 'Erstelle ein Konto, um deine Story zu starten.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: StoryJobTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: StoryJobTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'E-Mail',
                      hintStyle: const TextStyle(color: StoryJobTheme.textSecondary),
                      prefixIcon: const Icon(Icons.email_outlined, color: StoryJobTheme.cyanAccent),
                      filled: true,
                      fillColor: StoryJobTheme.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: StoryJobTheme.primaryViolet, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: StoryJobTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Passwort',
                      hintStyle: const TextStyle(color: StoryJobTheme.textSecondary),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: StoryJobTheme.cyanAccent),
                      filled: true,
                      fillColor: StoryJobTheme.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: StoryJobTheme.primaryViolet, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                      ),
                      onPressed: _isLoading ? null : _handleAuth,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Anmelden' : 'Registrieren',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Noch kein Konto? Jetzt registrieren'
                          : 'Bereits ein Konto? Jetzt anmelden',
                      style: const TextStyle(color: StoryJobTheme.cyanAccent),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: StoryJobTheme.cardBorder)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'oder',
                          style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: StoryJobTheme.cardBorder)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: StoryJobTheme.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _continueAsGuest,
                    icon: const Icon(Icons.person_outline_rounded, color: StoryJobTheme.textSecondary),
                    label: const Text(
                      'Als Gast ausprobieren',
                      style: TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Haupt-Navigation: Startet immer in der Mitte (Index 1 = Record / Voice Pitch)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Startet immer in der Mitte bei Index 1 (Record)
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    Center(child: Text('Feed / Matches', style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 18))),
    Center(child: Text('🎙️ Record / Voice Pitch (Mitte)', style: TextStyle(color: StoryJobTheme.cyanAccent, fontSize: 20, fontWeight: FontWeight.bold))),
    Center(child: Text('Profil / Einstellungen', style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: StoryJobTheme.cardSurface,
        selectedItemColor: StoryJobTheme.cyanAccent,
        unselectedItemColor: StoryJobTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.style_rounded), label: 'Matches'),
          BottomNavigationBarItem(icon: Icon(Icons.mic_rounded, size: 30), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}