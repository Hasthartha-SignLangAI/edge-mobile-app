import 'dart:async';
import 'dart:math';

import 'package:hasthaartha_app/localdb/repo/local_repo.dart';
import 'package:hasthaartha_app/services/ble_pipeline_service.dart';
import 'package:hasthaartha_app/services/onnx_servce.dart';

enum EnrollmentStage {
  idle,
  calibrating,
  waitingIdle,
  countdown,
  recording,
  saving,
  done,
  cancelled,
  error,
}

class EnrollmentState {
  final bool active;
  final EnrollmentStage stage;
  final String? word;
  final int samplesTarget;
  final int samplesDone;
  final double durationSec;
  final int? countdown;
  final String? message;
  final String? error;

  const EnrollmentState({
    required this.active,
    required this.stage,
    this.word,
    required this.samplesTarget,
    required this.samplesDone,
    required this.durationSec,
    this.countdown,
    this.message,
    this.error,
  });

  factory EnrollmentState.initial() => const EnrollmentState(
        active: false,
        stage: EnrollmentStage.idle,
        samplesTarget: 0,
        samplesDone: 0,
        durationSec: 6.0,
      );

  EnrollmentState copyWith({
    bool? active,
    EnrollmentStage? stage,
    String? word,
    int? samplesTarget,
    int? samplesDone,
    double? durationSec,
    int? countdown,
    String? message,
    String? error,
    bool clearCountdown = false,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return EnrollmentState(
      active: active ?? this.active,
      stage: stage ?? this.stage,
      word: word ?? this.word,
      samplesTarget: samplesTarget ?? this.samplesTarget,
      samplesDone: samplesDone ?? this.samplesDone,
      durationSec: durationSec ?? this.durationSec,
      countdown: clearCountdown ? null : (countdown ?? this.countdown),
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class GestureEnrollmentService {
  final BlePipelineService bleService;
  final OnnxService onnx;
  final LocalRepo repo;

  GestureEnrollmentService({
    required this.bleService,
    required this.onnx,
    required this.repo,
  }) {
    _frameSub = bleService.frameStream.listen(_onFrame);
    _stateController.add(_state);
  }

  // -----------------------------
  // Config (matched to web logic)
  // -----------------------------
  static const int _t = 512;
  static const int _f = 9;

  static const int _calibFrames = 200; // ~2 sec at 100Hz
  static const double _kStart = 3.0;
  static const double _kEnd = 2.0;
  static const int _energySmoothW = 8;

  // -----------------------------
  // Streams / state
  // -----------------------------
  final StreamController<EnrollmentState> _stateController =
      StreamController<EnrollmentState>.broadcast();

  Stream<EnrollmentState> get stateStream => _stateController.stream;

  EnrollmentState _state = EnrollmentState.initial();
  EnrollmentState get currentState => _state;

  StreamSubscription<List<double>>? _frameSub;

  // -----------------------------
  // Live frame state
  // -----------------------------
  final List<List<double>> _buffer = [];
  final List<double> _energyBuffer = [];

  final List<List<double>> _calibFramesBuf = [];

  List<double>? _idleMean3;
  double _startTh = 0.0;
  double _endTh = 0.0;

  // -----------------------------
  // Enrollment state
  // -----------------------------
  bool _active = false;
  String? _word;
  int _samplesTarget = 0;
  int _samplesDone = 0;
  double _durationSec = 6.0;

  bool _recording = false;
  bool _waitingIdle = false;

  DateTime? _countdownStart;
  int _countdownSeconds = 3;

  DateTime? _recordStart;
  List<List<double>> _currentRawFrames = [];
  final List<List<List<double>>> _sampleWindows = [];

  // -----------------------------
  // Public controls
  // -----------------------------
  Future<bool> startEnrollment({
    required String word,
    int samples = 10,
    double durationSec = 6.0,
  }) async {
    final cleaned = word.trim();

    if (cleaned.isEmpty || cleaned.contains(' ')) {
      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.error,
        error: 'Invalid word. Use a single word without spaces.',
      ));
      return false;
    }

    if (samples <= 0 || samples > 50) {
      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.error,
        error: 'Samples must be between 1 and 50.',
      ));
      return false;
    }

    if (durationSec < 1.0 || durationSec > 12.0) {
      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.error,
        error: 'Duration must be between 1 and 12 seconds.',
      ));
      return false;
    }

    if (_active) {
      _emit(_state.copyWith(
        stage: EnrollmentStage.error,
        error: 'Enrollment already active. Cancel first.',
      ));
      return false;
    }

    _active = true;
    _word = cleaned;
    _samplesTarget = samples;
    _samplesDone = 0;
    _durationSec = durationSec;

    _recording = false;
    _waitingIdle = true;
    _countdownStart = null;
    _recordStart = null;
    _currentRawFrames = [];
    _sampleWindows.clear();

    // If calibration is not ready yet, service will auto-calibrate from live frames.
    _emit(EnrollmentState(
      active: true,
      stage: _idleMean3 == null
          ? EnrollmentStage.calibrating
          : EnrollmentStage.waitingIdle,
      word: _word,
      samplesTarget: _samplesTarget,
      samplesDone: _samplesDone,
      durationSec: _durationSec,
      message: _idleMean3 == null
          ? 'Calibrating idle baseline. Keep arm relaxed.'
          : 'Waiting for idle hand position.',
    ));

    return true;
  }

  void cancelEnrollment() {
    _active = false;
    _word = null;
    _samplesTarget = 0;
    _samplesDone = 0;
    _durationSec = 6.0;

    _recording = false;
    _waitingIdle = false;
    _countdownStart = null;
    _recordStart = null;
    _currentRawFrames = [];
    _sampleWindows.clear();

    _emit(const EnrollmentState(
      active: false,
      stage: EnrollmentStage.cancelled,
      samplesTarget: 0,
      samplesDone: 0,
      durationSec: 6.0,
      message: 'Enrollment cancelled.',
    ));
  }

  void dispose() {
    _frameSub?.cancel();
    _stateController.close();
  }

  // -----------------------------
  // Main frame handler
  // -----------------------------
  void _onFrame(List<double> frame9) {
    if (frame9.length != _f) return;

    // Always keep ring buffer
    _buffer.add(List<double>.from(frame9));
    if (_buffer.length > _t) {
      _buffer.removeAt(0);
    }

    // Auto-calibrate from live frames if not yet calibrated
    if (_idleMean3 == null) {
      _calibFramesBuf.add(List<double>.from(frame9));
      if (_calibFramesBuf.length >= _calibFrames) {
        _calibrateIdle(_calibFramesBuf);
        _calibFramesBuf.clear();

        if (_active) {
          _emit(_state.copyWith(
            stage: EnrollmentStage.waitingIdle,
            message: 'Calibration complete. Waiting for idle hand position.',
            clearError: true,
            clearCountdown: true,
          ));
        }
      } else if (_active) {
        _emit(_state.copyWith(
          stage: EnrollmentStage.calibrating,
          message: 'Calibrating idle baseline... ${_calibFramesBuf.length}/$_calibFrames',
          clearError: true,
          clearCountdown: true,
        ));
      }
      return;
    }

    if (!_active) return;

    final d = _deltaEnergy(frame9);
    final dSmooth = _movingAvg(d);

    _handleEnrollment(dSmooth, frame9);
  }

  // -----------------------------
  // Enrollment state machine
  // -----------------------------
  void _handleEnrollment(double dSmooth, List<double> frame9) {
    final idleStable = dSmooth < _endTh;

    // Waiting for idle
    if (_waitingIdle && !_recording && _countdownStart == null) {
      if (idleStable) {
        _waitingIdle = false;
        _countdownStart = DateTime.now();

        _emit(_state.copyWith(
          stage: EnrollmentStage.countdown,
          countdown: 3,
          message:
              'Get ready for "${_word ?? ''}" - sample ${_samplesDone + 1}/$_samplesTarget',
          clearError: true,
        ));
      } else {
        _emit(_state.copyWith(
          stage: EnrollmentStage.waitingIdle,
          message: 'Hold arm still to start countdown.',
          clearError: true,
          clearCountdown: true,
        ));
      }
      return;
    }

    // Countdown
    if (_countdownStart != null && !_recording) {
      final elapsedMs =
          DateTime.now().difference(_countdownStart!).inMilliseconds;
      final remaining = _countdownSeconds - (elapsedMs ~/ 1000);

      if (remaining > 0) {
        _emit(_state.copyWith(
          stage: EnrollmentStage.countdown,
          countdown: remaining,
          message:
              'Perform "${_word ?? ''}" in $remaining...',
          clearError: true,
        ));
        return;
      } else {
        _countdownStart = null;
        _recording = true;
        _recordStart = DateTime.now();
        _currentRawFrames = [];

        _emit(_state.copyWith(
          stage: EnrollmentStage.recording,
          countdown: 0,
          message:
              'Recording sample ${_samplesDone + 1}/$_samplesTarget...',
          clearError: true,
        ));
        return;
      }
    }

    // Recording
    if (_recording) {
      _currentRawFrames.add(List<double>.from(frame9));

      final elapsedMs =
          DateTime.now().difference(_recordStart!).inMilliseconds;

      if (elapsedMs >= (_durationSec * 1000).round()) {
        _recording = false;

        final raw = List<List<double>>.from(_currentRawFrames);
        final fixed = _fixLengthCenter(raw, _t);

        _sampleWindows.add(fixed);
        _samplesDone += 1;

        _emit(_state.copyWith(
          stage: EnrollmentStage.waitingIdle,
          samplesDone: _samplesDone,
          message: 'Recorded sample $_samplesDone/$_samplesTarget',
          clearCountdown: true,
          clearError: true,
        ));

        if (_samplesDone >= _samplesTarget) {
          _finalizeEnrollment();
          return;
        }

        _waitingIdle = true;
        _currentRawFrames = [];
        _recordStart = null;
      }
      return;
    }
  }

  // -----------------------------
  // Finalize: average embeddings
  // -----------------------------
  Future<void> _finalizeEnrollment() async {
    if (_sampleWindows.isEmpty || _word == null) {
      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.error,
        error: 'No samples recorded.',
      ));
      cancelEnrollment();
      return;
    }

    _emit(_state.copyWith(
      stage: EnrollmentStage.saving,
      message: 'Generating personalized prototype...',
      clearCountdown: true,
      clearError: true,
    ));

    try {
      final embeddings = <List<double>>[];

      for (final window in _sampleWindows) {
        final emb = await onnx.encodeWindow(window);
        embeddings.add(emb);
      }

      if (embeddings.isEmpty) {
        throw Exception('No embeddings generated.');
      }

      final dim = embeddings.first.length;
      final avg = List<double>.filled(dim, 0.0);

      for (final emb in embeddings) {
        for (int i = 0; i < dim; i++) {
          avg[i] += emb[i];
        }
      }

      for (int i = 0; i < dim; i++) {
        avg[i] /= embeddings.length;
      }

      final prototype = onnx.normalizeEmbedding(avg);

      await repo.saveGesturePrototype(
        label: _word!,
        prototype: prototype,
        sampleCount: _sampleWindows.length,
      );

      _active = false;

      _emit(EnrollmentState(
        active: false,
        stage: EnrollmentStage.done,
        word: _word,
        samplesTarget: _samplesTarget,
        samplesDone: _samplesDone,
        durationSec: _durationSec,
        message:
            'Gesture "${_word!}" saved successfully with ${_sampleWindows.length} samples.',
      ));

      // Reset local enrollment fields but keep calibration
      _resetEnrollmentFieldsOnly();
    } catch (e) {
      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.error,
        error: 'Failed to save gesture: $e',
      ));
      _resetEnrollmentFieldsOnly();
    }
  }

  void _resetEnrollmentFieldsOnly() {
    _active = false;
    _word = null;
    _samplesTarget = 0;
    _samplesDone = 0;
    _durationSec = 6.0;

    _recording = false;
    _waitingIdle = false;
    _countdownStart = null;
    _recordStart = null;
    _currentRawFrames = [];
    _sampleWindows.clear();
  }

  // -----------------------------
  // Calibration helpers
  // -----------------------------
  void _calibrateIdle(List<List<double>> idleFrames) {
    double m0 = 0.0, m1 = 0.0, m2 = 0.0;

    for (final r in idleFrames) {
      m0 += r[0];
      m1 += r[1];
      m2 += r[2];
    }

    final n = idleFrames.length;
    _idleMean3 = [m0 / n, m1 / n, m2 / n];

    final deltas = idleFrames.map(_deltaEnergy).toList();

    final med = _median(deltas);
    final mad =
        _median(deltas.map((x) => (x - med).abs()).toList()) + 1e-6;
    final robustStd = 1.4826 * mad;

    _startTh = med + _kStart * robustStd;
    _endTh = med + _kEnd * robustStd;
  }

  double _deltaEnergy(List<double> row9) {
    if (_idleMean3 == null) return 0.0;

    return (row9[0] - _idleMean3![0]).abs() +
        (row9[1] - _idleMean3![1]).abs() +
        (row9[2] - _idleMean3![2]).abs();
  }

  double _movingAvg(double x) {
    _energyBuffer.add(x);
    if (_energyBuffer.length > _energySmoothW) {
      _energyBuffer.removeAt(0);
    }
    return _energyBuffer.reduce((a, b) => a + b) / _energyBuffer.length;
  }

  double _median(List<double> a) {
    final b = List<double>.from(a)..sort();
    if (b.isEmpty) return 0.0;
    final mid = b.length ~/ 2;
    if (b.length.isOdd) return b[mid];
    return (b[mid - 1] + b[mid]) / 2.0;
  }

  List<List<double>> _fixLengthCenter(
    List<List<double>> x,
    int targetLen,
  ) {
    if (x.length >= targetLen) {
      final start = (x.length - targetLen) ~/ 2;
      return x.sublist(start, start + targetLen);
    }

    final out = List<List<double>>.from(x.map((e) => List<double>.from(e)));
    while (out.length < targetLen) {
      out.add(List<double>.filled(_f, 0.0));
    }
    return out;
  }

  void _emit(EnrollmentState s) {
    _state = s;
    if (!_stateController.isClosed) {
      _stateController.add(s);
    }
  }
}