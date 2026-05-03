import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();

  List<double> _currentWaveform = [];
  List<double> get currentWaveform => _currentWaveform;

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;

    await _flutterTts.setLanguage("si-LK"); // Sinhala
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _initialized = true;
  }

  Future<void> speak(String sinhalaText, double volume) async {
    try {
      if (sinhalaText.isEmpty) return;

      await _init();
      await _flutterTts.setVolume(volume);

      await _flutterTts.stop();
      await _flutterTts.speak(sinhalaText);

      _generateMockWaveform();
    } catch (e) {
      print("❌ SPEECH ERROR: $e");
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _currentWaveform = [];
  }

  void _generateMockWaveform() {
    _currentWaveform = List.generate(50, (i) {
      final t = i / 50.0;
      if (t < 0.1) {
        return t * 10;
      } else if (t < 0.7) {
        return 0.8 + (0.2 * (i % 5) / 5);
      } else {
        return 1.0 - ((t - 0.7) / 0.3);
      }
    });
  }

  Future<void> provideHapticFeedback(double confidence) async {
    if (confidence >= 0.8) {
      await HapticFeedback.mediumImpact();
    } else if (confidence >= 0.6) {
      await HapticFeedback.lightImpact();
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}