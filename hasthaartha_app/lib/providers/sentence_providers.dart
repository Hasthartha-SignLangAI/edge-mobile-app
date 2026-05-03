import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hasthaartha_app/models/sentence_state.dart';
import 'package:hasthaartha_app/services/sentence_builder_service.dart';

// ── Translation mode ───────────────────────────────────────────────────────

/// Which mode the translation screen is currently operating in.
final translationModeProvider =
    StateProvider<TranslationMode>((ref) => TranslationMode.word);

// ── Sentence builder service ───────────────────────────────────────────────

/// Singleton [SentenceBuilderService]; disposed when the provider is released.
final sentenceBuilderProvider = Provider<SentenceBuilderService>((ref) {
  final service = SentenceBuilderService();
  ref.onDispose(service.dispose);
  return service;
});

// ── Live sentence state ────────────────────────────────────────────────────

/// Reactive [SentenceState] driven by the service's broadcast stream.
/// Starts with an empty (non-finalized) sentence.
final sentenceStateProvider = StreamProvider<SentenceState>((ref) {
  final builder = ref.watch(sentenceBuilderProvider);
  return builder.stateStream;
});
