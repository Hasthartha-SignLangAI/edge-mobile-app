import 'package:isar/isar.dart';

part 'history_record.g.dart';

@collection 
class HistoryRecord {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;

  late String gestureLabel;

  late String sinhalaText;

  late double confidence;

  String? deviceId;

  String? probsJson;
  
}