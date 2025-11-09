import 'package:flutter/material.dart';

enum ThemeItem { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeItem item) {
    switch (item) {
      case ThemeItem.light:
        _themeMode = ThemeMode.light;
        break;
      case ThemeItem.dark:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeItem.system:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
}
