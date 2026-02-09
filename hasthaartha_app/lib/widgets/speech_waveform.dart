import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated waveform visualization for speech audio
/// Shows real-time audio amplitude or idle breathing animation
class SpeechWaveform extends StatefulWidget {
  final List<double> waveformData;
  final bool isPlaying;
  final Color color;
  final double height;

  const SpeechWaveform({
    super.key,
    this.waveformData = const [],
    this.isPlaying = false,
    this.color = const Color(0xFF2196F3),
    this.height = 80,
  });

  @override
  State<SpeechWaveform> createState() => _SpeechWaveformState();
}

class _SpeechWaveformState extends State<SpeechWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _WaveformPainter(
              waveformData: widget.waveformData,
              isPlaying: widget.isPlaying,
              color: widget.color,
              animationValue: _animation.value,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final bool isPlaying;
  final Color color;
  final double animationValue;

  _WaveformPainter({
    required this.waveformData,
    required this.isPlaying,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty || !isPlaying) {
      _drawIdleWave(canvas, size);
    } else {
      _drawActiveWaveform(canvas, size);
    }
  }

  void _drawIdleWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final waveCount = 3;

    path.moveTo(0, centerY);

    for (var i = 0; i <= size.width; i++) {
      final x = i.toDouble();
      final normalizedX = x / size.width;
      final wave = math.sin(
        (normalizedX * waveCount * 2 * math.pi) + animationValue,
      );
      final y = centerY + (wave * 8); // Small amplitude for idle
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawActiveWaveform(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (var i = 0; i < waveformData.length; i++) {
      final amplitude = waveformData[i];
      final barHeight = amplitude * (size.height / 2) * 0.8;

      final x = i * barWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth * 0.7,
          height: barHeight,
        ),
        const Radius.circular(2),
      );

      // Draw with gradient effect
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.6),
          color,
          color.withValues(alpha: 0.6),
        ],
      );

      final gradientPaint = Paint()
        ..shader = gradient.createShader(rect.outerRect);

      canvas.drawRRect(rect, gradientPaint);
    }

    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (var i = 0; i < waveformData.length; i++) {
      final amplitude = waveformData[i];
      final barHeight = amplitude * (size.height / 2) * 0.8;

      final x = i * barWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth * 0.7,
          height: barHeight,
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.animationValue != animationValue;
  }
}
