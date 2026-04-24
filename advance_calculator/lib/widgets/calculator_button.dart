import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool highlight;
  final double flex;

  const CalculatorButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.highlight = false,
    this.flex = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight ? Theme.of(context).colorScheme.secondary.withOpacity(0.15) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );

    return Expanded(
      flex: (flex * 100).toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedScale(
            duration: Duration(milliseconds: 100),
            scale: 1.0,
            child: child,
          ),
        ),
      ),
    );
  }
}