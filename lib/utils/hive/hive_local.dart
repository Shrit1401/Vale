import 'package:hive_flutter/hive_flutter.dart';
import 'package:vale/utils/types/journal.dart';

class HiveLocal {
  static const String journalBoxName = 'journals';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(JournalAdapter());
  }

  static Future<Box<Journal>> _getBox() async {
    if (Hive.isBoxOpen(journalBoxName)) {
      return Hive.box<Journal>(journalBoxName);
    } else {
      return await Hive.openBox<Journal>(journalBoxName);
    }
  }

  // Journal operations
  static Future<void> saveJournal(Journal journal) async {
    final box = await _getBox();
    await box.put(journal.path, journal);
  }

  static Future<List<Journal>> getAllJournals() async {
    final box = await _getBox();
    return box.values.toList();
  }

  static Future<void> deleteJournal(String path) async {
    final box = await _getBox();
    await box.delete(path);
  }

  static Future<void> deleteAllJournals() async {
    final box = await _getBox();
    await box.clear();
  }
}
