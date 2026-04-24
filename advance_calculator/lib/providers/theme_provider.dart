import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService storage;
  ThemeMode themeMode = ThemeMode.system;

  ThemeProvider(this.storage) {
    _load();
  }

  Future<void> _load() async {
    final s = await storage.getThemeMode();
    if (s == 'light') themeMode = ThemeMode.light;
    else if (s == 'dark') themeMode = ThemeMode.dark;
    else themeMode = ThemeMode.system;
    notifyListeners();
  }

  void setMode(String m) {
    if (m == 'light') themeMode = ThemeMode.light;
    else if (m == 'dark') themeMode = ThemeMode.dark;
    else themeMode = ThemeMode.system;
    storage.saveThemeMode(m);
    notifyListeners();
  }
}