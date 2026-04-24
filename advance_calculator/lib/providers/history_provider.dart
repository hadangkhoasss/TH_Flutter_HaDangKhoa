import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/calculation_history.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService storage;
  List<CalculationHistory> items = [];

  HistoryProvider(this.storage) {
    load();
  }

  Future<void> load() async {
    items = await storage.getHistory();
    notifyListeners();
  }

  Future<void> add(CalculationHistory item) async {
    await storage.saveHistoryItem(item);
    await load();
  }

  Future<void> clear() async {
    await storage.clearHistory();
    await load();
  }
}