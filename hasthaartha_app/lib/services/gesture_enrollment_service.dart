import 'dart:async';
import 'dart:math';

import 'package:hasthaartha_app/localdb/repo/local_repo.dart';
import 'package:hasthaartha_app/services/ble_pipeline_service.dart';
import 'package:hasthaartha_app/services/onnx_servce.dart';

enum EnrollmentStage {
  idle,
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

  static const int _t = 512;
  static const int _f = 9;

  final StreamController<EnrollmentState> _stateController =
      StreamController<EnrollmentState>.broadcast();

  Stream<EnrollmentState> get stateStream => _stateController.stream;

  EnrollmentState _state = EnrollmentState.initial();
  EnrollmentState get currentState => _state;

  StreamSubscription<List<double>>? _frameSub;

  final List<List<double>> _buffer = [];

  int _idleStableFrames = 0;

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
        error: 'Invalid word. Use a single word.',
      ));
      return false;
    }

    if (_active) {
      _emit(_state.copyWith(
        stage: EnrollmentStage.error,
        error: 'Enrollment already active.',
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

    _emit(EnrollmentState(
      active: true,
      stage: EnrollmentStage.waitingIdle,
      word: _word,
      samplesTarget: samples,
      samplesDone: 0,
      durationSec: durationSec,
      message: 'Hold arm still to start recording.',
    ));

    return true;
  }

  void cancelEnrollment() {
    _resetEnrollmentFieldsOnly();

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

  void _onFrame(List<double> frame9) async {
    if (frame9.length != _f) return;

    _buffer.add(List<double>.from(frame9));
    if (_buffer.length > _t) {
      _buffer.removeAt(0);
    }

    if (!_active) return;
    if (_buffer.length < _t) return;

    await _handleEnrollment(frame9);
  }

  Future<void> _handleEnrollment(List<double> frame9) async {
    final base = await onnx.basePredict(_buffer);
    final idleStable = base["idleP"] > 0.7;

    if (_waitingIdle && !_recording && _countdownStart == null) {
      if (idleStable) {
        _idleStableFrames++;

        if (_idleStableFrames > 15) {
          _waitingIdle = false;
          _idleStableFrames = 0;
          _countdownStart = DateTime.now();

          _emit(_state.copyWith(
            stage: EnrollmentStage.countdown,
            countdown: 3,
            message: 'Get ready...',
          ));
        }
      } else {
        _idleStableFrames = 0;
      }
      return;
    }

    if (_countdownStart != null && !_recording) {
      final elapsed =
          DateTime.now().difference(_countdownStart!).inMilliseconds;

      final remaining = _countdownSeconds - (elapsed ~/ 1000);

      if (remaining > 0) {
        _emit(_state.copyWith(
          stage: EnrollmentStage.countdown,
          countdown: remaining,
        ));
        return;
      }

      _countdownStart = null;
      _recording = true;
      _recordStart = DateTime.now();
      _currentRawFrames = [];

      _emit(_state.copyWith(
        stage: EnrollmentStage.recording,
        message:
            'Recording sample ${_samplesDone + 1}/$_samplesTarget',
      ));
      return;
    }

    if (_recording) {
      _currentRawFrames.add(frame9);

      final elapsed =
          DateTime.now().difference(_recordStart!).inMilliseconds;

      if (elapsed >= (_durationSec * 1000)) {
        _recording = false;

        final raw = List<List<double>>.from(_currentRawFrames);
        final fixed = _fixLengthCenter(raw, _t);

        _sampleWindows.add(fixed);
        _samplesDone++;

        _emit(_state.copyWith(
          stage: EnrollmentStage.waitingIdle,
          samplesDone: _samplesDone,
          message: 'Recorded $_samplesDone/$_samplesTarget',
        ));

        if (_samplesDone >= _samplesTarget) {
          _finalizeEnrollment();
          return;
        }

        _waitingIdle = true;
        _currentRawFrames = [];
      }
    }
  }

  Future<void> _finalizeEnrollment() async {
    try {
      final embeddings = <List<double>>[];

      for (final window in _sampleWindows) {
        final emb = await onnx.encodeWindow(window);
        embeddings.add(emb);
      }

      final dim = embeddings.first.length;
      final avg = List<double>.filled(dim, 0);

      for (final e in embeddings) {
        for (int i = 0; i < dim; i++) {
          avg[i] += e[i];
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

      final protos = await repo.loadCustomPrototypes();
      onnx.setCustomPrototypes(protos);

      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.done,
        message: 'Gesture "$_word" saved successfully.',
      ));

      _resetEnrollmentFieldsOnly();
    } catch (e) {
      _emit(_state.copyWith(
        active: false,
        stage: EnrollmentStage.error,
        error: e.toString(),
      ));
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

  List<List<double>> _fixLengthCenter(
      List<List<double>> x, int targetLen) {
    if (x.length >= targetLen) {
      final start = (x.length - targetLen) ~/ 2;
      return x.sublist(start, start + targetLen);
    }

    final out = List<List<double>>.from(x);

    while (out.length < targetLen) {
      out.add(List.filled(_f, 0));
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