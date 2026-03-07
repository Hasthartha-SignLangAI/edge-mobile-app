import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class PredictionResult {
  final String label;
  final String source; // base | fewshot | unknown
  final double confidence;
  final double stable;
  final double idleProb;

  PredictionResult({
    required this.label,
    required this.source,
    required this.confidence,
    required this.stable,
    required this.idleProb,
  });
}

class OnnxService {
  late OrtSession _classifierSession;
  late OrtSession _encoderSession;
  late OrtEnv _env;

  late List<double> _mean;
  late List<double> _scale;
  late Map<int, String> _labelMap;
  late Map<String, List<double>> _prototypes;

  late int _idleIndex;

  // thresholds from web system
  final double BASE_CONF_TH = 0.80;
  final double IDLE_GATE_TH = 0.60;
  final double FEWSHOT_SIM_TH = 0.78;
  final double FEWSHOT_MARGIN = 0.06;

  String getLabel(int index) {
    return _labelMap[index] ?? "Unknown";
  }

  Map<String, List<double>> getBuiltInPrototypes() {
    return _prototypes;
  }

  // ================= INIT =================

  Future<void> init() async {
    _env = OrtEnv.instance;
    final sessionOptions = OrtSessionOptions();

    final classifierData =
        await rootBundle.load('assets/models/cnn_lstm_with_idle.onnx');

    _classifierSession = await OrtSession.fromBuffer(
        classifierData.buffer.asUint8List(), sessionOptions);

    final encoderData =
        await rootBundle.load('assets/models/encoder.onnx');

    _encoderSession = await OrtSession.fromBuffer(
        encoderData.buffer.asUint8List(), sessionOptions);

    final scalerJson =
        await rootBundle.loadString('assets/models/scaler_params.json');

    final scalerData = jsonDecode(scalerJson);
    _mean = List<double>.from(scalerData['mean']);
    _scale = List<double>.from(scalerData['scale']);

    final labelJson =
        await rootBundle.loadString('assets/models/label_map.json');

    final labelData = jsonDecode(labelJson);
    _labelMap = {};
    labelData.forEach((key, value) {
      _labelMap[value] = key;
    });

    _idleIndex = _labelMap.entries
        .firstWhere((e) => e.value == "idle")
        .key;

    final protoJson =
        await rootBundle.loadString('assets/models/fewshot_db.json');

    final protoData = jsonDecode(protoJson);

    _prototypes = {};
    protoData['prototypes'].forEach((key, value) {
      _prototypes[key] = List<double>.from(value);
    });
  }

  // ================= PREPROCESS =================

  List<List<double>> _dcRemove(List<List<double>> input) {
    int T = input.length;
    List<double> means = List.filled(3, 0.0);

    for (var row in input) {
      for (int i = 0; i < 3; i++) {
        means[i] += row[i];
      }
    }

    for (int i = 0; i < 3; i++) {
      means[i] /= T;
    }

    return input.map((row) {
      List<double> r = List.from(row);
      for (int i = 0; i < 3; i++) {
        r[i] -= means[i];
      }
      return r;
    }).toList();
  }

  List<List<double>> _normalize(List<List<double>> input) {
    return input.map((row) {
      return List.generate(
        row.length,
        (i) => (row[i] - _mean[i]) / (_scale[i] + 1e-6),
      );
    }).toList();
  }

  Float32List prepareInput(List<List<double>> input) {
    final dc = _dcRemove(input);
    final norm = _normalize(dc);
    return Float32List.fromList(norm.expand((e) => e).toList());
  }

  // ================= BASE MODEL =================

  Future<Map<String, dynamic>> basePredict(
      List<List<double>> inputData) async {
    final tensor = OrtValueTensor.createTensorWithDataList(
        prepareInput(inputData), [1, 512, 9]);

    final outputs = await _classifierSession.runAsync(
        OrtRunOptions(),
        {_classifierSession.inputNames.first: tensor});

    final raw = (outputs!.first as OrtValueTensor).value;
    final probs =
        (raw as List).first.cast<double>();

    int pred = 0;
    double maxConf = probs[0];

    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > maxConf) {
        maxConf = probs[i];
        pred = i;
      }
    }

    return {
      "pred": pred,
      "conf": maxConf,
      "idleP": probs[_idleIndex],
    };
  }

  // ================= ENCODER =================
  // Used for FEW-SHOT + ENROLLMENT

  Future<List<double>> encodeWindow(
      List<List<double>> inputData) async {

    final tensor = OrtValueTensor.createTensorWithDataList(
        prepareInput(inputData), [1, 512, 9]);

    final outputs = await _encoderSession.runAsync(
        OrtRunOptions(),
        {_encoderSession.inputNames.first: tensor});

    List<double> embedding =
        ((outputs!.first as OrtValueTensor).value as List)
            .first
            .cast<double>();

    return normalizeEmbedding(embedding);
  }

  List<double> normalizeEmbedding(List<double> embedding) {
    double norm =
        sqrt(embedding.fold(0, (a, b) => a + b * b));

    return embedding
        .map((e) => e / (norm + 1e-8))
        .toList();
  }

  // ================= FEW SHOT =================

  Future<Map<String, dynamic>?> fewShotPredict(
      List<List<double>> inputData,
      {Map<String, List<double>>? customPrototypes}) async {

    if (_prototypes.isEmpty && customPrototypes == null) return null;

    final embedding = await encodeWindow(inputData);

    Map<String, List<double>> allProtos = {};

    allProtos.addAll(_prototypes);

    if (customPrototypes != null) {
      allProtos.addAll(customPrototypes);
    }

    String? bestLabel;
    double bestSim = -1;
    double secondSim = -1;

    allProtos.forEach((label, proto) {
      double sim = _cosine(embedding, proto);

      if (sim > bestSim) {
        secondSim = bestSim;
        bestSim = sim;
        bestLabel = label;
      } else if (sim > secondSim) {
        secondSim = sim;
      }
    });

    double margin = bestSim - secondSim;

    return {
      "label": bestLabel,
      "sim": bestSim,
      "margin": margin,
    };
  }

  double _cosine(List<double> a, List<double> b) {
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  // ================= TXT LOADER (DEBUG) =================

  Future<List<List<double>>> loadTxtFrames(String path) async {
    final text = await rootBundle.loadString(path);
    final lines = text.split('\n');

    final frames = <List<double>>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');

      if (parts.length != 10) continue;

      try {
        final row9 =
            parts.sublist(1).map((e) => double.parse(e)).toList();

        if (row9.length == 9) {
          frames.add(row9);
        }
      } catch (_) {}
    }

    return frames;
  }
}