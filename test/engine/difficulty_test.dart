import 'package:flutter_test/flutter_test.dart';
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

    test('buckets cover all thresholds', () {
      expect(difficultyBucket(30), Difficulty.beginner);
      expect(difficultyBucket(50), Difficulty.casual);
      expect(difficultyBucket(58), Difficulty.skilled);
      expect(difficultyBucket(70), Difficulty.expert);
    });
  });
}
