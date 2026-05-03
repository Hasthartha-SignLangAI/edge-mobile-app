import 'package:flutter/material.dart';
import 'package:hasthaartha_app/models/gesture_data.dart';

/// Custom painter for visualizing hand gestures in real-time
/// Renders 2D hand outline with 21 keypoints at 60fps
class GestureVisualizer extends StatefulWidget {
  final GestureData gestureData;
  final double size;

  const GestureVisualizer({
    super.key,
    required this.gestureData,
    this.size = 300,
  });

  @override
  State<GestureVisualizer> createState() => _GestureVisualizerState();
}

class _GestureVisualizerState extends State<GestureVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.gestureData.keypoints.isEmpty
                ? _pulseAnimation.value
                : 1.0,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _HandGesturePainter(gestureData: widget.gestureData),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for hand skeleton visualization
class _HandGesturePainter extends CustomPainter {
  final GestureData gestureData;

  _HandGesturePainter({required this.gestureData});

  @override
  void paint(Canvas canvas, Size size) {
    if (gestureData.keypoints.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Determine color based on confidence
    final confidenceColor = _getConfidenceColor(gestureData.confidence);
    paint.color = confidenceColor;

    // Draw hand skeleton connections
    _drawHandSkeleton(canvas, size, paint);

    // Draw keypoints
    _drawKeypoints(canvas, size, confidenceColor);
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw hand outline placeholder
    final center = Offset(size.width / 2, size.height / 2);
    final handPath = Path();

    // Simple hand shape
    handPath.moveTo(center.dx, center.dy - 60);
    handPath.lineTo(center.dx - 40, center.dy);
    handPath.lineTo(center.dx - 30, center.dy + 80);
    handPath.lineTo(center.dx + 30, center.dy + 80);
    handPath.lineTo(center.dx + 40, center.dy);
    handPath.close();

    canvas.drawPath(handPath, paint);

    // Draw "Ready" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Ready',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 100),
    );
  }

  void _drawHandSkeleton(Canvas canvas, Size size, Paint paint) {
    // Hand skeleton connections (simplified 21-point model)
    final connections = [
      // Thumb
      [0, 1], [1, 2], [2, 3], [3, 4],
      // Index finger
      [0, 5], [5, 6], [6, 7], [7, 8],
      // Middle finger
      [0, 9], [9, 10], [10, 11], [11, 12],
      // Ring finger
      [0, 13], [13, 14], [14, 15], [15, 16],
      // Pinky
      [0, 17], [17, 18], [18, 19], [19, 20],
    ];

    for (final connection in connections) {
      if (connection[0] < gestureData.keypoints.length &&
          connection[1] < gestureData.keypoints.length) {
        final p1 = gestureData.keypoints[connection[0]];
        final p2 = gestureData.keypoints[connection[1]];

        final offset1 = _keypointToOffset(p1, size);
        final offset2 = _keypointToOffset(p2, size);

        canvas.drawLine(offset1, offset2, paint);
      }
    }
  }

  void _drawKeypoints(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    for (final keypoint in gestureData.keypoints) {
      final offset = _keypointToOffset(keypoint, size);
      final radius = 6.0 * keypoint.confidence;

      // Draw glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(offset, radius * 1.5, glowPaint);

      // Draw keypoint
      canvas.drawCircle(offset, radius, paint);
    }
  }

  Offset _keypointToOffset(HandKeypoint keypoint, Size size) {
    // Convert normalized coordinates (0-1) to canvas coordinates
    // Add some padding and center the hand
    final padding = size.width * 0.1;
    final x = padding + (keypoint.x * (size.width - 2 * padding));
    final y = padding + (keypoint.y * (size.height - 2 * padding));
    return Offset(x, y);
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return const Color(0xFF4CAF50); // Green
    } else if (confidence >= 0.6) {
      return const Color(0xFFFFC107); // Yellow/Amber
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  @override
  bool shouldRepaint(_HandGesturePainter oldDelegate) {
    return oldDelegate.gestureData != gestureData;
  }
}
