// Data models for gesture recognition and hand tracking

/// Represents a single hand keypoint in 3D space
class HandKeypoint {
  final double x;
  final double y;
  final double z;
  final double confidence;

  const HandKeypoint({
    required this.x,
    required this.y,
    required this.z,
    required this.confidence,
  });

  factory HandKeypoint.fromJson(Map<String, dynamic> json) {
    return HandKeypoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'z': z, 'confidence': confidence};
  }
}

/// Represents a recognized gesture with all associated data
class GestureData {
  final String label;
  final String sinhalaText;
  final double confidence;
  final List<HandKeypoint> keypoints;
  final DateTime timestamp;

  const GestureData({
    required this.label,
    required this.sinhalaText,
    required this.confidence,
    required this.keypoints,
    required this.timestamp,
  });

  factory GestureData.fromJson(Map<String, dynamic> json) {
    return GestureData(
      label: json['label'] as String,
      sinhalaText: json['sinhalaText'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      keypoints: (json['keypoints'] as List)
          .map((k) => HandKeypoint.fromJson(k as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'sinhalaText': sinhalaText,
      'confidence': confidence,
      'keypoints': keypoints.map((k) => k.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Returns color based on confidence level
  /// Green (>80%), Yellow (60-80%), Red (<60%)
  String get confidenceColor {
    if (confidence >= 0.8) return 'green';
    if (confidence >= 0.6) return 'yellow';
    return 'red';
  }

  /// Check if confidence is high enough for auto-play
  bool get isHighConfidence => confidence >= 0.7;

  GestureData copyWith({
    String? label,
    String? sinhalaText,
    double? confidence,
    List<HandKeypoint>? keypoints,
    DateTime? timestamp,
  }) {
    return GestureData(
      label: label ?? this.label,
      sinhalaText: sinhalaText ?? this.sinhalaText,
      confidence: confidence ?? this.confidence,
      keypoints: keypoints ?? this.keypoints,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Empty gesture data for initial state
class EmptyGestureData extends GestureData {
  EmptyGestureData()
    : super(
        label: '',
        sinhalaText: '',
        confidence: 0.0,
        keypoints: const [],
        timestamp: DateTime.now(),
      );
}
