import 'package:shared_preferences/shared_preferences.dart';

class FirstRunService {
  static const _kSeenSplashKey = 'has_seen_splash_v1';

  Future<bool> hasSeenSplash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSeenSplashKey) ?? false;
  }

  Future<void> setSeenSplash() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSeenSplashKey, true);
  }
}
