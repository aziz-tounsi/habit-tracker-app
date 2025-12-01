import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _accentKey = 'accentColorIndex';
  
  bool _isDarkMode = true;
  int _accentColorIndex = 0;
  
  bool get isDarkMode => _isDarkMode;
  int get accentColorIndex => _accentColorIndex;
  
  ThemeData get theme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  
  Color get accentColor => AppColors.habitColors[_accentColorIndex % AppColors.habitColors.length];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    _accentColorIndex = prefs.getInt(_accentKey) ?? 0;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setAccentColor(int index) async {
    _accentColorIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, _accentColorIndex);
    notifyListeners();
  }
}
