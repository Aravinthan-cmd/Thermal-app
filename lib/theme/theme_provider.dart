import 'package:flutter/material.dart';
import 'package:thermal/theme/dark_mode.dart';
import 'package:thermal/theme/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get currentThemeData => _isDarkMode ? darkMode : lightMode;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeProvider() {
    // Initialize with the default system theme
    _isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  }
}