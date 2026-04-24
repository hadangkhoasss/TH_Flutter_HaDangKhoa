import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/calculator_button.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';

class ButtonGrid extends StatelessWidget {
  const ButtonGrid({Key? key}) : super(key: key);

  Widget _buildBasic(BuildContext context) {
    final cp = context.read<CalculatorProvider>();
    final rows = [
      ['C', 'CE', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];
    return Column(
      children: rows.map((row) {
        return Row(
          children: row.map((label) {
            return CalculatorButton(
              label: label,
              highlight: RegExp(r'[÷×\-\+\=]').hasMatch(label),
              onTap: () {
                if (label == 'C') cp.clear();
                else if (label == 'CE') cp.deleteLast();
                else if (label == '=') cp.evaluate();
                else if (label == '±') {
                  if (cp.expression.startsWith('-')) cp.setExpression(cp.expression.substring(1));
                  else cp.setExpression('-' + cp.expression);
                } else if (label == '÷') cp.append('/');
                else if (label == '×') cp.append('*');
                else cp.append(label);
              },
              onLongPress: label == 'C' ? () => cp.clearAllHistory() : null,
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildScientific(BuildContext context) {
    final cp = context.read<CalculatorProvider>();
    final rows = [
      ['2nd', 'sin', 'cos', 'tan', 'Ln', 'log'],
      ['x²', '√', 'x^y', '(', ')', '÷'],
      ['MC', '7', '8', '9', 'C', '×'],
      ['MR', '4', '5', '6', 'CE', '-'],
      ['M+', '1', '2', '3', '%', '+'],
      ['M-', '±', '0', '.', 'π', '='],
    ];
    return Column(
      children: rows.map((row) {
        return Row(children: row.map((label) {
          return CalculatorButton(
            label: label,
            highlight: label == '=' || RegExp(r'^[\+\-\×\÷%]$').hasMatch(label),
            onTap: () {
              // handle some labels
              if (label == 'C') cp.clear();
              else if (label == '=') cp.evaluate();
              else if (label == 'π') cp.append('pi');
              else if (label == 'sin' || label == 'cos' || label == 'tan') cp.append('$label(');
              else if (label == 'x²') cp.append('^2');
              else if (label == 'x^y') cp.append('^');
              else if (label == '√') cp.append('sqrt(');
              else if (label == 'MC') cp.mc();
              else if (label == 'MR') cp.mr();
              else if (label == 'M+') cp.mPlus();
              else if (label == 'M-') cp.mMinus();
              else if (label == 'Ln') cp.append('ln(');
              else if (label == 'log') cp.append('log(');
              else if (label == 'CE') cp.deleteLast();
              else cp.append(label);
            },
          );
        }).toList());
      }).toList(),
    );
  }

  Widget _buildProgrammer(BuildContext context) {
    final cp = context.read<CalculatorProvider>();
    final rows = [
      ['BIN', 'OCT', 'DEC', 'HEX'],
      ['AND', 'OR', 'XOR', 'NOT'],
      ['<<', '>>', 'C', 'CE'],
      ['7', '8', '9', 'A'],
      ['4', '5', '6', 'B'],
      ['1', '2', '3', 'C'],
      ['±', '0', '.', '='],
    ];
    return Column(
      children: rows.map((row) {
        return Row(children: row.map((label) {
          return CalculatorButton(label: label, onTap: () {
            if (label == 'C') cp.clear();
            else if (label == 'CE') cp.deleteLast();
            else if (label == '=') cp.evaluate();
            else cp.append(label);
          });
        }).toList());
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<CalculatorProvider>().mode;
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: mode == CalculatorMode.basic
              ? _buildBasic(context)
              : mode == CalculatorMode.scientific
              ? _buildScientific(context)
              : _buildProgrammer(context),
        ),
      ),
    );
  }
}