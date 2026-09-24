import 'package:flutter/material.dart';
import '../../../core/theme/storyjob_theme.dart';
import '../../../core/services/app_services.dart';

class AuthScreen extends StatefulWidget {
  final String initialRole;
  const AuthScreen({super.key, this.initialRole = 'Talent'});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    if (isLogin) {
      await AppServices.loginUser(email, password);
    } else {
      await AppServices.registerUser(
        email: email,
        password: password,
        role: widget.initialRole,
        displayName: 'Peter Alt',
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StoryJob Anmeldung')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passwort'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: StoryJobTheme.cyanAccent)
                : ElevatedButton(
                    onPressed: _submitAuth,
                    child: Text(isLogin ? 'Anmelden' : 'Registrieren'),
                  ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Account erstellen' : 'Bereits registriert? Login'),
            ),
          ],
        ),
      ),
    );
  }
}