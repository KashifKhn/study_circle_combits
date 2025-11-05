import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_circle/utils/logger.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  // Initialize theme from shared preferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        AppLogger.info('Theme loaded: $savedTheme');
      } else {
        _themeMode = ThemeMode.light;
        AppLogger.info('No saved theme, using light mode');
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load theme', e, stackTrace);
      _themeMode = ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
    notifyListeners();
    AppLogger.info('Theme toggled to: ${_themeMode == ThemeMode.dark ? "dark" : "light"}');
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _saveTheme();
    notifyListeners();
    AppLogger.info('Theme set to: ${mode == ThemeMode.dark ? "dark" : "light"}');
  }

  // Save theme to shared preferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save theme', e, stackTrace);
    }
  }
}
