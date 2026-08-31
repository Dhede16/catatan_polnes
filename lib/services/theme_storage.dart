import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const String _themeKey = 'app_theme_mode';

  final SharedPreferences? _prefs;

  ThemeStorage([this._prefs]);

  Future<SharedPreferences> get _instance async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await _instance;
    final String? themeStr = prefs.getString(_themeKey);

    if (themeStr == 'dark') {
      return ThemeMode.dark;
    } else if (themeStr == 'light') {
      return ThemeMode.light;
    }
    return ThemeMode.system;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _instance;
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, modeString);
  }

  Future<void> clearThemeMode() async {
    final prefs = await _instance;
    await prefs.remove(_themeKey);
  }
}
