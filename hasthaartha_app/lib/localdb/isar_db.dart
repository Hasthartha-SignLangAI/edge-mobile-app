import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/history_record.dart';
import 'models/user_settings.dart';
import 'models/custom_gesture.dart';

class IsarDB {
  static Isar? _isar;

  static Future<Isar> open() async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [HistoryRecordSchema, UserSettingsSchema, CustomGestureSchema],
      directory: dir.path,
      inspector: true, // can turn off in production 
    );
    return _isar!;
  }

  static Isar get instance {
    final db = _isar;
    if (db == null) {
      throw StateError("IsarDB not opened. Call IsarDB.open() first.");
    }
    return db;
  }
}
