import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/cipher.dart';

void main() {
  group('CipherMap', () {
    test('is a derangement bijection for 1000 seeds', () {
      for (var seed = 0; seed < 1000; seed++) {
        final map = CipherMap.fromSeed(seed);
        final outputs = <String>{};
        for (final plain in alphabet.split('')) {
          final cipher = map.encryptLetter(plain);
          expect(cipher, isNot(plain),
              reason: 'seed $seed: $plain maps to itself');
          expect(alphabet.contains(cipher), isTrue);
          outputs.add(cipher);
          expect(map.decryptLetter(cipher), plain);
        }
        expect(outputs.length, 26, reason: 'seed $seed: not a bijection');
      }
    });

    test('same seed twice yields the identical mapping', () {
      final a = CipherMap.fromSeed(99);
      final b = CipherMap.fromSeed(99);
      for (final plain in alphabet.split('')) {
        expect(a.encryptLetter(plain), b.encryptLetter(plain));
      }
    });

    test('quote id determines its cipher', () {
      final a = CipherMap.forQuoteId('wis-001');
      final b = CipherMap.forQuoteId('wis-001');
      final c = CipherMap.forQuoteId('wis-002');
      expect(a.encrypt('HELLO WORLD'), b.encrypt('HELLO WORLD'));
      expect(a.encrypt('HELLO WORLD'), isNot(c.encrypt('HELLO WORLD')));
    });

    test('encrypt preserves non-letters and decrypt round-trips', () {
      final map = CipherMap.fromSeed(7);
      const plain = "WELL DONE IS BETTER THAN WELL SAID, ISN'T IT?";
      final cipher = map.encrypt(plain);
      expect(cipher.length, plain.length);
      expect(cipher, isNot(plain));
      for (var i = 0; i < plain.length; i++) {
        final ch = plain[i];
        if (!alphabet.contains(ch)) {
          expect(cipher[i], ch, reason: 'non-letter at $i changed');
        }
      }
      final decrypted = cipher
          .split('')
          .map((ch) => alphabet.contains(ch) ? map.decryptLetter(ch) : ch)
          .join();
      expect(decrypted, plain);
    });
  });

  group('normalizeQuoteText', () {
    test('uppercases and folds typographic punctuation', () {
      expect(normalizeQuoteText('Hello\u{2019}s \u{201C}world\u{201D}'),
          'HELLO\'S "WORLD"');
      expect(normalizeQuoteText('em\u{2014}dash'), 'EM-DASH');
    });

    test('lettersOnly strips everything else', () {
      expect(lettersOnly('WELL DONE, IS IT?'), 'WELLDONEISIT');
    });
  });
}
