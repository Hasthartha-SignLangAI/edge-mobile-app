import 'dart:async';

import 'package:hasthaartha_app/models/sentence_state.dart';

/// Manages sentence-level accumulation of predicted Sinhala words.
///
/// Responsibilities:
///   - Filter empty / UNKNOWN words (empty sinhala string)
///   - Consecutive-duplicate rejection (avoids recording the same word twice in a row)
///   - Per-word cooldown (800 ms) to absorb engine noise within a single gesture
///   - Idle-timer finalization (3 s of silence → sentence is complete)
///   - Broadcast state changes via [stateStream]
class SentenceBuilderService {
  // ── Configuration ────────────────────────────────────────────────────────
  final Duration idleTimeout;
  final Duration wordCooldown;

  // ── Internal state ────────────────────────────────────────────────────────
  final List<String> _words = [];
  final List<double> _confidences = [];

  String? _lastAcceptedWord;
  DateTime? _lastAcceptedAt;
  bool _isFinalized = false;

  Timer? _idleTimer;

  final StreamController<SentenceState> _controller =
      StreamController<SentenceState>.broadcast();

  // ── Public API ────────────────────────────────────────────────────────────

  SentenceBuilderService({
    this.idleTimeout = const Duration(seconds: 3),
    this.wordCooldown = const Duration(milliseconds: 800),
  });

  /// Live stream of [SentenceState] snapshots.
  Stream<SentenceState> get stateStream => _controller.stream;

  /// Synchronous snapshot of the current state (useful for one-time reads).
  SentenceState get currentState => SentenceState(
        words: List.unmodifiable(_words),
        isFinalized: _isFinalized,
        avgConfidence: _avgConf(),
      );

  /// Attempt to add a word to the sentence.
  ///
  /// The word is rejected (silently) if:
  ///   - It is empty (idle/UNKNOWN mapped to empty string)
  ///   - It equals the last accepted word (consecutive duplicate)
  ///   - It arrives within the cooldown window after the last accepted word
  ///
  /// If accepted the idle timer is reset.
  void addWord(String sinhalaWord, double confidence) {
    // 1. Discard empty words (idle / UNKNOWN mapping)
    if (sinhalaWord.trim().isEmpty) return;

    // 2. Consecutive duplicate filter
    if (sinhalaWord == _lastAcceptedWord) return;

    // 3. Per-word cooldown
    final now = DateTime.now();
    if (_lastAcceptedAt != null &&
        now.difference(_lastAcceptedAt!) < wordCooldown) {
      return;
    }

    // Accept
    _words.add(sinhalaWord);
    _confidences.add(confidence);
    _lastAcceptedWord = sinhalaWord;
    _lastAcceptedAt = now;
    _isFinalized = false;

    // Reset idle timer
    _idleTimer?.cancel();
    _idleTimer = Timer(idleTimeout, _finalize);

    _emit();
  }

  /// Force-finalize the current sentence immediately (e.g. user presses Stop).
  void finalize() {
    if (_words.isEmpty) return;
    _idleTimer?.cancel();
    _finalize();
  }

  /// Clear everything and return to an empty state.
  void reset() {
    _idleTimer?.cancel();
    _words.clear();
    _confidences.clear();
    _lastAcceptedWord = null;
    _lastAcceptedAt = null;
    _isFinalized = false;
    _emit();
  }

  void dispose() {
    _idleTimer?.cancel();
    _controller.close();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _finalize() {
    if (_words.isEmpty) return;
    _isFinalized = true;
    _emit();
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(currentState);
  }

  double _avgConf() {
    if (_confidences.isEmpty) return 0.0;
    return _confidences.reduce((a, b) => a + b) / _confidences.length;
  }
}
