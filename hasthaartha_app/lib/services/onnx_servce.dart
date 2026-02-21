import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class OnnxService {
  late OrtSession _session;
  late OrtEnv _env;

  late List<double> _mean;
  late List<double> _scale;
  late Map<int, String> _labelMap;

  Future<void> init() async {
    _env = OrtEnv.instance;

    // Load ONNX model
    final modelData = await rootBundle.load(
      'assets/models/cnn_lstm_with_idle.onnx',
    );

    final sessionOptions = OrtSessionOptions();
    _session = await OrtSession.fromBuffer(
      modelData.buffer.asUint8List(),
      sessionOptions,
    );

    // 🔥 Load scaler params
    final scalerJson = await rootBundle.loadString(
      'assets/models/scaler_params.json',
    );
    final scalerData = jsonDecode(scalerJson);

    _mean = List<double>.from(scalerData['mean']);
    _scale = List<double>.from(scalerData['scale']);

    // 🔥 Load label map
    final labelJson = await rootBundle.loadString(
      'assets/models/label_map.json',
    );
    final labelData = jsonDecode(labelJson);

    _labelMap = {};
    labelData.forEach((key, value) {
      _labelMap[value] = key;
    });
  }

  // ===============================
  // 🔥 PREPROCESSING
  // ===============================

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

  // ===============================
  // 🔥 PREDICTION
  // ===============================

  Future<String> predictWord(List<List<double>> inputData) async {
    // Normalize first
    final dcCorrected = _dcRemove(inputData);
    final normalized = _normalize(dcCorrected);

    final flattened = normalized.expand((row) => row).toList();

    final inputTensor = OrtValueTensor.createTensorWithDataList(
      Float32List.fromList(flattened),
      [1, 512, 9],
    );

    final inputs = <String, OrtValue>{_session.inputNames.first: inputTensor};

    final outputs = await _session.runAsync(OrtRunOptions(), inputs);

    if (outputs == null || outputs.isEmpty) {
      throw Exception("ONNX inference failed.");
    }

    final outputTensor = outputs.first as OrtValueTensor;

    final rawOutput = outputTensor.value;

    final List<List<double>> output2D = (rawOutput as List)
        .map((e) => (e as List).cast<double>())
        .toList();

    final softmax = output2D.first;

    print("---- CLASS PROBABILITIES ----");

    for (int i = 0; i < softmax.length; i++) {
      final label = _labelMap[i] ?? "unknown";
      print("$label : ${softmax[i].toStringAsFixed(6)}");
    }

    print("-----------------------------");

    // Sort indices by probability (descending)
    final sortedIndices = List.generate(softmax.length, (i) => i)
      ..sort((a, b) => softmax[b].compareTo(softmax[a]));

    print("Top 3 Predictions:");
    for (int i = 0; i < 3; i++) {
      final idx = sortedIndices[i];
      print("${_labelMap[idx]} : ${softmax[idx].toStringAsFixed(6)}");
    }

    print("-----------------------------");

    // Best prediction
    final predictedIndex = sortedIndices.first;
    final confidence = softmax[predictedIndex];

    print(
      "FINAL PREDICTION → ${_labelMap[predictedIndex]} "
      "(confidence: ${confidence.toStringAsFixed(4)})",
    );

    return _labelMap[predictedIndex] ?? "Unknown";
  }

  List<List<double>> _dcRemove(List<List<double>> input) {
    int T = input.length;
    int F = input[0].length;

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

  Future<List<List<double>>> loadTxtFrames(String path) async {
  final text = await rootBundle.loadString(path);
  final lines = text.split('\n');

  final frames = <List<double>>[];

  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    final parts = line.split(',');

    // Expecting 10 columns: timestamp + 9 features
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
