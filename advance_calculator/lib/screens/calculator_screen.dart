import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../widgets/mode_selector.dart';
import '../providers/calculator_provider.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CalculatorProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Calculator'),
        actions: [
          IconButton(icon: Icon(Icons.history), onPressed: () => Navigator.pushNamed(context, '/history')),
          IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ModeSelector(),
              SizedBox(height: 12),
              DisplayArea(),
              SizedBox(height: 12),
              ButtonGrid(),
            ],
          ),
        ),
      ),
    );
  }
}