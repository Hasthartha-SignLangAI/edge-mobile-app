import 'package:flutter_test/flutter_test.dart';
import 'package:hasthaartha_app/services/sentence_builder_service.dart';
import 'package:hasthaartha_app/models/sentence_state.dart';

void main() {
  group('SentenceBuilderService', () {
    late SentenceBuilderService service;

    setUp(() {
      service = SentenceBuilderService(
        idleTimeout: const Duration(milliseconds: 200),
        wordCooldown: const Duration(milliseconds: 100),
      );
    });

    tearDown(() {
      service.dispose();
    });

    // ── Filtering ──────────────────────────────────────────────────────────

    test('empty string is discarded', () {
      service.addWord('', 0.9);
      expect(service.currentState.words, isEmpty);
    });

    test('whitespace-only string is discarded', () {
      service.addWord('   ', 0.9);
      expect(service.currentState.words, isEmpty);
    });

    // ── Accumulation ───────────────────────────────────────────────────────

    test('valid words accumulate in order', () async {
      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('හොඳයි', 0.85);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('නරකයි', 0.7);

      expect(service.currentState.words, ['ස්තූතියි', 'හොඳයි', 'නරකයි']);
    });

    test('sentence is words joined by spaces', () async {
      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('හොඳයි', 0.85);

      expect(service.currentState.sentence, 'ස්තූතියි හොඳයි');
    });

    // ── Consecutive duplicate filter ───────────────────────────────────────

    test('consecutive duplicate word is rejected', () async {
      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('ස්තූතියි', 0.9); // same as last — should be ignored

      expect(service.currentState.words.length, 1);
    });

    test('non-consecutive duplicates are accepted', () async {
      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('හොඳයි', 0.85);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('ස්තූතියි', 0.9); // different from last — OK

      expect(service.currentState.words.length, 3);
    });

    // ── Cooldown ───────────────────────────────────────────────────────────

    test('word arriving within cooldown is rejected', () {
      service.addWord('ස්තූතියි', 0.9);
      // Immediately add a different word without waiting past cooldown
      service.addWord('හොඳයි', 0.85);

      expect(service.currentState.words.length, 1);
    });

    test('word arriving after cooldown is accepted', () async {
      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 120)); // past cooldown (100 ms)
      service.addWord('හොඳයි', 0.85);

      expect(service.currentState.words.length, 2);
    });

    // ── Average confidence ─────────────────────────────────────────────────

    test('avgConfidence is mean of accepted words confidences', () async {
      service.addWord('ස්තූතියි', 1.0);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('හොඳයි', 0.5);

      expect(service.currentState.avgConfidence, closeTo(0.75, 0.001));
    });

    // ── Finalization ───────────────────────────────────────────────────────

    test('isFinalized becomes true after idle timeout', () async {
      service.addWord('ස්තූතියි', 0.9);
      expect(service.currentState.isFinalized, isFalse);

      await Future.delayed(const Duration(milliseconds: 250)); // past 200 ms timeout

      expect(service.currentState.isFinalized, isTrue);
    });

    test('idle timer resets when a new word is added', () async {
      service.addWord('ස්තූතියි', 0.9);

      await Future.delayed(const Duration(milliseconds: 150)); // almost at timeout
      service.addWord('හොඳයි', 0.85); // reset timer

      await Future.delayed(const Duration(milliseconds: 150)); // still not timed out
      // Timer was reset so still not finalized after 150 ms
      expect(service.currentState.isFinalized, isFalse);

      await Future.delayed(const Duration(milliseconds: 100)); // now past timeout
      expect(service.currentState.isFinalized, isTrue);
    });

    test('manual finalize() triggers finalization immediately', () {
      service.addWord('ස්තූතියි', 0.9);
      service.finalize();

      expect(service.currentState.isFinalized, isTrue);
    });

    test('finalize() on empty sentence does nothing', () {
      service.finalize();
      expect(service.currentState.isFinalized, isFalse);
    });

    // ── Reset ──────────────────────────────────────────────────────────────

    test('reset() clears all state', () async {
      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 250));
      expect(service.currentState.isFinalized, isTrue);

      service.reset();

      final s = service.currentState;
      expect(s.words, isEmpty);
      expect(s.isFinalized, isFalse);
      expect(s.avgConfidence, 0.0);
    });

    // ── Stream ─────────────────────────────────────────────────────────────

    test('stateStream emits on each accepted word', () async {
      final states = <SentenceState>[];
      final sub = service.stateStream.listen(states.add);

      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 120));
      service.addWord('හොඳයි', 0.85);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.length, 2);
      expect(states.last.words.length, 2);

      await sub.cancel();
    });

    test('stateStream emits finalized state after idle', () async {
      final states = <SentenceState>[];
      final sub = service.stateStream.listen(states.add);

      service.addWord('ස්තූතියි', 0.9);
      await Future.delayed(const Duration(milliseconds: 300));

      expect(states.any((s) => s.isFinalized), isTrue);

      await sub.cancel();
    });
  });
}
