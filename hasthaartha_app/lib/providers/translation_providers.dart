import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:hasthaartha_app/main.dart'; // for blePipelineProvider
import 'package:hasthaartha_app/models/gesture_data.dart';
import 'package:hasthaartha_app/models/translation_state.dart';

/// ============================================================
/// ✅ BLE connection state (NOW REAL - comes from BlePipelineService)
/// ============================================================
/// This provider listens to BlePipelineService.connectionStream and converts it
/// into your existing BLEConnectionState model.
///
/// NOTE:
/// - signalStrength is not available from the stream directly.
///   (If you want RSSI, we can add a periodic readRssi() in BlePipelineService.)
final bleConnectionProvider = StreamProvider<BLEConnectionState>((ref) async* {
  final ble = ref.watch(blePipelineProvider);

  yield ble.device != null
      ? BLEConnectionState.connected(
          ble.device!.platformName.isNotEmpty
              ? ble.device!.platformName
              : ble.device!.remoteId.str,
          0,
        )
      : BLEConnectionState.disconnected();

  await for (final state in ble.connectionStream) {
    if (state == BluetoothConnectionState.connected &&
        ble.device != null) {
      yield BLEConnectionState.connected(
        ble.device!.platformName.isNotEmpty
            ? ble.device!.platformName
            : ble.device!.remoteId.str,
        0,
      );
    } else {
      yield BLEConnectionState.disconnected();
    }
  }
});

/// ============================================================
/// Translation screen state
/// ============================================================
final translationStateProvider =
    StateNotifierProvider<TranslationStateNotifier, TranslationState>((ref) {
  return TranslationStateNotifier();
});

class TranslationStateNotifier extends StateNotifier<TranslationState> {
  TranslationStateNotifier() : super(TranslationState.initial());

  void startTranslation() {
    state = state.copyWith(status: TranslationStatus.active);
  }

  void stopTranslation() {
    state = state.copyWith(status: TranslationStatus.idle);
  }

  void setProcessing() {
    state = state.copyWith(status: TranslationStatus.processing);
  }

  void setError(String message) {
    state = TranslationState.error(message);
  }

  void toggleDebugMode() {
    state = state.copyWith(isDebugMode: !state.isDebugMode);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void reset() {
    state = TranslationState.initial();
  }
}

/// ============================================================
/// Current gesture (updated by prediction stream)
/// ============================================================
final currentGestureProvider =
    StateNotifierProvider<CurrentGestureNotifier, GestureData>((ref) {
  return CurrentGestureNotifier();
});

class CurrentGestureNotifier extends StateNotifier<GestureData> {
  CurrentGestureNotifier() : super(EmptyGestureData());

  void updateGesture(GestureData gesture) {
    state = gesture;
  }

  void clear() {
    state = EmptyGestureData();
  }
}

/// ============================================================
/// Other UI controls / debug
/// ============================================================
final debugModeProvider = StateProvider<bool>((ref) => false);

final volumeProvider = StateProvider<double>((ref) => 0.8);

final audioPlaybackProvider = StateProvider<bool>((ref) => false);

final fpsCounterProvider = StateProvider<double>((ref) => 60.0);

final latencyMetricsProvider = StateProvider<int>((ref) => 0);