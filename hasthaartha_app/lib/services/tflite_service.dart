import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  Interpreter? _interpreter;

  // Update these if your model differs
  static const int T = 512;
  static const int F = 9;

  Future<void> loadModelIfNeeded() async {
    if (_interpreter != null) return;

    _interpreter = await Interpreter.fromAsset(
      'models/cnn_lstm_with_idle_fp32.tflite',
      options: InterpreterOptions()..threads = 4,
    );
  }

  /// Runs ONE dummy inference and returns {topIndex, topProb, probs}
  Future<({int topIndex, double topProb, List<double> probs})> runDummy() async {
    await loadModelIfNeeded();
    final interpreter = _interpreter!;

    // Input shape: [1, 512, 9]
    final rnd = Random();
    final input = List.generate(
      1,
      (_) => List.generate(
        T,
        (_) => List.generate(F, (_) => 0.02 * (rnd.nextDouble() - 0.5)),
      ),
    );

    // Output shape: [1, C]
    final outShape = interpreter.getOutputTensor(0).shape;
    final c = outShape.last;
    final output = List.generate(1, (_) => List.filled(c, 0.0));

    interpreter.run(input, output);

    final probs = output[0].map((e) => (e as num).toDouble()).toList();

    int bestIdx = 0;
    double bestVal = probs.isNotEmpty ? probs[0] : 0.0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > bestVal) {
        bestVal = probs[i];
        bestIdx = i;
      }
    }

    return (topIndex: bestIdx, topProb: bestVal, probs: probs);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
