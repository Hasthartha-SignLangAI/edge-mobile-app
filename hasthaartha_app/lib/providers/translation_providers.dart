import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hasthaartha_app/models/gesture_data.dart';
import 'package:hasthaartha_app/models/translation_state.dart';

/// Provider for BLE connection state
/// In production, this would connect to actual BLE service
final bleConnectionProvider =
    StateNotifierProvider<BLEConnectionNotifier, BLEConnectionState>((ref) {
      return BLEConnectionNotifier();
    });

class BLEConnectionNotifier extends StateNotifier<BLEConnectionState> {
  BLEConnectionNotifier() : super(BLEConnectionState.disconnected());

  void connect(String deviceName) {
    state = BLEConnectionState.connected(deviceName, 85);
  }

  void disconnect() {
    state = BLEConnectionState.disconnected();
  }

  void updateSignalStrength(int strength) {
    state = state.copyWith(signalStrength: strength);
  }

  void setError(String message) {
    state = BLEConnectionState.error(message);
  }
}

/// Provider for translation screen state
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

/// Provider for current gesture data stream
/// In production, this would receive data from ML inference service
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

/// Provider for debug mode toggle
final debugModeProvider = StateProvider<bool>((ref) => false);

/// Provider for volume control
final volumeProvider = StateProvider<double>((ref) => 0.8);

/// Provider for audio playback state
final audioPlaybackProvider = StateProvider<bool>((ref) => false);

/// Provider for FPS counter (debug mode)
final fpsCounterProvider = StateProvider<double>((ref) => 60.0);

/// Provider for latency metrics (debug mode)
final latencyMetricsProvider = StateProvider<int>((ref) => 0);
