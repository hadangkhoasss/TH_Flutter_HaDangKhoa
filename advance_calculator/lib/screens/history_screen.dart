import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HistoryProvider>();
    final cp = context.read<CalculatorProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: hp.items.isEmpty
          ? Center(child: Text('No history'))
          : ListView.builder(
          itemCount: hp.items.length,
          itemBuilder: (context, i) {
            final item = hp.items[i];
            return ListTile(
              title: Text(item.expression),
              subtitle: Text(item.result),
              trailing: Text('${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}'),
              onTap: () {
                cp.setExpression(item.expression);
                Navigator.pop(context);
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Clear history?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
              ],
            ),
          );
          if (ok == true) {
            await hp.clear();
          }
        },
      ),
    );
  }
}