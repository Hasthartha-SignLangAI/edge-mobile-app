import 'package:isar/isar.dart';

part 'custom_gesture.g.dart';

@collection
class CustomGesture {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late String name;          // user-defined gesture name
  late DateTime createdAt;

  /// Folder path where samples for this gesture are stored
  late String samplesDir;

  /// how many samples recorded (10–15)
  int sampleCount = 0;

  /// simple classifier for few-shot later
  bool isTrained = false;
}

