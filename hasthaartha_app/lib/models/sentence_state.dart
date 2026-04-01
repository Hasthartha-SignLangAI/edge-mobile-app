/// Translation mode: word-by-word or sentence accumulation.
enum TranslationMode { word, sentence }

/// Immutable snapshot of the sentence buffer.
class SentenceState {
  /// Sinhala words accepted so far (de-duplicated, filtered).
  final List<String> words;

  /// True once the idle-timeout fires and the sentence is considered complete.
  final bool isFinalized;

  /// Average confidence of all accepted words.
  final double avgConfidence;

  const SentenceState({
    required this.words,
    required this.isFinalized,
    required this.avgConfidence,
  });

  /// Factory for an empty (reset) state.
  factory SentenceState.empty() {
    return const SentenceState(
      words: [],
      isFinalized: false,
      avgConfidence: 0.0,
    );
  }

  /// The words joined into a single space-delimited sentence.
  String get sentence => words.join(' ');

  bool get isEmpty => words.isEmpty;
  bool get isNotEmpty => words.isNotEmpty;

  SentenceState copyWith({
    List<String>? words,
    bool? isFinalized,
    double? avgConfidence,
  }) {
    return SentenceState(
      words: words ?? this.words,
      isFinalized: isFinalized ?? this.isFinalized,
      avgConfidence: avgConfidence ?? this.avgConfidence,
    );
  }
}
