import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';

class DisplayArea extends StatelessWidget {
  const DisplayArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalculatorProvider>();
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          cp.deleteLast();
        }
      },
      onScaleUpdate: (details) {
        if (details.scale != 1.0) cp.setFontSize(cp.fontSize * details.scale);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Opacity(opacity: 0.6, child: Text(cp.previousResult, style: TextStyle(fontSize: 14))),
            SizedBox(height: 8),
            SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Text(
                cp.expression.isEmpty ? '0' : cp.expression,
                style: TextStyle(fontSize: cp.fontSize, fontWeight: FontWeight.w500),
              ),
            ),
            if (cp.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(cp.errorMessage!, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}