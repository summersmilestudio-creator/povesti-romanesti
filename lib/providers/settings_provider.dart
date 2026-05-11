import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _nightModeKey = 'night_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _voiceGenderKey = 'voice_gender';

  bool _nightMode = false;
  double _fontSize = 22.0;
  bool _loaded = false;
  String _voiceGender = 'feminin'; // 'masculin' sau 'feminin'

  bool get nightMode => _nightMode;
  double get fontSize => _fontSize;
  bool get loaded => _loaded;
  String get voiceGender => _voiceGender;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _nightMode = prefs.getBool(_nightModeKey) ?? false;
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 22.0;
    _voiceGender = prefs.getString(_voiceGenderKey) ?? 'feminin';
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleNightMode() async {
    _nightMode = !_nightMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nightModeKey, _nightMode);
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<void> setVoiceGender(String gender) async {
    _voiceGender = gender;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_voiceGenderKey, gender);
  }
}
