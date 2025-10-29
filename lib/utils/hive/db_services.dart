import 'package:hive_flutter/hive_flutter.dart';
import 'package:vale/utils/types/journal.dart';
import 'package:vale/utils/types/journal_emotion_adapter.dart';

class DatabaseService {
  static const String journalBoxName = 'journals';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(JournalEmotionAdapter());
    Hive.registerAdapter(JournalAdapter());
    await Hive.openBox<Journal>(journalBoxName);
  }

  //Journal Operations
  static Future<void> saveJournal(Journal journal) async {
    final box = await Hive.openBox<Journal>(journalBoxName);
    await box.put(journal.path, journal);
  }

  static Future<List<Journal>> getAllJournals() async {
    final box = await Hive.openBox<Journal>(journalBoxName);
    return box.values.toList();
  }

  static Future<void> deleteJournal(String path) async {
    final box = await Hive.openBox<Journal>(journalBoxName);
    await box.delete(path);
  }

  static Future<void> deleteAllJournals() async {
    final box = await Hive.openBox<Journal>(journalBoxName);
    await box.clear();
  }
}
