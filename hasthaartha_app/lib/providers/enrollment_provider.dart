import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/main.dart';
import 'package:hasthaartha_app/services/gesture_enrollment_service.dart';
import 'package:hasthaartha_app/localdb/repo/local_repo.dart';

final enrollmentServiceProvider =
    Provider.autoDispose<GestureEnrollmentService>((ref) {
  final ble = ref.read(blePipelineProvider);
  final onnx = ref.read(onnxServiceProvider);
  final repo = LocalRepo();

  final service = GestureEnrollmentService(
    bleService: ble,
    onnx: onnx,
    repo: repo,
  );

  ref.onDispose(service.dispose);

  return service;
});

final enrollmentStateProvider =
    StreamProvider.autoDispose((ref) async* {
  final service = ref.watch(enrollmentServiceProvider);

  // Emit initial state immediately
  yield service.currentState;

  // Then listen to updates
  yield* service.stateStream;
});