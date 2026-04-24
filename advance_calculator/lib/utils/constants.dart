import 'package:flutter/material.dart';


///  COLOR SYSTEM (Light / Dark Themes)
class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF1E1E1E);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent = Color(0xFFFF6B6B);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent = Color(0xFF4ECDC4);
}

///  UI DIMENSIONS

class AppDimens {
  static const double buttonSpacing = 12.0;
  static const double buttonRadius = 16.0;
  static const double displayRadius = 24.0;
  static const double screenPadding = 24.0;

  static const Duration buttonAnimDuration = Duration(milliseconds: 200);
  static const Duration modeSwitchDuration = Duration(milliseconds: 300);
}
///  BUTTON LABELS (BASIC + SCIENTIFIC + PROGRAMMER)

class ButtonLabels {
  /// Basic Mode (4×5 grid)
  static const List<List<String>> basic = [
    ['C', 'CE', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  /// Scientific Mode (6×6 grid)
  static const List<List<String>> scientific = [
    ['2nd', 'sin', 'cos', 'tan', 'Ln', 'log'],
    ['x²', '√', 'x^y', '(', ')', '÷'],
    ['MC', '7', '8', '9', 'C', '×'],
    ['MR', '4', '5', '6', 'CE', '-'],
    ['M+', '1', '2', '3', '%', '+'],
    ['M-', '±', '0', '.', 'π', '='],
  ];

  /// Programmer Mode
  static const List<List<String>> programmer = [
    ['BIN', 'OCT', 'DEC', 'HEX'],
    ['AND', 'OR', 'XOR', 'NOT'],
    ['<<', '>>', 'C', 'CE'],
    ['7', '8', '9', 'A'],
    ['4', '5', '6', 'B'],
    ['1', '2', '3', 'C'],
    ['±', '0', '.', '='],
  ];
}

///  STRING CONSTANTS


class AppText {
  static const String appTitle = "Advanced Calculator";

  // Modes
  static const String basicMode = "Basic";
  static const String scientificMode = "Scientific";
  static const String programmerMode = "Programmer";

  // Angle Modes
  static const String deg = "DEG";
  static const String rad = "RAD";

  // History
  static const String historyTitle = "Calculation History";
  static const String noHistory = "No history available";
}

///  ANIMATION CONSTANTS


class AppAnimations {
  /// For error shake animation (slide or horizontal shake)
  static const Duration errorDuration = Duration(milliseconds: 350);

  /// Button press scale animation
  static const Duration pressScaleDuration = Duration(milliseconds: 150);
}


///  OTHER CONSTANTS

class AppConst {
  static const int defaultHistorySize = 50;
  static const int minDecimal = 2;
  static const int maxDecimal = 10;
}