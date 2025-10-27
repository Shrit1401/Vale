import 'package:hive/hive.dart';

part 'journal.g.dart';

@HiveType(typeId: 0)
class Journal {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final int durationInSeconds;

  const Journal({
    required this.title,
    required this.date,
    required this.durationInSeconds,
    required this.path,
  });
}
