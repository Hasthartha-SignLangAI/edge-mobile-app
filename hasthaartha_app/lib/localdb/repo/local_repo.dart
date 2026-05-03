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

    await _db.writeTxn(() async {

    // 1️⃣ Save new record
    await _db.historyRecords.put(rec);

    // 2️⃣ Cleanup old records
    final count = await _db.historyRecords.count();

    if (count > 200) {

      final old = await _db.historyRecords
          .where()
          .sortByCreatedAt()
          .limit(50)
          .findAll();

      await _db.historyRecords.deleteAll(
          old.map((e) => e.id).toList());
    }
  });
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

    final cleanLabel = label.trim().toLowerCase();

    CustomGesture? existing = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .labelEqualTo(cleanLabel)
        .findFirst();

    if (existing != null) {
      return existing;
    }

    final g = CustomGesture()
      ..userId = uid
      ..label = cleanLabel
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
    final cleanLabel = label.trim().toLowerCase();

    CustomGesture? existing = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .labelEqualTo(cleanLabel)
        .findFirst();

    if (existing != null) {
      existing.prototype = prototype;
      existing.sampleCount = sampleCount;
      existing.createdAt = DateTime.now();

      await _db.writeTxn(() async => _db.customGestures.put(existing));
    } else {
      final g = CustomGesture()
        ..userId = uid
        ..label = cleanLabel
        ..prototype = prototype
        ..sampleCount = sampleCount
        ..createdAt = DateTime.now();

      await _db.writeTxn(() async => _db.customGestures.put(g));
    }
  }

  /// Load prototypes for inference (used by OnnxService)
  Future<Map<String, List<double>>> loadCustomPrototypes() async {
    final uid = _currentUid();

    final gestures = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .findAll();

    final map = <String, List<double>>{};

    for (var g in gestures) {
      if (g.prototype.isNotEmpty) {
        map[g.label] = List<double>.from(g.prototype);
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

  /// Delete gesture by id
  Future<void> deleteCustomGesture(Id id) async {
    await _db.writeTxn(() async => _db.customGestures.delete(id));
  }

  /// Delete gesture by label
  Future<void> deleteGestureByLabel(String label) async {
    final uid = _currentUid();
    final cleanLabel = label.trim().toLowerCase();

    final g = await _db.customGestures
        .filter()
        .userIdEqualTo(uid)
        .labelEqualTo(cleanLabel)
        .findFirst();

    if (g != null) {
      await _db.writeTxn(() async => _db.customGestures.delete(g.id));
    }
  }

  /// Clear all user gestures
  Future<void> clearAllGestures() async {
    final uid = _currentUid();

    await _db.writeTxn(() async {
      final ids = await _db.customGestures
          .filter()
          .userIdEqualTo(uid)
          .idProperty()
          .findAll();

      if (ids.isNotEmpty) {
        await _db.customGestures.deleteAll(ids);
      }
    });
  }
}