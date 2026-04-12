import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Mobile Calculator',
      // Use a primary background color for Scaffold to match the UI sample
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        fontFamily: 'Roboto',
        useMaterial3: false,
      ),
      home: const CalculatorScreen(),
    );
  }
}

// Define colors following the adjusted design sample
const Color kWhite = Color(0xFFFFFFFF);
const Color kDarkBackground = Color(0xFF1C1C1C); // Main background
const Color kNumberButton = Color(0xFF333333); // Number buttons
const Color kOperatorDarkGreen = Color(
  0xFF394734,
); // Operator buttons (÷, ×, -, +, %)
const Color kEqualButton = Color(0xFF326B38); // "=" button (darker green)
const Color kRed = Color(0xFF8B4747); // "C" button
const Color kLightGray = Color(0xFF5E5E5E); // "+/-" and "." buttons

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // State variables for managing calculations
  String _display = '0';
  String _equation = ''; // Pending expression
  double _num1 = 0;
  double _num2 = 0;
  String _operation = '';
  String _history = ''; // Last calculation history
  bool _isNewEntry = true;

  // --- CALCULATION LOGIC ---

  void _onNumberPressed(String value) {
    setState(() {
      if (_display == 'Error') _clearAll();

      if (_isNewEntry || _display == '0') {
        _display = value;
        _isNewEntry = false;
      } else {
        // Limit character count
        if (_display.length < 15) {
          _display += value;
        }
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_display == 'Error') _clearAll();

      if (_isNewEntry) {
        _display = '0.';
        _isNewEntry = false;
        return;
      }

      if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _clearAll() {
    setState(() {
      _display = '0';
      _equation = '';
      _history = '';
      _num1 = 0;
      _num2 = 0;
      _operation = '';
      _isNewEntry = true;
    });
  }

  // "()" button acts as Clear End (delete last character)
  void _clearEnd() {
    setState(() {
      if (_display == 'Error') {
        _clearAll();
        return;
      }

      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _isNewEntry = true;
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == 'Error' || _display == '0') return;

      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  void _onPercent() {
    setState(() {
      if (_display == 'Error') return;

      final value = double.tryParse(_display) ?? 0;
      final result = value / 100.0;
      _display = _formatNumber(result);
      _isNewEntry = true;
    });
  }

  void _onOperationPressed(String op) {
    setState(() {
      if (_display == 'Error') {
        _clearAll();
        return;
      }

      if (_operation.isNotEmpty && !_isNewEntry) {
        _calculate();
      } else {
        _num1 = double.tryParse(_display) ?? 0;
      }

      _operation = op;
      _equation = '${_formatNumber(_num1)} $op';
      _isNewEntry = true;
    });
  }

  void _calculate() {
    _num2 = double.tryParse(_display) ?? 0;

    double? result;
    try {
      switch (_operation) {
        case '+':
          result = _num1 + _num2;
          break;
        case '-':
          result = _num1 - _num2;
          break;
        case '×':
          result = _num1 * _num2;
          break;
        case '÷':
          if (_num2 == 0) {
            // Handle division by zero
            _display = 'Error';
            _history = '${_formatNumber(_num1)} ÷ 0 =';
            _equation = '';
            _operation = '';
            _isNewEntry = true;
            return;
          } else {
            result = _num1 / _num2;
          }
          break;
        default:
          result = _num2;
      }

      // Update history and result
      _history =
      '${_formatNumber(_num1)} $_operation ${_formatNumber(_num2)} =';
      _num1 = result;
      _display = _formatNumber(result);
      _equation = '';
      _operation = '';
      _isNewEntry = true;
    } catch (e) {
      _display = 'Error';
      _equation = '';
      _operation = '';
      _isNewEntry = true;
    }
  }

  void _onEqualsPressed() {
    setState(() {
      if (_display == 'Error') return;
      if (_operation.isEmpty) {
        _history = '${_formatNumber(double.tryParse(_display) ?? 0)} =';
        _isNewEntry = true;
        return;
      }
      _calculate();
    });
  }

  String _formatNumber(double value) {
    String text = value.toStringAsFixed(10);
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');

    if (text.length > 15 || value.abs() >= 1e15) {
      return value.toStringAsExponential(5);
    }
    return text;
  }

  // Main handler for all button taps
  void _onButtonTap(String label) {
    switch (label) {
      case 'C':
        _clearAll();
        break;
    // "()" triggers clear last character
      case 'CE':
        _clearEnd();
        break;
      case '%':
        _onPercent();
        break;
      case '÷':
      case '×':
      case '-':
      case '+':
        _onOperationPressed(label);
        break;
      case '=':
        _onEqualsPressed();
        break;
      case '+/-':
        _toggleSign();
        break;
      case '.':
        _onDecimalPressed();
        break;
      default:
        _onNumberPressed(label);
    }
  }

  // --- UI PART OF THE STATEFUL WIDGET ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Display area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: kDarkBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // History / pending expression
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        _equation.isEmpty ? _history : _equation,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 22, color: kWhite),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Current display number
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 48,
                          color: kWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Button area
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                color: kDarkBackground,
                child: Column(
                  children: [
                    _buildButtonRow(['C', 'CE', '%', '÷']),
                    _buildButtonRow(['7', '8', '9', '×']),
                    _buildButtonRow(['4', '5', '6', '-']),
                    _buildButtonRow(['1', '2', '3', '+']),
                    _buildButtonRow(['+/-', '0', '.', '=']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Returns a Row widget containing calculator buttons
  Widget _buildButtonRow(List<String> labels) {
    return Expanded(
      child: Row(
        children: labels
            .map(
              (label) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: AspectRatio(
                aspectRatio: 1,
                child: CalculatorButton(
                  label: label,
                  backgroundColor: _getButtonColor(label),
                  textColor: kWhite,
                  onTap: () => _onButtonTap(label),
                ),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  // Returns button background color based on label
  Color _getButtonColor(String label) {
    if (label == 'C') return kRed;
    if (label == '=') return kEqualButton;

    // Operators
    if (label == '÷' ||
        label == '×' ||
        label == '-' ||
        label == '+' ||
        label == '%') {
      return kOperatorDarkGreen;
    }

    // Special functions (same style as number buttons)
    if (label == '+/-' || label == '.' || label == '()') return kLightGray;

    // Number buttons
    return kNumberButton;
  }
}

// Calculator button widget (updated to display '()' instead of '⌫')
class CalculatorButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            // Display the original label (such as '()')
            label,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}