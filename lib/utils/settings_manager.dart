import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const _soundKey        = 'sound_enabled';
  static const _timerKey        = 'timer_duration';
  static const _cardBackKey     = 'card_back';
  static const _playerNameKey   = 'player_name';

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  static Future<int> getTimerDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_timerKey) ?? 5;
  }

  static Future<void> setTimerDuration(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timerKey, value);
  }

  static Future<String> getCardBack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cardBackKey) ?? 'back-blue';
  }

  static Future<void> setCardBack(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cardBackKey, value);
  }

  static Future<String> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerNameKey) ?? 'Player';
  }

  static Future<void> setPlayerName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, value);
  }
}