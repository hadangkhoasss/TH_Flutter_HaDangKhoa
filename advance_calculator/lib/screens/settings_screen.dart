import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/calculator_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final calc = context.watch<CalculatorProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('Theme'),
            subtitle: Text(theme.themeMode.toString().split('.').last),
            trailing: DropdownButton<String>(
              value: theme.themeMode == ThemeMode.system
                  ? 'system'
                  : (theme.themeMode == ThemeMode.light ? 'light' : 'dark'),
              items: ['system', 'light', 'dark']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => theme.setMode(v ?? 'system'),
            ),
          ),
          ListTile(
            title: Text('Angle mode'),
            trailing: DropdownButton<String>(
              value: calc.angleMode,
              items: ['DEG', 'RAD'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => calc.setAngleMode(v ?? 'DEG'),
            ),
          ),
          ListTile(
            title: Text('Decimal Precision'),
            subtitle: Slider(
              min: 2,
              max: 10,
              divisions: 8,
              value: calc.decimalPrecision.toDouble(),
              onChanged: (v) => calc.setDecimalPrecision(v.toInt()),
            ),
            trailing: Text('${calc.decimalPrecision}'),
          ),
          SwitchListTile(
            title: Text('Haptic Feedback'),
            value: calc.hapticEnabled,
            onChanged: (v) => calc.hapticEnabled = v,
          ),
          ListTile(
            title: Text('History Size'),
            trailing: DropdownButton<int>(
              value: calc.historySize,
              items: [25, 50, 100].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (v) {
                if (v != null) calc.historySize = v;
              },
            ),
          ),
          ElevatedButton(
            child: Text('Clear All History'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Confirm'),
                  content: Text('Clear all history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
                  ],
                ),
              );
              if (ok == true) {
                await calc.clearAllHistory();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('History cleared')));
              }
            },
          ),
        ],
      ),
    );
  }
}