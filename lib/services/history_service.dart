import 'package:hive/hive.dart';
import '../models/history_item.dart';

class HistoryService {
  final Box<HistoryItem> _historyBox = Hive.box<HistoryItem>('history');

  /// ✅ Adiciona item ao histórico
  Future<void> addToHistory(String imagePath, String description) async {
    final item = HistoryItem(
      imagePath: imagePath,
      description: description,
      timestamp: DateTime.now(),
    );
    await _historyBox.add(item);
  }

  /// ✅ Recupera todo o histórico
  Future<List<HistoryItem>> getHistory() async {
    return _historyBox.values.toList();
  }

  /// ✅ Deleta um item específico
  Future<void> deleteHistoryItem(HistoryItem item) async {
    await item.delete();
  }

  /// ✅ Limpa todo o histórico
  Future<void> clearHistory() async {
    await _historyBox.clear();
  }
}