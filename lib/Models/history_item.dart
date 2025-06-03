import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  late String imagePath;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late DateTime timestamp;

  HistoryItem({
    required this.imagePath,
    required this.description,
    required this.timestamp,
  });
}