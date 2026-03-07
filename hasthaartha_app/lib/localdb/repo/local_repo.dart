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

  // ================= SETTINGS =================

  Future<UserSettings> getSettings() async {
    final uid = _currentUid();

    final s = await _db.userSettings
        .filter()
        .userIdEqualTo(uid)
        .findFirst();

    if (s != null) return s;

    final fresh = UserSettings()
      ..userId = uid;

    await _db.writeTxn(() async => _db.userSettings.put(fresh));
    return fresh;
  }

  Future<void> updateSettings(UserSettings settings) async {
    settings.userId =
        settings.userId.isNotEmpty ? settings.userId : _currentUid();

    await _db.writeTxn(() async => _db.userSettings.put(settings));
  }

  // ================= HISTORY =================

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

  // ================= CUSTOM GESTURES =================

  /// Create empty gesture entry before enrollment
  Future<CustomGesture> createCustomGesture({
    required String label,
  }) async {
    final uid = _currentUid();

    final g = CustomGesture()
      ..userId = uid
      ..label = label
      ..createdAt = DateTime.now()
      ..sampleCount = 0
      ..prototype = [];

    await _db.writeTxn(() async => _db.customGestures.put(g));
    return g;
  }

  /// Save trained prototype after enrollment
  Future<void> saveGesturePrototype({
    required String label,
    required List<double> prototype,
    required int sampleCount,
  }) async {
    final uid = _currentUid();

    CustomGesture? existing = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .labelEqualTo(label)
        .findFirst();

    if (existing != null) {
      existing.prototype = prototype;
      existing.sampleCount = sampleCount;
      existing.createdAt = DateTime.now();

      await _db.writeTxn(() async => _db.customGestures.put(existing));
    } else {
      final g = CustomGesture()
        ..userId = uid
        ..label = label
        ..prototype = prototype
        ..sampleCount = sampleCount
        ..createdAt = DateTime.now();

      await _db.writeTxn(() async => _db.customGestures.put(g));
    }
  }

  /// Load prototypes for inference
  Future<Map<String, List<double>>> loadCustomPrototypes() async {
    final uid = _currentUid();

    final gestures = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .findAll();

    final map = <String, List<double>>{};

    for (var g in gestures) {
      if (g.prototype.isNotEmpty) {
        map[g.label] = g.prototype;
      }
    }

    return map;
  }

  /// List gestures (for UI)
  Future<List<CustomGesture>> listCustomGestures() async {
    final uid = _currentUid();

    return _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Delete gesture
  Future<void> deleteCustomGesture(Id id) async {
    await _db.writeTxn(() async => _db.customGestures.delete(id));
  }

  /// Delete by label
  Future<void> deleteGestureByLabel(String label) async {
    final uid = _currentUid();

    final g = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .labelEqualTo(label)
        .findFirst();

    if (g != null) {
      await _db.writeTxn(() async => _db.customGestures.delete(g.id));
    }
  }
}