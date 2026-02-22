import 'dart:math';

class RealtimeGestureEngine {

  // Model window config
  final int T = 512;
  final int F = 9;

  // Gating parameters (from your working app)
  final int energySmoothW = 8;
  final double kStart = 3.0;
  final double kEnd = 2.0;
  final int endQuietFrames = 20;
  final int minGestureFrames = 35;
  final int maxGestureFrames = 260;
  final int cooldownFrames = 40;

  List<List<double>> _buffer = [];
  List<double> _energyBuffer = [];

  bool _inGesture = false;
  int _quiet = 0;
  int _gFrames = 0;
  int _cooldown = 0;

  List<double>? _idleMean3;
  double _startTh = 0;
  double _endTh = 0;

  bool get ready => _idleMean3 != null;

  // ==========================
  // IDLE CALIBRATION
  // ==========================
  void calibrateIdle(List<List<double>> idleFrames) {

    double m0 = 0, m1 = 0, m2 = 0;

    for (var r in idleFrames) {
      m0 += r[0];
      m1 += r[1];
      m2 += r[2];
    }

    int n = idleFrames.length;

    m0 /= n;
    m1 /= n;
    m2 /= n;

    _idleMean3 = [m0, m1, m2];

    List<double> deltas = idleFrames.map((r) {
      return _deltaEnergy(r);
    }).toList();

    double med = _median(deltas);
    double mad = _median(deltas.map((x) => (x - med).abs()).toList()) + 1e-6;
    double robustStd = 1.4826 * mad;

    _startTh = med + kStart * robustStd;
    _endTh = med + kEnd * robustStd;
  }

  // ==========================
  // FRAME PUSH (REALTIME)
  // ==========================
  List<List<double>>? pushFrame(List<double> frame9) {

    if (_idleMean3 == null) return null;

    _buffer.add(frame9);
    if (_buffer.length > T) _buffer.removeAt(0);
    if (_buffer.length < T) return null;

    if (_cooldown > 0) _cooldown--;

    double energy = _movingAvg(_deltaEnergy(frame9));

    // Not in gesture
    if (!_inGesture) {
      if (_cooldown == 0 && energy > _startTh) {
        _inGesture = true;
        _quiet = 0;
        _gFrames = 0;
      }
      return null;
    }

    // In gesture
    _gFrames++;

    if (energy < _endTh) {
      _quiet++;
    } else {
      _quiet = 0;
    }

    bool endGesture = (_quiet >= endQuietFrames) ||
                      (_gFrames >= maxGestureFrames);

    if (!endGesture) return null;

    if (_gFrames < minGestureFrames) {
      _reset();
      return null;
    }

    // Gesture finished — return window for prediction
    final window = List<List<double>>.from(
      _buffer.map((r) => List<double>.from(r))
    );

    _reset();
    return window;
  }

  // ==========================
  // HELPERS
  // ==========================
  void _reset() {
    _inGesture = false;
    _quiet = 0;
    _gFrames = 0;
    _cooldown = cooldownFrames;
  }

  double _deltaEnergy(List<double> r) {
    return (r[0] - _idleMean3![0]).abs() +
           (r[1] - _idleMean3![1]).abs() +
           (r[2] - _idleMean3![2]).abs();
  }

  double _movingAvg(double x) {
    _energyBuffer.add(x);
    if (_energyBuffer.length > energySmoothW) {
      _energyBuffer.removeAt(0);
    }
    return _energyBuffer.reduce((a, b) => a + b) / _energyBuffer.length;
  }

  double _median(List<double> a) {
    final b = List<double>.from(a)..sort();
    if (b.isEmpty) return 0;
    int mid = b.length ~/ 2;
    if (b.length.isOdd) return b[mid];
    return (b[mid - 1] + b[mid]) / 2;
  }
}
