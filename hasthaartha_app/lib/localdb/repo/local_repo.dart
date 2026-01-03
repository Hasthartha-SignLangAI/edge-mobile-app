import 'package:isar/isar.dart';
import '../isar_db.dart';
import '../models/history_record.dart';
import '../models/user_settings.dart';
import '../models/custom_gesture.dart';

class LocalRepo {
  final Isar _db = IsarDB.instance;

  // SETTINGS
  Future<UserSettings> getSettings() async {
    final s = await _db.userSettings.get(1);
    if (s != null) return s;

    final fresh = UserSettings();
    await _db.writeTxn(() async => _db.userSettings.put(fresh));
    return fresh;
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _db.writeTxn(() async => _db.userSettings.put(settings));
  }

  // HISTORY
  Future<void> addHistory({
    required String gestureLabel,
    required String sinhalaText,
    required double confidence,
    String? deviceId,
    String? probsJson,
  }) async {
    final rec = HistoryRecord()
      ..createdAt = DateTime.now()
      ..gestureLabel = gestureLabel
      ..sinhalaText = sinhalaText
      ..confidence = confidence
      ..deviceId = deviceId
      ..probsJson = probsJson;

    await _db.writeTxn(() async => _db.historyRecords.put(rec));
  }

  Future<List<HistoryRecord>> latestHistory({int limit = 50}) async {
    return _db.historyRecords
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> clearHistory() async {
    await _db.writeTxn(() async => _db.historyRecords.clear());
  }

  // CUSTOM GESTURES
  Future<CustomGesture> createCustomGesture({
    required String name,
    required String samplesDir,
  }) async {
    final g = CustomGesture()
      ..name = name
      ..createdAt = DateTime.now()
      ..samplesDir = samplesDir
      ..sampleCount = 0
      ..isTrained = false;

    await _db.writeTxn(() async => _db.customGestures.put(g));
    return g;
  }

  Future<List<CustomGesture>> listCustomGestures() async {
    return _db.customGestures.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> updateCustomGesture(CustomGesture g) async {
    await _db.writeTxn(() async => _db.customGestures.put(g));
  }

  Future<void> deleteCustomGesture(Id id) async {
    await _db.writeTxn(() async => _db.customGestures.delete(id));
  }
}