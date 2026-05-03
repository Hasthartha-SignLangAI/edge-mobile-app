import 'dart:math';
import 'onnx_servce.dart';

class RealtimeGestureEngine {

  final int T = 512;
  final int energySmoothW = 8;

  final int minGestureFrames = 35;
  final int maxGestureFrames = 260;
  final int endQuietFrames = 20;
  final int cooldownFrames = 40;

  final int predIntervalFrames = 6;
  final int minVotes = 6;
  final double minStableFrac = 0.70;

  List<List<double>> _buffer = [];
  List<double> _energyBuffer = [];

  bool _inGesture = false;
  int _quiet = 0;
  int _frames = 0;
  int _cooldown = 0;
  int _framesSincePred = 0;

  Map<int, int> _voteCounter = {};
  Map<int, double> _confSum = {};
  double _idleSum = 0;
  int _votesTotal = 0;

  List<double>? _idleMean3;
  double _startTh = 0;
  double _endTh = 0;

  final OnnxService onnx;

  RealtimeGestureEngine(this.onnx);

  /// Resets the engine's transient state (buffers, counters) but PRESERVES
  /// calibration data (_idleMean3, _startTh, _endTh).
  void reset() {
    _buffer.clear();
    _energyBuffer.clear();
    _inGesture = false;
    _quiet = 0;
    _frames = 0;
    _cooldown = 0;
    _framesSincePred = 0;
    _voteCounter.clear();
    _confSum.clear();
    _idleSum = 0;
    _votesTotal = 0;
  }


  void calibrateIdle(List<List<double>> idleFrames) {
    double m0 = 0, m1 = 0, m2 = 0;
    for (var r in idleFrames) {
      m0 += r[0];
      m1 += r[1];
      m2 += r[2];
    }

    int n = idleFrames.length;
    _idleMean3 = [m0 / n, m1 / n, m2 / n];

    List<double> deltas =
        idleFrames.map((r) => _deltaEnergy(r)).toList();

    double med = _median(deltas);
    double mad =
        _median(deltas.map((e) => (e - med).abs()).toList()) +
            1e-6;

    double robustStd = 1.4826 * mad;

    _startTh = med + 3.0 * robustStd;
    _endTh = med + 2.0 * robustStd;
  }

  Future<PredictionResult?> pushFrame(
      List<double> frame9) async {

    if (_idleMean3 == null) return null;

    _buffer.add(frame9);
    if (_buffer.length > T) _buffer.removeAt(0);
    if (_buffer.length < T) return null;

    if (_cooldown > 0) _cooldown--;

    double energy =
        _movingAvg(_deltaEnergy(frame9));

    if (!_inGesture) {
      if (_cooldown == 0 && energy > _startTh) {
        _inGesture = true;
        _quiet = 0;
        _frames = 0;
        _framesSincePred = 0;
        _voteCounter.clear();
        _confSum.clear();
        _idleSum = 0;
        _votesTotal = 0;
      }
      return null;
    }

    _frames++;
    _framesSincePred++;

    if (energy < _endTh) {
      _quiet++;
    } else {
      _quiet = 0;
    }

    if (_frames >= minGestureFrames &&
        _framesSincePred >= predIntervalFrames) {

      _framesSincePred = 0;

      final result =
          await onnx.basePredict(_buffer);

      int pred = result["pred"];
      double conf = result["conf"];
      double idleP = result["idleP"];

      _voteCounter[pred] =
          (_voteCounter[pred] ?? 0) + 1;

      _confSum[pred] =
          (_confSum[pred] ?? 0) + conf;

      _idleSum += idleP;
      _votesTotal++;
    }

    bool endGesture =
        (_quiet >= endQuietFrames) ||
            (_frames >= maxGestureFrames);

    if (!endGesture) return null;

    _inGesture = false;
    _cooldown = cooldownFrames;

    if (_votesTotal == 0) return null;

    int best = _voteCounter.entries
        .reduce((a, b) =>
            a.value > b.value ? a : b)
        .key;

    double stable =
        _voteCounter[best]! / _votesTotal;

    double baseConf =
        _confSum[best]! /
            _voteCounter[best]!;

    double idleP =
        _idleSum / _votesTotal;

    if (_votesTotal >= minVotes &&
        stable >= minStableFrac &&
        baseConf >= onnx.BASE_CONF_TH &&
        idleP < onnx.IDLE_GATE_TH) {

      return PredictionResult(
        label: onnx.getLabel(best),
        source: "base",
        confidence: baseConf,
        stable: stable,
        idleProb: idleP,
      );
    }

    final few =
        await onnx.fewShotPredict(_buffer);

    if (few != null &&
        few["sim"] >= onnx.FEWSHOT_SIM_TH &&
        few["margin"] >= onnx.FEWSHOT_MARGIN) {

      return PredictionResult(
        label: few["label"],
        source: "fewshot",
        confidence: few["sim"],
        stable: stable,
        idleProb: idleP,
      );
    }

    return PredictionResult(
      label: "UNKNOWN",
      source: "unknown",
      confidence: baseConf,
      stable: stable,
      idleProb: idleP,
    );
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
    return _energyBuffer.reduce((a, b) => a + b) /
        _energyBuffer.length;
  }

  double _median(List<double> a) {
    final b = List<double>.from(a)..sort();
    if (b.isEmpty) return 0;
    int mid = b.length ~/ 2;
    if (b.length.isOdd) return b[mid];
    return (b[mid - 1] + b[mid]) / 2;
  }
}