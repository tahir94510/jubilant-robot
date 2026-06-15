import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/alphabet.dart';
import 'package:quotecrack/engine/cipher.dart';
import 'package:quotecrack/models/puzzle.dart';
import 'package:quotecrack/models/quote.dart';

/// The cryptogram "math" must hold for every supported alphabet, not just
/// English: the cipher is a derangement bijection, it is deterministic, and a
/// puzzle is always fully solvable by entering the correct plain letters.
void main() {
  group('every alphabet yields a sound cipher', () {
    for (final a in Alphabets.all) {
      test('${a.code}: derangement bijection over its letters', () {
        final n = a.letters.length;
        for (var seed = 0; seed < 200; seed++) {
          final map = CipherMap.fromSeed(seed, alphabet: a.letters);
          final outputs = <String>{};
          for (final plain in a.letters.split('')) {
            final cipher = map.encryptLetter(plain);
            expect(cipher, isNot(plain),
                reason: '${a.code} seed $seed: $plain maps to itself');
            expect(a.isLetter(cipher), isTrue);
            outputs.add(cipher);
            expect(map.decryptLetter(cipher), plain);
          }
          expect(outputs.length, n,
              reason: '${a.code} seed $seed: not a bijection');
        }
      });

      test('${a.code}: same seed is deterministic', () {
        final x = CipherMap.fromSeed(42, alphabet: a.letters);
        final y = CipherMap.fromSeed(42, alphabet: a.letters);
        for (final plain in a.letters.split('')) {
          expect(x.encryptLetter(plain), y.encryptLetter(plain));
        }
      });
    }
  });

  test('alphabet sizes are as designed', () {
    expect(Alphabets.en.letters.length, 26);
    expect(Alphabets.es.letters.length, 27); // adds Ñ
    expect(Alphabets.tr.letters.length, 29); // full Turkish alphabet
  });

  group('locale-correct normalization', () {
    test('Turkish casing keeps the dotted/dotless İ-I pair', () {
      final tr = Alphabets.tr;
      // "bilgi" -> BİLGİ (not BILGI); "ışık" -> IŞIK (not İŞİK).
      expect(tr.normalize('bilgi'), 'BİLGİ');
      expect(tr.normalize('ışık'), 'IŞIK');
      expect(tr.isLetter('İ'), isTrue);
      expect(tr.isLetter('Ş'), isTrue);
      expect(tr.isLetter('Q'), isFalse); // not a Turkish letter
    });

    test('Spanish keeps Ñ but folds accented vowels', () {
      expect(Alphabets.es.normalize('mañana añejo'), 'MAÑANA AÑEJO');
      expect(Alphabets.es.normalize('corazón'), 'CORAZON');
      expect(Alphabets.es.isLetter('Ñ'), isTrue);
    });

    test('German folds umlauts and ß; French folds accents', () {
      expect(Alphabets.de.normalize('Größe'), 'GROSSE');
      expect(Alphabets.fr.normalize('élève à Noël'), 'ELEVE A NOEL');
    });
  });

  group('puzzles are solvable in every alphabet', () {
    final samples = {
      'tr': 'Damlaya damlaya göl olur.',
      'es': 'El que mucho abarca poco aprieta.',
      'de': 'Übung macht den Meister.',
      'fr': 'Petit à petit, l’oiseau fait son nid.',
      'en': 'Less is more.',
    };
    samples.forEach((locale, text) {
      test('$locale: entering the solution solves the board', () {
        final quote = Quote(
          id: '$locale-sample',
          text: text,
          author: 'Test',
          source: 'Test',
          category: 'proverbs',
          locale: locale,
        );
        final session = PuzzleSession(quote: quote);
        // Decrypt every cipher letter to its plain letter: must fully solve.
        for (final c in session.cipherLetters) {
          session.guesses[c] = session.cipher.decryptLetter(c);
        }
        expect(session.isSolved, isTrue,
            reason: '$locale puzzle did not solve with the correct letters');
        // And the keyboard can produce every needed plain letter.
        final keys = quote.alphabet.keyboardRows.join().split('').toSet();
        expect(keys.containsAll(session.usedPlainLetters), isTrue,
            reason: '$locale keyboard is missing a needed letter');
      });
    });
  });
}
