import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';
import 'package:hasthaartha_app/localdb/models/custom_gesture.dart';

final customGesturesProvider =
    FutureProvider<List<CustomGesture>>((ref) async {
  final repo = LocalRepo();
  return repo.listCustomGestures();
});