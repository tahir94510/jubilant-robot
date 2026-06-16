import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/alphabet.dart';

/// The on-screen keyboard must offer every playable letter exactly once and
/// never a key that can't appear in the cipher. Each locale uses its own
/// familiar physical layout (QWERTY / QWERTZ / AZERTY / Turkish-Q).
void main() {
  for (final alphabet in Alphabets.all) {
    test('${alphabet.code} keyboard covers exactly its alphabet', () {
      final keys = alphabet.keyboardRows.join('').split('');
      final letters = alphabet.letters.split('').toSet();

      // No duplicate keys.
      expect(
        keys.length,
        keys.toSet().length,
        reason: '${alphabet.code} has a duplicated key',
      );
      // Exactly the playable letters — no missing, no extras (e.g. Q/W/X must
      // not appear on the Turkish keyboard).
      expect(
        keys.toSet(),
        letters,
        reason: '${alphabet.code} keyboard does not match its letters',
      );
    });
  }

  test('German is QWERTZ and French is AZERTY', () {
    expect(Alphabets.de.keyboardRows.first, startsWith('QWERTZ'));
    expect(Alphabets.fr.keyboardRows.first, startsWith('AZERTY'));
  });
}
