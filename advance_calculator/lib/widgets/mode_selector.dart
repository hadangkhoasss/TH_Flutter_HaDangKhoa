import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_mode.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalculatorProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: Text('Basic'),
          selected: cp.mode == CalculatorMode.basic,
          onSelected: (_) => cp.switchMode(CalculatorMode.basic),
        ),
        SizedBox(width: 8),
        ChoiceChip(
          label: Text('Scientific'),
          selected: cp.mode == CalculatorMode.scientific,
          onSelected: (_) => cp.switchMode(CalculatorMode.scientific),
        ),
        SizedBox(width: 8),
        ChoiceChip(
          label: Text('Programmer'),
          selected: cp.mode == CalculatorMode.programmer,
          onSelected: (_) => cp.switchMode(CalculatorMode.programmer),
        ),
        SizedBox(width: 12),
        // angle indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.withOpacity(0.15)),
          child: Text(cp.angleMode),
        ),
        SizedBox(width: 8),
        if (cp.memory != 0.0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.orange.withOpacity(0.15)),
            child: Text('M'),
          ),
      ],
    );
  }
}