import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/expression_parser.dart';

void main() {
  final parser = ExpressionParser();

  test('basic arithmetic', () {
    expect(parser.evaluate('5+3*2'), 11.0);
    expect(parser.evaluate('(5+3)*2 - 4/2'), 14.0);
  });

  test('scientific degrees', () {
    final v = parser.evaluate('sin(45)+cos(45)', angleMode: 'DEG');
    expect((v - 1.4142135).abs() < 1e-5, true);
  });

  test('pi and implicit mult', () {
    final v = parser.evaluate('2pi');
    expect((v - (2 * 3.141592653589793)).abs() < 1e-9, true);
  });

  test('factorial', () {
    expect(parser.evaluate('5!'), 120.0);
  });
}