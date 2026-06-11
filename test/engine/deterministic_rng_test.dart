import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/deterministic_rng.dart';

void main() {
  group('DeterministicRng', () {
    test('produces the locked golden sequences', () {
      // GOLDEN VECTORS: these lock the PRNG output forever. If this test
      // fails, daily puzzles and ciphers would change for every player —
      // never "fix" the expectation, fix the regression.
      final rng1 = DeterministicRng(1);
      expect(
        List.generate(5, (_) => rng1.nextUint32()),
        [270369, 67634689, 2647435461, 307599695, 2398689233],
      );
      final rng2 = DeterministicRng(123456789);
      expect(
        List.generate(5, (_) => rng2.nextUint32()),
        [2714967881, 2238813396, 1250077441, 3820100336, 3177519686],
      );
      final rng3 = DeterministicRng(0xDEADBEEF);
      expect(
        List.generate(5, (_) => rng3.nextUint32()),
        [1199382711, 2384302402, 3129746520, 4276113467, 1745748808],
      );
    });

    test('same seed, same sequence', () {
      final a = DeterministicRng(42);
      final b = DeterministicRng(42);
      for (var i = 0; i < 100; i++) {
        expect(a.nextUint32(), b.nextUint32());
      }
    });

    test('zero seed is remapped, not stuck', () {
      final rng = DeterministicRng(0);
      final values = List.generate(10, (_) => rng.nextUint32()).toSet();
      expect(values.length, greaterThan(1));
    });

    test('nextInt stays in range', () {
      final rng = DeterministicRng(7);
      for (var i = 0; i < 1000; i++) {
        final v = rng.nextInt(26);
        expect(v, inInclusiveRange(0, 25));
      }
    });
  });

  group('fmix32 / stableStringHash', () {
    test('fmix32 golden values', () {
      expect(fmix32(0), 0);
      expect(fmix32(1), 1364076727);
      expect(fmix32(20260611), 1053797001);
      expect(fmix32(20260611), isNot(fmix32(20260612)));
    });

    test('stableStringHash is order-sensitive and stable', () {
      expect(stableStringHash('abc'), 440920331);
      expect(stableStringHash('abc'), isNot(stableStringHash('acb')));
      expect(stableStringHash(''), 0x811C9DC5);
    });
  });
}
