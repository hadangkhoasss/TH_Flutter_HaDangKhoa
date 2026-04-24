enum CalculatorMode { basic, scientific, programmer }

extension CalcModeExt on CalculatorMode {
  String get name {
    switch (this) {
      case CalculatorMode.basic:
        return 'basic';
      case CalculatorMode.scientific:
        return 'scientific';
      case CalculatorMode.programmer:
        return 'programmer';
    }
  }
}