import 'package:shared_preferences/shared_preferences.dart';

class IntroPrefsService {
  static const String _hasSeenIntroKey = 'storyjob_has_seen_intro_v1';

  Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  Future<void> markIntroAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }

  /// Hilfsmethode für Tests, um den Erststart erneut zu simulieren.
  Future<void> resetIntroStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenIntroKey);
  }
}