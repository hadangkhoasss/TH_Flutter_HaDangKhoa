import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class ExpressionParser {
  final Parser _parser = Parser();

  double evaluate(String expression, {String angleMode = 'DEG'}) {
    String s = _preprocess(expression);

    // handle degree to radian conversion for sin/cos/tan calls
    if (angleMode == 'DEG') {
      s = _convertTrigDegrees(s);
    }

    // parse and evaluate
    Expression exp = _parser.parse(s);
    ContextModel cm = ContextModel();

    // constants
    cm.bindVariableName('pi', Number(math.pi));
    cm.bindVariableName('e', Number(math.e));


    s = _replaceFactWithNumber(s);

    exp = _parser.parse(s);
    final result = exp.evaluate(EvaluationType.REAL, cm);
    if (result is num) {
      return result.toDouble();
    } else {
      throw Exception('Evaluation returned non-numeric');
    }
  }

  String _preprocess(String s) {
    s = s.replaceAll('×', '*').replaceAll('÷', '/');
    s = s.replaceAll('π', 'pi').replaceAll('PI', 'pi');
    s = s.replaceAll('e', 'e'); // leave e

    // Replace unicode minus with -
    s = s.replaceAll('−', '-');

    // implicit multiplication: digit or ) followed by ( or pi or e or variable
    s = s.replaceAllMapped(RegExp(r'(\d|\))(\()'), (m) => '${m[1]}*${m[2]}');
    s = s.replaceAllMapped(RegExp(r'(\d)(pi|e)'), (m) => '${m[1]}*${m[2]}');
    s = s.replaceAllMapped(RegExp(r'(pi|e)(\d|\()'), (m) => '${m[1]}*${m[2]}');

    // simple factorial: convert "5!" -> "fact(5)"
    s = s.replaceAllMapped(RegExp(r'(\d+)!'), (m) => 'fact(${m[1]})');

    return s;
  }

  String _convertTrigDegrees(String s) {
    // naive replacement: sin(x) -> sin(x*pi/180)
    // works for sin(NUM) or sin(expression) patterns.
    s = s.replaceAllMapped(RegExp(r'sin\(([^()]+)\)'), (m) => 'sin((${m[1]})*pi/180)');
    s = s.replaceAllMapped(RegExp(r'cos\(([^()]+)\)'), (m) => 'cos((${m[1]})*pi/180)');
    s = s.replaceAllMapped(RegExp(r'tan\(([^()]+)\)'), (m) => 'tan((${m[1]})*pi/180)');
    return s;
  }

  String _replaceFactWithNumber(String s) {
    return s.replaceAllMapped(RegExp(r'fact\((\d+)\)'), (m) {
      final n = int.parse(m[1]!);
      final val = _fact(n);
      return val.toString();
    });
  }

  int _fact(int n) {
    if (n < 0) throw Exception('factorial negative');
    int r = 1;
    for (var i = 1; i <= n; i++) r *= i;
    return r;
  }
}