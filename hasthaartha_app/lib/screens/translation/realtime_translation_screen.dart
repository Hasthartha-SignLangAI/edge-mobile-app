import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/main.dart';
import 'package:hasthaartha_app/models/gesture_data.dart';
import 'package:hasthaartha_app/models/translation_state.dart';
import 'package:hasthaartha_app/models/translation_state.dart' as app_state;
import 'package:hasthaartha_app/providers/translation_providers.dart';
import 'package:hasthaartha_app/services/speech_service.dart';
import 'package:hasthaartha_app/widgets/debug_panel.dart';
import 'package:hasthaartha_app/widgets/gesture_visualizer.dart';
import 'package:hasthaartha_app/widgets/speech_waveform.dart';

/// Real-Time Translation Screen - Main screen of the app
/// Provides low-latency gesture recognition with speech feedback
class RealtimeTranslationScreen extends ConsumerStatefulWidget {
  const RealtimeTranslationScreen({super.key});

  @override
  ConsumerState<RealtimeTranslationScreen> createState() =>
      _RealtimeTranslationScreenState();
}

class _RealtimeTranslationScreenState
    extends ConsumerState<RealtimeTranslationScreen>
    with TickerProviderStateMixin {
  late SpeechService _speechService;
  late AnimationController _buttonPulseController;
  late Animation<double> _buttonPulseAnimation;

  int _connectionIconTapCount = 0;
  DateTime? _lastConnectionTap;

  StreamSubscription? _predSub;

  @override
  void initState() {
    super.initState();

    // Lock to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _speechService = SpeechService();

    // Setup button pulse animation
    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut),
    );

    // ✅ Listen to BLE prediction stream (from BlePipelineService)
    final bleService = ref.read(blePipelineProvider);

    _predSub = bleService.gestureStream.stream.listen((prediction) {
      // Only update UI when translation is active
      final isActive = ref.read(translationStateProvider).isActive;
      if (!isActive) return;

      // Convert PredictionResult -> GestureData
      // NOTE: If you have a Sinhala mapping table, replace sinhalaText here.
      final gesture = GestureData(
        label: prediction.label,
        sinhalaText: prediction.label,
        confidence: prediction.confidence,
        keypoints: _generateMockKeypoints(),
        timestamp: DateTime.now(),
      );

      ref.read(currentGestureProvider.notifier).updateGesture(gesture);

      // Auto speech on high confidence
      if (prediction.confidence >= 0.80) {
        final volume = ref.read(volumeProvider);
        _speechService.speak(gesture.sinhalaText, volume);
        _speechService.provideHapticFeedback(prediction.confidence);
      }
    });
  }

  @override
  void dispose() {
    // restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _predSub?.cancel();
    _buttonPulseController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _handleConnectionIconTap() {
    final now = DateTime.now();

    // Reset counter if more than 1 second since last tap
    if (_lastConnectionTap != null &&
        now.difference(_lastConnectionTap!).inSeconds > 1) {
      _connectionIconTapCount = 0;
    }

    _connectionIconTapCount++;
    _lastConnectionTap = now;

    // Triple tap to toggle debug mode
    if (_connectionIconTapCount >= 3) {
      ref.read(translationStateProvider.notifier).toggleDebugMode();
      HapticFeedback.mediumImpact();
      _connectionIconTapCount = 0;
    }
  }

  void _toggleTranslation() {
    final state = ref.read(translationStateProvider);

    if (state.isActive) {
      // Stop translation
      ref.read(translationStateProvider.notifier).stopTranslation();
      _speechService.stop();
      ref.read(currentGestureProvider.notifier).clear();
    } else {
      // Start translation
      ref.read(translationStateProvider.notifier).startTranslation();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationStateProvider);
    final currentGesture = ref.watch(currentGestureProvider);
    final volume = ref.watch(volumeProvider);

    // ✅ Connection state from BlePipelineService stream
    final connAsync = ref.watch(bleConnectionProvider);
    final isConnected = connAsync.when(
      data: (s) => s.isConnected,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Deep blue
              Color(0xFF1565C0),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with connection status and settings
              _buildHeader(
                app_state.BLEConnectionState(isConnected: isConnected),
              ),

              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Gesture Visualization
                      _buildGestureVisualization(currentGesture),

                      const SizedBox(height: 30),

                      // Predicted Gesture Label (Large Sinhala Text)
                      _buildGestureLabel(currentGesture),

                      const SizedBox(height: 20),

                      // Speech Waveform
                      _buildSpeechWaveform(),

                      const SizedBox(height: 30),

                      // Start/Stop Button
                      _buildPrimaryButton(translationState),

                      const SizedBox(height: 20),

                      // Volume and Controls
                      _buildControls(volume),

                      const SizedBox(height: 20),

                      // Debug Panel
                      DebugPanel(
                        isVisible: translationState.isDebugMode,
                        fps: ref.watch(fpsCounterProvider),
                        latencyMs: ref.watch(latencyMetricsProvider),
                        emgData: _generateMockEMGData(),
                        imuData: _generateMockIMUData(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(app_state.BLEConnectionState bleConnection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),

          // Connection status
          GestureDetector(
            onTap: _handleConnectionIconTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    bleConnection.isConnected
                        ? Icons.bluetooth_connected_rounded
                        : Icons.bluetooth_disabled_rounded,
                    color: bleConnection.isConnected
                        ? const Color(0xFF4CAF50)
                        : Colors.orangeAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bleConnection.isConnected ? 'Connected' : 'Not Connected',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings button
          IconButton(
            onPressed: () {
              // Navigate to settings
            },
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureVisualization(GestureData gesture) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: GestureVisualizer(
        gestureData: gesture,
        size: MediaQuery.of(context).size.width - 80,
      ),
    );
  }

  Widget _buildGestureLabel(GestureData gesture) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(gesture.label),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // English label
            Text(
              gesture.label.isEmpty ? 'Ready to Translate' : gesture.label,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Sinhala text (large, high contrast)
            Text(
              gesture.sinhalaText.isEmpty ? 'අත් ඉඟි පරිවර්තනය' : gesture.sinhalaText,
              style: GoogleFonts.notoSansSinhala(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (gesture.confidence > 0) ...[
              const SizedBox(height: 12),
              // Confidence indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: _getConfidenceColor(gesture.confidence),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(gesture.confidence * 100).toStringAsFixed(0)}% confident',
                    style: GoogleFonts.inter(
                      color: _getConfidenceColor(gesture.confidence),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechWaveform() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.volume_up_rounded,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Speech Output',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SpeechWaveform(
            waveformData: _speechService.currentWaveform,
            isPlaying: _speechService.currentWaveform.isNotEmpty,
            color: const Color(0xFF64B5F6),
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(TranslationState state) {
    final isActive = state.isActive;

    return AnimatedBuilder(
      animation: _buttonPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? 1.0 : _buttonPulseAnimation.value,
          child: GestureDetector(
            onTap: _toggleTranslation,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                gradient: LinearGradient(
                  colors: isActive
                      ? [const Color(0xFFF44336), const Color(0xFFE57373)]
                      : [const Color(0xFF4CAF50), const Color(0xFF81C784)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isActive
                            ? const Color(0xFFF44336)
                            : const Color(0xFF4CAF50))
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isActive ? 'STOP TRANSLATION' : 'START TRANSLATION',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(double volume) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.volume_down_rounded, color: Colors.white70),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    ref.read(volumeProvider.notifier).state = value;
                  },
                  activeColor: const Color(0xFF64B5F6),
                  inactiveColor: Colors.white24,
                ),
              ),
              const Icon(Icons.volume_up_rounded, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF4CAF50);
    if (confidence >= 0.6) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  // Mock data generators for debug mode
  List<double> _generateMockEMGData() {
    return List.generate(50, (i) => (i % 10 - 5) / 10);
  }

  List<double> _generateMockIMUData() {
    return List.generate(50, (i) => (i % 8 - 4) / 8);
  }

  List<HandKeypoint> _generateMockKeypoints() {
  // Generates stable dummy hand skeleton so visualizer doesn't break
    return List.generate(
      21,
      (i) => HandKeypoint(
        x: 0.5 + (i % 5) * 0.02,
        y: 0.5 + (i ~/ 5) * 0.02,
        confidence: 1.0,
        z: 0.0,
      ),
    );
  }
}