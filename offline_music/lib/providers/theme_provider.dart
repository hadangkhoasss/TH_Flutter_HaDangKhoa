import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // mặc định giống Spotify

  /// Lấy theme hiện tại
  ThemeMode get themeMode => _themeMode;

  /// Kiểm tra có đang Dark Mode không
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Bật / tắt Dark Mode
  void toggleTheme() {
    _themeMode =
        isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
