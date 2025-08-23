import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void setTheme(bool darkMode) {
    isDarkMode = darkMode;
    notifyListeners();
  }
}