import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class OnnxService {
  late OrtSession _classifierSession;
  late OrtSession _encoderSession;
  late OrtEnv _env;

  late List<double> _mean;
  late List<double> _scale;
  late Map<int, String> _labelMap;
  late Map<String, List<double>> _prototypes;

  // =========================================================
  // 🔥 INIT
  // =========================================================

  Future<void> init() async {
    _env = OrtEnv.instance;
    final sessionOptions = OrtSessionOptions();

    // ==============================
    // Load CNN-LSTM classifier
    // ==============================
    final classifierData = await rootBundle.load(
      'assets/models/cnn_lstm_with_idle.onnx',
    );

    _classifierSession = await OrtSession.fromBuffer(
      classifierData.buffer.asUint8List(),
      sessionOptions,
    );

    print("✅ Classifier loaded");

    // ==============================
    // Load Few-Shot Encoder
    // ==============================
    final encoderData = await rootBundle.load(
      'assets/models/encoder.onnx',
    );

    _encoderSession = await OrtSession.fromBuffer(
      encoderData.buffer.asUint8List(),
      sessionOptions,
    );

    print("✅ Few-shot encoder loaded");

    // ==============================
    // Load Scaler Params
    // ==============================
    final scalerJson = await rootBundle.loadString(
      'assets/models/scaler_params.json',
    );
    final scalerData = jsonDecode(scalerJson);

    _mean = List<double>.from(scalerData['mean']);
    _scale = List<double>.from(scalerData['scale']);

    print("✅ Scaler loaded");

    // ==============================
    // Load Label Map
    // ==============================
    final labelJson = await rootBundle.loadString(
      'assets/models/label_map.json',
    );
    final labelData = jsonDecode(labelJson);

    _labelMap = {};
    labelData.forEach((key, value) {
      _labelMap[value] = key;
    });

    print("✅ Label map loaded");

    // ==============================
    // Load Few-Shot Prototype DB
    // ==============================
    final protoJson = await rootBundle.loadString(
      'assets/models/fewshot_db.json',
    );
    final protoData = jsonDecode(protoJson);

    _prototypes = {};

    protoData['prototypes'].forEach((key, value) {
      _prototypes[key] = List<double>.from(value);
    });

    print("✅ Few-shot prototype DB loaded");
  }

  // =========================================================
  // 🔥 PREPROCESSING
  // =========================================================

  List<List<double>> _dcRemove(List<List<double>> input) {
    int T = input.length;

    List<double> means = List.filled(3, 0.0);

    // Compute mean for first 3 EMG channels
    for (int t = 0; t < T; t++) {
      for (int f = 0; f < 3; f++) {
        means[f] += input[t][f];
      }
    }

    for (int f = 0; f < 3; f++) {
      means[f] /= T;
    }

    // Subtract mean
    List<List<double>> corrected = [];

    for (int t = 0; t < T; t++) {
      List<double> row = List.from(input[t]);

      for (int f = 0; f < 3; f++) {
        row[f] = row[f] - means[f];
      }

      corrected.add(row);
    }

    return corrected;
  }

  List<List<double>> _normalize(List<List<double>> input) {
    List<List<double>> normalized = [];

    for (var row in input) {
      List<double> newRow = [];

      for (int i = 0; i < row.length; i++) {
        double value = (row[i] - _mean[i]) / _scale[i];
        newRow.add(value);
      }

      normalized.add(newRow);
    }

    return normalized;
  }

  Float32List _prepareInput(List<List<double>> inputData) {
    final dcCorrected = _dcRemove(inputData);
    final normalized = _normalize(dcCorrected);
    final flattened = normalized.expand((row) => row).toList();
    return Float32List.fromList(flattened);
  }

  // =========================================================
  // 🔥 STANDARD CNN-LSTM PREDICTION
  // =========================================================

  Future<String> predictWord(List<List<double>> inputData) async {
    final inputTensor = OrtValueTensor.createTensorWithDataList(
      _prepareInput(inputData),
      [1, 512, 9],
    );

    final inputs = {
      _classifierSession.inputNames.first: inputTensor
    };

    final outputs =
        await _classifierSession.runAsync(OrtRunOptions(), inputs);

    if (outputs == null || outputs.isEmpty) {
      throw Exception("Classifier inference failed.");
    }

    final outputTensor = outputs.first as OrtValueTensor;
    final rawOutput = outputTensor.value;

    final List<List<double>> output2D =
        (rawOutput as List).map((e) => (e as List).cast<double>()).toList();

    final softmax = output2D.first;

    // Get best index
    final sortedIndices = List.generate(softmax.length, (i) => i)
      ..sort((a, b) => softmax[b].compareTo(softmax[a]));

    final predictedIndex = sortedIndices.first;
    final confidence = softmax[predictedIndex];

    print("FINAL PREDICTION → ${_labelMap[predictedIndex]} "
        "(confidence: ${confidence.toStringAsFixed(4)})");

    return _labelMap[predictedIndex] ?? "Unknown";
  }

  // =========================================================
  // 🔥 FEW-SHOT PREDICTION
  // =========================================================

  Future<String> predictFewShot(List<List<double>> inputData) async {
    final inputTensor = OrtValueTensor.createTensorWithDataList(
      _prepareInput(inputData),
      [1, 512, 9],
    );

    final inputs = {
      _encoderSession.inputNames.first: inputTensor
    };

    final outputs =
        await _encoderSession.runAsync(OrtRunOptions(), inputs);

    if (outputs == null || outputs.isEmpty) {
      throw Exception("Encoder inference failed.");
    }

    final outputTensor = outputs.first as OrtValueTensor;
    final raw = outputTensor.value as List;

    final embedding = (raw.first as List).cast<double>();

    String bestLabel = "";
    double bestDistance = double.infinity;

    _prototypes.forEach((label, proto) {
      double dist = _euclidean(embedding, proto);
      if (dist < bestDistance) {
        bestDistance = dist;
        bestLabel = label;
      }
    });

    print("FEW-SHOT PREDICTION → $bestLabel "
        "(distance: ${bestDistance.toStringAsFixed(4)})");

    return bestLabel;
  }

  double _euclidean(List<double> a, List<double> b) {
    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      double diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sum; // sqrt not required
  }

  // =========================================================
  // 🔥 TXT LOADER (for testing)
  // =========================================================

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
        final row9 = parts
            .sublist(1)
            .map((e) => double.parse(e.trim()))
            .toList();

        if (row9.length == 9) {
          frames.add(row9);
        }
      } catch (_) {}
    }

    return frames;
  }
}
