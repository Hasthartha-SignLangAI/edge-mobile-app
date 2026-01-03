import 'package:isar/isar.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = 1; // single row

  double ttsSpeed = 1.0;
  double ttsPitch = 1.0;
  double ttsVolume = 1.0;

  bool darkMode = false;

  /// For BLE auto reconnect
  String? lastBleDeviceId;
  String? lastBleDeviceName;

  /// To later add Sinhala/English UI toggle
  String uiLanguage = "si"; // si/en
}