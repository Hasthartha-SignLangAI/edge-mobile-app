import 'package:isar/isar.dart';
import '../isar_db.dart';
import '../models/history_record.dart';
import '../models/user_settings.dart';
import '../models/custom_gesture.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocalRepo {
  final Isar _db = IsarDB.instance;

  String _currentUid() {
    return FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
  }

  // SETTINGS
  Future<UserSettings> getSettings() async {
    final uid = _currentUid();

    // If your UserSettings model doesn't have `userId`, keep using ID=1
    // But for multi-user, it's better to add `userId` to settings as well.
    final s = await _db.userSettings.filter().userIdEqualTo(uid).findFirst();
    if (s != null) return s;

    final fresh = UserSettings()
      ..userId = uid; // requires userId field in UserSettings model

    await _db.writeTxn(() async => _db.userSettings.put(fresh));
    return fresh;
  }

  Future<void> updateSettings(UserSettings settings) async {
    // ensure userId is always set (multi-user safety)
    settings.userId = settings.userId.isNotEmpty ? settings.userId : _currentUid();
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
    final uid = _currentUid();

    final rec = HistoryRecord()
      ..userId = uid
      ..createdAt = DateTime.now()
      ..gestureLabel = gestureLabel
      ..sinhalaText = sinhalaText
      ..confidence = confidence
      ..deviceId = deviceId
      ..probsJson = probsJson;

    await _db.writeTxn(() async => _db.historyRecords.put(rec));
  }

  Future<List<HistoryRecord>> latestHistory({int limit = 50}) async {
    final uid = _currentUid();

    return _db.historyRecords
        .where()
        .userIdEqualTo(uid)
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> clearHistory() async {
    final uid = _currentUid();

    await _db.writeTxn(() async {
      final ids = await _db.historyRecords
          .filter()
          .userIdEqualTo(uid)
          .idProperty()
          .findAll();

          if (ids.isNotEmpty) {
            await _db.historyRecords.deleteAll(ids);
          }
    });
  }

  // CUSTOM GESTURES
  Future<CustomGesture> createCustomGesture({
    required String name,
    required String samplesDir,
  }) async {
    final uid = _currentUid();

    final g = CustomGesture()
      ..userId = uid
      ..name = name
      ..createdAt = DateTime.now()
      ..samplesDir = samplesDir
      ..sampleCount = 0
      ..isTrained = false;

    await _db.writeTxn(() async => _db.customGestures.put(g));
    return g;
  }

  Future<List<CustomGesture>> listCustomGestures() async {
    final uid = _currentUid();

    return _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> updateCustomGesture(CustomGesture g) async {
    g.userId = g.userId.isNotEmpty ? g.userId : _currentUid();
    await _db.writeTxn(() async => _db.customGestures.put(g));
  }

  Future<void> deleteCustomGesture(Id id) async {
    await _db.writeTxn(() async => _db.customGestures.delete(id));
  }
}