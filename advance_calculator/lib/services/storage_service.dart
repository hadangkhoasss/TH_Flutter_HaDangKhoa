import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';

class StorageService {
  static const _kHistory = 'history';
  static const _kTheme = 'theme';
  static const _kMemory = 'memory';
  static const _kMode = 'mode';
  static const _kAngle = 'angle';
  static const _kSettings = 'settings';

  Future<void> saveHistoryItem(CalculationHistory item, {int maxItems = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kHistory) ?? [];
    list.insert(0, jsonEncode(item.toJson()));
    if (list.length > maxItems) {
      list.removeRange(maxItems, list.length);
    }
    await prefs.setStringList(_kHistory, list);
  }

  Future<List<CalculationHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kHistory) ?? [];
    return list.map((s) => CalculationHistory.fromJson(jsonDecode(s))).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistory);
  }

  Future<void> saveMemory(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kMemory, value);
  }

  Future<double?> getMemory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kMemory);
  }

  Future<void> saveMode(CalculatorMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, mode.name);
  }

  Future<CalculatorMode?> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kMode);
    if (s == null) return null;
    switch (s) {
      case 'basic':
        return CalculatorMode.basic;
      case 'scientific':
        return CalculatorMode.scientific;
      case 'programmer':
        return CalculatorMode.programmer;
      default:
        return null;
    }
  }

  Future<void> saveAngleMode(String angle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAngle, angle);
  }

  Future<String?> getAngleMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAngle);
  }

  Future<void> saveThemeMode(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, theme);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTheme);
  }
}