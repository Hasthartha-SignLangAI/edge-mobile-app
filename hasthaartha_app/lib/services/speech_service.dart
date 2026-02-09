import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service for text-to-speech synthesis and audio playback
/// Handles Sinhala speech synthesis with waveform data
class SpeechService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Mock waveform data for visualization
  List<double> _currentWaveform = [];

  List<double> get currentWaveform => _currentWaveform;

  /// Play speech for given Sinhala text
  /// In production, this would use a TTS engine or pre-recorded audio files
  Future<void> speak(String sinhalaText, double volume) async {
    try {
      // Set volume
      await _audioPlayer.setVolume(volume);

      // In production:
      // 1. Convert Sinhala text to speech using TTS engine
      // 2. Or play pre-recorded audio file for common gestures
      // 3. Extract waveform data for visualization

      // For now, play a placeholder sound
      // await _audioPlayer.play(AssetSource('audio/placeholder.mp3'));

      // Generate mock waveform data
      _generateMockWaveform();

      // Simulate speech playback
      await Future.delayed(const Duration(milliseconds: 800));

      print('🔊 SPEECH: Playing "$sinhalaText" at volume $volume');
    } catch (e) {
      print('❌ SPEECH ERROR: $e');
      HapticFeedback.heavyImpact(); // Error feedback
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentWaveform = [];
  }

  /// Generate mock waveform data for visualization
  void _generateMockWaveform() {
    _currentWaveform = List.generate(50, (i) {
      final t = i / 50.0;
      // Simulate speech envelope: attack, sustain, decay
      if (t < 0.1) {
        return t * 10; // Attack
      } else if (t < 0.7) {
        return 0.8 + (0.2 * (i % 5) / 5); // Sustain with variation
      } else {
        return 1.0 - ((t - 0.7) / 0.3); // Decay
      }
    });
  }

  /// Provide haptic feedback for gesture recognition
  Future<void> provideHapticFeedback(double confidence) async {
    if (confidence >= 0.8) {
      await HapticFeedback.mediumImpact(); // Strong confidence
    } else if (confidence >= 0.6) {
      await HapticFeedback.lightImpact(); // Medium confidence
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
