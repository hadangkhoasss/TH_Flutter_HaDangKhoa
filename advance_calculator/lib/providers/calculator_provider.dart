import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/expression_parser.dart';
import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';

class CalculatorProvider extends ChangeNotifier {
  final StorageService storage;
  final ExpressionParser parser;

  String expression = '';
  String previousResult = '';
  String? errorMessage;
  double memory = 0.0;
  CalculatorMode mode = CalculatorMode.basic;
  String angleMode = 'DEG';
  double fontSize = 36;
  int decimalPrecision = 6;
  bool hapticEnabled = true;
  int historySize = 50;

  CalculatorProvider({required this.storage, required this.parser}) {
    _load();
  }

  Future<void> _load() async {
    final mem = await storage.getMemory();
    memory = mem ?? 0.0;
    final savedMode = await storage.getMode();
    if (savedMode != null) mode = savedMode;
    final ang = await storage.getAngleMode();
    if (ang != null) angleMode = ang;
    notifyListeners();
  }

  void append(String s) {
    errorMessage = null;
    expression += s;
    notifyListeners();
  }

  void setExpression(String s) {
    expression = s;
    notifyListeners();
  }

  void deleteLast() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
      notifyListeners();
    }
  }

  void clear() {
    expression = '';
    errorMessage = null;
    notifyListeners();
  }

  Future<void> evaluate() async {
    try {
      final val = parser.evaluate(expression, angleMode: angleMode);
      final formatted = _format(val);
      previousResult = formatted;
      // save to history
      await storage.saveHistoryItem(CalculationHistory(expression: expression, result: formatted, timestamp: DateTime.now()), maxItems: historySize);
      expression = formatted;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  String _format(double v) {
    // format with decimalPrecision, trim trailing zeros
    return v.toStringAsFixed(decimalPrecision).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  // Memory functions
  void mPlus() {
    final current = double.tryParse(previousResult) ?? double.tryParse(expression) ?? 0.0;
    memory += current;
    storage.saveMemory(memory);
    notifyListeners();
  }

  void mMinus() {
    final current = double.tryParse(previousResult) ?? double.tryParse(expression) ?? 0.0;
    memory -= current;
    storage.saveMemory(memory);
    notifyListeners();
  }

  void mr() {
    expression += memory.toString();
    notifyListeners();
  }

  void mc() {
    memory = 0.0;
    storage.saveMemory(memory);
    notifyListeners();
  }

  void switchMode(CalculatorMode m) {
    mode = m;
    storage.saveMode(m);
    notifyListeners();
  }

  void setAngleMode(String a) {
    angleMode = a;
    storage.saveAngleMode(a);
    notifyListeners();
  }

  void setDecimalPrecision(int p) {
    decimalPrecision = p;
    notifyListeners();
  }

  void setFontSize(double s) {
    fontSize = s.clamp(14.0, 56.0);
    notifyListeners();
  }

  Future<void> clearAllHistory() async {
    await storage.clearHistory();
    notifyListeners();
  }
}