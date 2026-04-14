import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hasthaartha_app/main.dart';
import 'package:hasthaartha_app/models/gesture_data.dart';
import 'package:hasthaartha_app/services/onnx_servce.dart';
import 'package:hasthaartha_app/models/sentence_state.dart';
import 'package:hasthaartha_app/models/translation_state.dart';
import 'package:hasthaartha_app/models/translation_state.dart' as app_state;
import 'package:hasthaartha_app/providers/local_repo_provider.dart';
import 'package:hasthaartha_app/providers/sentence_providers.dart';
import 'package:hasthaartha_app/providers/translation_providers.dart';
import 'package:hasthaartha_app/services/speech_service.dart';
import 'package:hasthaartha_app/utils/sinhala_mapper.dart';
import 'package:hasthaartha_app/widgets/debug_panel.dart';
import 'package:hasthaartha_app/widgets/speech_waveform.dart';

/// Real-Time Translation Screen – supports both Word Mode and Sentence Mode.
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

  /// Whether we already handled speech/history for the current finalized
  /// sentence. Reset when the sentence builder emits a non-finalized state.
  bool _sentenceSpeechHandled = false;

  StreamSubscription? _predSub;
  StreamSubscription? _sentenceSub;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _speechService = SpeechService();

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
          parent: _buttonPulseController, curve: Curves.easeInOut),
    );

    // ── BLE prediction stream ──────────────────────────────────────────────
    final bleService = ref.read(blePipelineProvider);

    _predSub = bleService.gestureStream.stream.listen(_onPrediction);

    // ── Sentence finalization watcher ──────────────────────────────────────
    // We subscribe to the sentence stream here so we can trigger side-effects
    // (TTS + history) as soon as finalization happens, even when the screen
    // widget isn't rebuilding.
    final builder = ref.read(sentenceBuilderProvider);
    _sentenceSub = builder.stateStream.listen(_onSentenceStateChange);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _predSub?.cancel();
    _sentenceSub?.cancel();
    _buttonPulseController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  // ── Prediction handler ──────────────────────────────────────────────────

  Future<void> _onPrediction(PredictionResult prediction) async {
    final isActive = ref.read(translationStateProvider).isActive;
    if (!isActive) return;

    final sinhalaWord = SinhalaMapper.toSinhala(prediction.label);
    final mode = ref.read(translationModeProvider);

    if (mode == TranslationMode.word) {
      // ── Word Mode: existing behavior completely unchanged ──────────────
      final repo = ref.read(localRepoProvider);
      await repo.addHistory(
        gestureLabel: prediction.label,
        sinhalaText: sinhalaWord,
        confidence: prediction.confidence,
      );

      final gesture = GestureData(
        label: prediction.label,
        sinhalaText: sinhalaWord,
        confidence: prediction.confidence,
        keypoints: const [],
        timestamp: DateTime.now(),
      );

      ref.read(currentGestureProvider.notifier).updateGesture(gesture);

      if (prediction.confidence >= 0.80) {
        final volume = ref.read(volumeProvider);
        await _speechService.speak(gesture.sinhalaText, volume);
        await _speechService.provideHapticFeedback(prediction.confidence);
      }
    } else {
      // ── Sentence Mode: route to sentence builder ───────────────────────
      // SentenceBuilderService applies its own dedup + cooldown filters.
      final builder = ref.read(sentenceBuilderProvider);
      builder.addWord(sinhalaWord, prediction.confidence);

      // Keep currentGestureProvider updated so we can show the latest word
      // as a "live hint" inside the sentence display card.
      if (sinhalaWord.trim().isNotEmpty) {
        final gesture = GestureData(
          label: prediction.label,
          sinhalaText: sinhalaWord,
          confidence: prediction.confidence,
          keypoints: const [],
          timestamp: DateTime.now(),
        );
        ref.read(currentGestureProvider.notifier).updateGesture(gesture);
      }
    }
  }

  // ── Sentence finalization side-effects ───────────────────────────────────

  Future<void> _onSentenceStateChange(SentenceState state) async {
    if (!state.isFinalized) {
      // New word added (or reset) — allow speaking again after next finalize.
      _sentenceSpeechHandled = false;
      return;
    }

    if (_sentenceSpeechHandled) return; // already handled this finalization
    if (state.isEmpty) return;

    _sentenceSpeechHandled = true;

    // Speak the complete sentence once.
    final volume = ref.read(volumeProvider);
    await _speechService.speak(state.sentence, volume);
    HapticFeedback.mediumImpact();

    // Save one history entry for the entire finalized sentence.
    final repo = ref.read(localRepoProvider);
    await repo.addHistory(
      gestureLabel: 'sentence',
      sinhalaText: state.sentence,
      confidence: state.avgConfidence,
    );
  }

  // ── UI actions ──────────────────────────────────────────────────────────

  void _handleConnectionIconTap() {
    final now = DateTime.now();
    if (_lastConnectionTap != null &&
        now.difference(_lastConnectionTap!).inSeconds > 1) {
      _connectionIconTapCount = 0;
    }
    _connectionIconTapCount++;
    _lastConnectionTap = now;
    if (_connectionIconTapCount >= 3) {
      ref.read(translationStateProvider.notifier).toggleDebugMode();
      HapticFeedback.mediumImpact();
      _connectionIconTapCount = 0;
    }
  }

  Future<void> _toggleTranslation() async {
    final state = ref.read(translationStateProvider);
    final bleService = ref.read(blePipelineProvider);

    if (state.isActive) {
      // ── Stop ──────────────────────────────────────────────────────────────
      final mode = ref.read(translationModeProvider);
      if (mode == TranslationMode.sentence) {
        // Force-finalize so the sentence is not lost on Stop.
        ref.read(sentenceBuilderProvider).finalize();
      }
      ref.read(translationStateProvider.notifier).stopTranslation();
      _speechService.stop();
      ref.read(currentGestureProvider.notifier).clear();

      // Tell the ESP32 to stop sending frames.
      await bleService.stopStreaming();
    } else {
      // ── Start ─────────────────────────────────────────────────────────────
      // Tell the ESP32 to start sending frames before activating translation.
      try {
        await bleService.startStreaming();
      } catch (e) {
        // Device not connected or characteristics not ready.
        ref.read(translationStateProvider.notifier).setError(
          'Could not start streaming: $e',
        );
        return;
      }

      ref.read(translationStateProvider.notifier).startTranslation();
      HapticFeedback.mediumImpact();
    }
  }


  void _clearSentence() {
    ref.read(sentenceBuilderProvider).reset();
    ref.read(currentGestureProvider.notifier).clear();
    _sentenceSpeechHandled = false;
    _speechService.stop();
  }

  void _speakSentenceNow(String sentence) {
    final volume = ref.read(volumeProvider);
    _speechService.speak(sentence, volume);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationStateProvider);
    final currentGesture = ref.watch(currentGestureProvider);
    final volume = ref.watch(volumeProvider);
    final mode = ref.watch(translationModeProvider);
    final sentenceAsync = ref.watch(sentenceStateProvider);
    final sentenceState = sentenceAsync.valueOrNull ?? SentenceState.empty();

    final connAsync = ref.watch(bleConnectionProvider);
    final isConnected = connAsync.when(
      data: (s) => s.isConnected,
      loading: () => false,
      error: (_, _) => false,
    );

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F7FF), Color(0xFFDEEDFF), Color(0xFFC7E2FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(
                app_state.BLEConnectionState(isConnected: isConnected),
                mode,
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ── Main display: adapts to mode ──────────────────
                      mode == TranslationMode.word
                          ? _buildGestureLabel(currentGesture)
                          : _buildSentenceDisplay(sentenceState, currentGesture),

                      const SizedBox(height: 20),

                      _buildSpeechWaveform(),

                      const SizedBox(height: 30),

                      _buildPrimaryButton(translationState),

                      const SizedBox(height: 20),

                      _buildControls(volume, mode, sentenceState),

                      const SizedBox(height: 20),

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

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(
      app_state.BLEConnectionState bleConnection, TranslationMode mode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF0D47A1),
                ),
              ),
              GestureDetector(
                onTap: _handleConnectionIconTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                        bleConnection.isConnected
                            ? 'Connected'
                            : 'Not Connected',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1A1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_rounded,
                    color: Color(0xFF0D47A1)),
              ),
            ],
          ),

          // ── Mode toggle ─────────────────────────────────────────────────
          const SizedBox(height: 12),
          _buildModeToggle(mode),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildModeToggle(TranslationMode mode) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeTab(
            label: 'Word',
            icon: Icons.text_fields_rounded,
            isSelected: mode == TranslationMode.word,
            onTap: () {
              ref.read(translationModeProvider.notifier).state =
                  TranslationMode.word;
              // Clear sentence state when switching back to word mode
              ref.read(sentenceBuilderProvider).reset();
              ref.read(currentGestureProvider.notifier).clear();
              _sentenceSpeechHandled = false;
            },
          ),
          const SizedBox(width: 4),
          _modeTab(
            label: 'Sentence',
            icon: Icons.short_text_rounded,
            isSelected: mode == TranslationMode.sentence,
            onTap: () {
              ref.read(translationModeProvider.notifier).state =
                  TranslationMode.sentence;
              ref.read(currentGestureProvider.notifier).clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _modeTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF1565C0),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : const Color(0xFF1565C0),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Word mode display ────────────────────────────────────────────────────

  Widget _buildGestureLabel(GestureData gesture) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(gesture.label),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              gesture.label.isEmpty ? 'Ready to Translate' : gesture.label,
              style: GoogleFonts.inter(
                color: Colors.black.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              gesture.sinhalaText.isEmpty
                  ? 'අත් ඉඟි පරිවර්තනය'
                  : gesture.sinhalaText,
              style: GoogleFonts.notoSansSinhala(
                color: const Color(0xFF0D47A1),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (gesture.confidence > 0) ...[
              const SizedBox(height: 12),
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

  // ── Sentence mode display ────────────────────────────────────────────────

  Widget _buildSentenceDisplay(SentenceState state, GestureData latestGesture) {
    final hasSentence = state.isNotEmpty;
    final isFinalized = state.isFinalized;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFinalized
              ? const Color(0xFF4CAF50).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.9),
          width: isFinalized ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFinalized
                ? const Color(0xFF4CAF50).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: label + finalized badge
          Row(
            children: [
              Text(
                'Sentence',
                style: GoogleFonts.inter(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (isFinalized)
                GestureDetector(
                  onTap: hasSentence
                      ? () => _speakSentenceNow(state.sentence)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF4CAF50).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded,
                            size: 13, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          'Spoken',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (hasSentence)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color:
                              const Color(0xFF1565C0).withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Listening…',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1565C0).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Sentence text
          Text(
            hasSentence ? state.sentence : 'අත් ඉඟි පරිවර්තනය',
            style: GoogleFonts.notoSansSinhala(
              color: hasSentence
                  ? const Color(0xFF0D47A1)
                  : const Color(0xFF0D47A1).withValues(alpha: 0.35),
              fontSize: 34,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          // Latest word hint (while listening)
          if (!isFinalized &&
              latestGesture.sinhalaText.isNotEmpty &&
              hasSentence) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.arrow_forward_rounded,
                    size: 14,
                    color: Colors.black.withValues(alpha: 0.35)),
                const SizedBox(width: 4),
                Text(
                  latestGesture.sinhalaText,
                  style: GoogleFonts.notoSansSinhala(
                    color: Colors.black.withValues(alpha: 0.35),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          // Word count + avg confidence
          if (hasSentence) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: _getConfidenceColor(state.avgConfidence), size: 14),
                const SizedBox(width: 5),
                Text(
                  '${state.words.length} word${state.words.length == 1 ? '' : 's'} · ${(state.avgConfidence * 100).toStringAsFixed(0)}% avg',
                  style: GoogleFonts.inter(
                    color: _getConfidenceColor(state.avgConfidence),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Speech waveform ──────────────────────────────────────────────────────

  Widget _buildSpeechWaveform() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.volume_up_rounded,
                color: const Color(0xFF0D47A1).withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Speech Output',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SpeechWaveform(
            waveformData: _speechService.currentWaveform,
            isPlaying: _speechService.currentWaveform.isNotEmpty,
            color: const Color(0xFF1976D2),
            height: 60,
          ),
        ],
      ),
    );
  }

  // ── Primary button ───────────────────────────────────────────────────────

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

  // ── Controls ─────────────────────────────────────────────────────────────

  Widget _buildControls(
      double volume, TranslationMode mode, SentenceState sentenceState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Volume slider
          Row(
            children: [
              Icon(
                Icons.volume_down_rounded,
                color: const Color(0xFF0D47A1).withValues(alpha: 0.7),
              ),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    ref.read(volumeProvider.notifier).state = value;
                  },
                  activeColor: const Color(0xFF1976D2),
                  inactiveColor:
                      const Color(0xFF1976D2).withValues(alpha: 0.2),
                ),
              ),
              Icon(
                Icons.volume_up_rounded,
                color: const Color(0xFF0D47A1).withValues(alpha: 0.7),
              ),
            ],
          ),

          // Sentence mode action row
          if (mode == TranslationMode.sentence) ...[
            const Divider(height: 8),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Clear button
                _controlButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Clear',
                  color: const Color(0xFFF44336),
                  onTap: sentenceState.isNotEmpty ? _clearSentence : null,
                ),
                // Speak Now button
                _controlButton(
                  icon: Icons.record_voice_over_rounded,
                  label: 'Speak Now',
                  color: const Color(0xFF1565C0),
                  onTap: sentenceState.isNotEmpty
                      ? () => _speakSentenceNow(sentenceState.sentence)
                      : null,
                ),
                // Finalize button
                _controlButton(
                  icon: Icons.check_rounded,
                  label: 'Finalize',
                  color: const Color(0xFF388E3C),
                  onTap: (sentenceState.isNotEmpty && !sentenceState.isFinalized)
                      ? () => ref.read(sentenceBuilderProvider).finalize()
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF4CAF50);
    if (confidence >= 0.6) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  List<double> _generateMockEMGData() =>
      List.generate(50, (i) => (i % 10 - 5) / 10);

  List<double> _generateMockIMUData() =>
      List.generate(50, (i) => (i % 8 - 4) / 8);
}