import 'package:hive/hive.dart';
import 'package:vale/utils/types/journal.dart';

class JournalEmotionAdapter extends TypeAdapter<JournalEmotion> {
  @override
  final int typeId = 1;

  @override
  JournalEmotion read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return JournalEmotion.defaultEmotion;
      case 1:
        return JournalEmotion.happy;
      case 2:
        return JournalEmotion.sad;
      case 3:
        return JournalEmotion.angry;
      case 4:
        return JournalEmotion.anxious;
      case 5:
        return JournalEmotion.excited;
      case 6:
        return JournalEmotion.peaceful;
      default:
        return JournalEmotion.defaultEmotion;
    }
  }

  @override
  void write(BinaryWriter writer, JournalEmotion obj) {
    switch (obj) {
      case JournalEmotion.defaultEmotion:
        writer.writeByte(0);
        break;
      case JournalEmotion.happy:
        writer.writeByte(1);
        break;
      case JournalEmotion.sad:
        writer.writeByte(2);
        break;
      case JournalEmotion.angry:
        writer.writeByte(3);
        break;
      case JournalEmotion.anxious:
        writer.writeByte(4);
        break;
      case JournalEmotion.excited:
        writer.writeByte(5);
        break;
      case JournalEmotion.peaceful:
        writer.writeByte(6);
        break;
    }
  }
}
