import 'package:isar/isar.dart';

part 'custom_gesture.g.dart';

@collection
class CustomGesture {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index(unique: true, composite: [CompositeIndex('userId')])
  late String label;

  late List<double> prototype;

  late int sampleCount;

  late DateTime createdAt;
}