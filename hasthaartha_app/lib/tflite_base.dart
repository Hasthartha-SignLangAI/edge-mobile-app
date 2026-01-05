import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteBaseModel {
  late final Interpreter _interpreter;
  bool _loaded = false;

  static const int T = 512;
  static const int F = 9;

  bool get isLoaded => _loaded;

 Future<void> load() async {
  try {
    final bytes = await rootBundle.load(
      'assets/models/cnn_lstm_with_idle_fp32.tflite',
    );
    print('✅ model bytes = ${bytes.lengthInBytes}');

    final options = InterpreterOptions()..threads = 4;
    options.addDelegate(FlexDelegate()); // ⭐ REQUIRED

    _interpreter = await Interpreter.fromAsset(
      'assets/models/cnn_lstm_with_idle_fp32.tflite',
      options: options,
    );

    final inT = _interpreter.getInputTensor(0);
    final outT = _interpreter.getOutputTensor(0);

    print('✅ Input: shape=${inT.shape} type=${inT.type}');
    print('✅ Output: shape=${outT.shape} type=${outT.type}');

    _loaded = true;
  } catch (e, st) {
    print("❌ Interpreter load failed: $e");
    print(st);
    rethrow;
  }
}

  List<double> predictDummy() {
    // [1, 512, 9]
    final input = List.generate(
      1,
      (_) => List.generate(
        T,
        (_) => List.generate(F, (_) => 0.02 * (Random().nextDouble() - 0.5)),
      ),
    );

    final outShape = _interpreter.getOutputTensor(0).shape; // [1, C]
    final c = outShape.last;
    final output = List.generate(1, (_) => List.filled(c, 0.0));

    _interpreter.run(input, output);
    return output[0].cast<double>();
  }

  void close() {
    if (_loaded) _interpreter.close();
    _loaded = false;
  }
}
