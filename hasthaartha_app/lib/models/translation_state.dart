// UI state management for the translation screen

/// Represents the current status of the translation screen
enum TranslationStatus {
  /// Ready to start, waiting for user action
  idle,

  /// Establishing BLE connection to device
  connecting,

  /// Actively translating gestures in real-time
  active,

  /// ML inference in progress
  processing,

  /// Error state (connection lost, inference failed, etc.)
  error,
}

/// Represents the overall state of the translation screen
class TranslationState {
  final TranslationStatus status;
  final String? errorMessage;
  final bool isDebugMode;
  final double volume;

  const TranslationState({
    required this.status,
    this.errorMessage,
    this.isDebugMode = false,
    this.volume = 0.8,
  });

  /// Initial idle state
  factory TranslationState.initial() {
    return const TranslationState(
      status: TranslationStatus.idle,
      isDebugMode: false,
      volume: 0.8,
    );
  }

  /// Create error state with message
  factory TranslationState.error(String message) {
    return TranslationState(
      status: TranslationStatus.error,
      errorMessage: message,
    );
  }

  bool get isIdle => status == TranslationStatus.idle;
  bool get isConnecting => status == TranslationStatus.connecting;
  bool get isActive => status == TranslationStatus.active;
  bool get isProcessing => status == TranslationStatus.processing;
  bool get hasError => status == TranslationStatus.error;

  TranslationState copyWith({
    TranslationStatus? status,
    String? errorMessage,
    bool? isDebugMode,
    double? volume,
  }) {
    return TranslationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isDebugMode: isDebugMode ?? this.isDebugMode,
      volume: volume ?? this.volume,
    );
  }
}

/// BLE connection state
class BLEConnectionState {
  final bool isConnected;
  final int signalStrength; // 0-100
  final String? deviceName;
  final String? errorMessage;

  const BLEConnectionState({
    required this.isConnected,
    this.signalStrength = 0,
    this.deviceName,
    this.errorMessage,
  });

  factory BLEConnectionState.disconnected() {
    return const BLEConnectionState(isConnected: false);
  }

  factory BLEConnectionState.connected(String deviceName, int signalStrength) {
    return BLEConnectionState(
      isConnected: true,
      deviceName: deviceName,
      signalStrength: signalStrength,
    );
  }

  factory BLEConnectionState.error(String message) {
    return BLEConnectionState(isConnected: false, errorMessage: message);
  }

  BLEConnectionState copyWith({
    bool? isConnected,
    int? signalStrength,
    String? deviceName,
    String? errorMessage,
  }) {
    return BLEConnectionState(
      isConnected: isConnected ?? this.isConnected,
      signalStrength: signalStrength ?? this.signalStrength,
      deviceName: deviceName ?? this.deviceName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
