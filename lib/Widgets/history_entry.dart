import 'package:hive/hive.dart';

part 'history_entry.g.dart';

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime date;

  HistoryEntry({
    required this.imagePath,
    required this.description,
    required this.date,
  });
}
 