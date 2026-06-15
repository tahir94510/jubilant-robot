import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/alphabet.dart';
import 'package:quotecrack/engine/difficulty.dart';

void main() {
  group('difficultyScore', () {
    test('shorter texts score harder', () {
      const long =
          'The only way to have a friend is to be one and the best time to '
          'plant a tree was twenty years ago so begin today my friend';
      const short = 'Fortune favors the bold';
      expect(difficultyScore(short), greaterThan(difficultyScore(long)));
    });

    test('rare letters score harder than common ones', () {
      // Same structure, one swaps in J/Q/X/Z-heavy words.
      const common = 'A SEA OF TEA AND SUN';
      const rare = 'A JAZZ OF QUIZ AND LYNX';
      expect(difficultyScore(rare), greaterThan(difficultyScore(common)));
    });

    test('few short foothold words scores harder', () {
      const footholds = 'IT IS A DAY TO GO ON AND ON';
      const dense = 'TWILIGHT GATHERS QUIETLY YONDER';
      expect(difficultyScore(dense), greaterThan(difficultyScore(footholds)));
    });

    test('score stays within 0-100', () {
      const samples = [
        'Go.',
        'Less is more.',
        'The quick brown fox jumps over the lazy dog near the riverbank '
            'every single morning before the village wakes and the bells ring',
      ];
      for (final s in samples) {
        final score = difficultyScore(s);
        expect(score, inInclusiveRange(0, 100));
      }
    });

    test('rarity uses each language own frequencies, not English', () {
      // Turkish words made of letters that are COMMON in Turkish (a, e, i, n,
      // l, r) must NOT be judged rare. Scored with the English table, the
      // Turkish-specific 'İ' would be unknown and inflate rarity; with the
      // Turkish table it is one of the most common letters.
      const trCommon = 'ANNE ELİNİ NİNE İLE';
      final tr = difficultyScore(trCommon, alphabet: Alphabets.tr);
      // A Turkish phrase loaded with genuinely rare Turkish letters (j, f, ğ).
      const trRare = 'JÖF FÜJ ĞAJ FÖJ';
      final trRareScore = difficultyScore(trRare, alphabet: Alphabets.tr);
      expect(trRareScore, greaterThan(tr));
    });

    test('every alphabet scores within 0-100', () {
      const samples = {
        'tr': 'Damlaya damlaya göl olur, aka aka sel olur.',
        'es': 'No hay mal que por bien no venga.',
        'de': 'Übung macht den Meister.',
        'fr': 'Petit à petit, l’oiseau fait son nid.',
        'it': 'Chi va piano va sano e va lontano.',
        'pt': 'Água mole em pedra dura tanto bate até que fura.',
      };
      samples.forEach((code, text) {
        final score = difficultyScore(
          text,
          alphabet: Alphabets.forLocale(code),
        );
        expect(score, inInclusiveRange(0, 100), reason: '$code out of range');
      });
    });

    test('buckets cover all thresholds', () {
      expect(difficultyBucket(30), Difficulty.beginner);
      expect(difficultyBucket(50), Difficulty.casual);
      expect(difficultyBucket(58), Difficulty.skilled);
      expect(difficultyBucket(70), Difficulty.expert);
    });
  });
}
