/// Per-language alphabets for the cryptogram engine.
///
/// A cryptogram substitutes one *letter* for another, so "what counts as a
/// letter" is language-specific. English and the accent-folding European
/// languages play on the 26-letter Latin set; Spanish adds Ñ; Turkish uses
/// its own 29-letter alphabet (with the dotted/dotless İ-I distinction).
///
/// An [Alphabet] owns three things the rest of the engine needs:
///   1. the ordered letter set the cipher permutes,
///   2. locale-correct normalization (casing + diacritic folding), and
///   3. the on-screen keyboard layout.
library;

import 'cipher.dart';

class Alphabet {
  Alphabet({
    required this.code,
    required this.letters,
    required this.keyboardRows,
    this.folds = const {},
  }) : letterSet = letters.split('').toSet();

  /// Locale code this alphabet serves (e.g. 'en', 'tr', 'es').
  final String code;

  /// Ordered uppercase letters the cipher permutes.
  final String letters;

  /// On-screen keyboard rows (the action keys attach to the last row).
  final List<String> keyboardRows;

  /// Uppercase diacritic/ligature folds applied during [normalize], e.g.
  /// {'É':'E', 'ß':'SS'}. Letters the language treats as distinct (Spanish Ñ,
  /// every Turkish letter) are NOT folded — they live in [letters] instead.
  final Map<String, String> folds;

  final Set<String> letterSet;

  bool isLetter(String ch) => letterSet.contains(ch);

  /// Locale-correct uppercasing. Dart's [String.toUpperCase] is locale-blind,
  /// which mangles Turkish (i→I instead of i→İ); fix the i/ı pair first.
  String _toUpper(String s) {
    if (code == 'tr') {
      s = s.replaceAll('i', 'İ').replaceAll('ı', 'I');
    }
    return s.toUpperCase();
  }

  /// Uppercases, folds typographic punctuation to ASCII, then applies the
  /// language's diacritic folds so only this alphabet's letters remain among
  /// the run of "letters" (punctuation and spaces pass through untouched).
  String normalize(String raw) {
    var s = raw
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('…', '...');
    s = _toUpper(s);
    if (folds.isEmpty) return s;
    final b = StringBuffer();
    for (final ch in s.split('')) {
      b.write(folds[ch] ?? ch);
    }
    return b.toString();
  }

  /// Just this alphabet's letters from a normalized string.
  String lettersOnly(String normalized) {
    final b = StringBuffer();
    for (final ch in normalized.split('')) {
      if (letterSet.contains(ch)) b.write(ch);
    }
    return b.toString();
  }

  /// Splits a normalized string into words on runs of non-letters.
  List<String> words(String normalized) {
    final out = <String>[];
    final buf = StringBuffer();
    for (final ch in normalized.split('')) {
      if (letterSet.contains(ch)) {
        buf.write(ch);
      } else if (buf.isNotEmpty) {
        out.add(buf.toString());
        buf.clear();
      }
    }
    if (buf.isNotEmpty) out.add(buf.toString());
    return out;
  }
}

/// The registry of supported alphabets. Adding a language is just adding an
/// entry here plus its content files.
abstract final class Alphabets {
  // Standard QWERTY for the Latin-script languages.
  static const _qwerty = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

  // German keyboards are QWERTZ (Z and Y swapped vs QWERTY).
  static const _qwertz = ['QWERTZUIOP', 'ASDFGHJKL', 'YXCVBNM'];

  // French keyboards are AZERTY (M moves up to row 2).
  static const _azerty = ['AZERTYUIOP', 'QSDFGHJKLM', 'WXCVBN'];

  /// English (and the base for any ASCII content).
  static final Alphabet en = Alphabet(
    code: 'en',
    letters: latinAlphabet,
    keyboardRows: _qwerty,
  );

  /// German: umlauts and ß fold to their base spellings (crossword tradition).
  static final Alphabet de = Alphabet(
    code: 'de',
    letters: latinAlphabet,
    keyboardRows: _qwertz,
    folds: {'Ä': 'A', 'Ö': 'O', 'Ü': 'U', 'ß': 'SS'},
  );

  /// French: accents are diacritics on base letters; ligatures expand.
  static final Alphabet fr = Alphabet(
    code: 'fr',
    letters: latinAlphabet,
    keyboardRows: _azerty,
    folds: {
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Ç': 'C',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Î': 'I',
      'Ï': 'I',
      'Ô': 'O',
      'Ö': 'O',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ÿ': 'Y',
      'Œ': 'OE',
      'Æ': 'AE',
    },
  );

  /// Italian: grave/acute accents fold to base vowels.
  static final Alphabet it = Alphabet(
    code: 'it',
    letters: latinAlphabet,
    keyboardRows: _qwerty,
    folds: {
      'À': 'A',
      'È': 'E',
      'É': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ò': 'O',
      'Ó': 'O',
      'Ù': 'U',
      'Ú': 'U',
    },
  );

  /// Portuguese (BR): tildes/accents/cedilla fold to base letters.
  static final Alphabet pt = Alphabet(
    code: 'pt',
    letters: latinAlphabet,
    keyboardRows: _qwerty,
    folds: {
      'Á': 'A',
      'Â': 'A',
      'Ã': 'A',
      'À': 'A',
      'Ç': 'C',
      'É': 'E',
      'Ê': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ú': 'U',
      'Ü': 'U',
    },
  );

  /// Spanish: Ñ is a distinct letter (27-letter alphabet); accented vowels
  /// fold to their base (the same letter with a stress mark).
  static final Alphabet es = Alphabet(
    code: 'es',
    letters: 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ',
    keyboardRows: const ['QWERTYUIOP', 'ASDFGHJKLÑ', 'ZXCVBNM'],
    folds: {'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U', 'Ü': 'U'},
  );

  /// Turkish: the full 29-letter alphabet, no folding. The layout is the
  /// familiar Turkish-Q keyboard with Q, W, X removed (they are not Turkish
  /// letters, so they appear in neither the cipher nor the keyboard).
  static final Alphabet tr = Alphabet(
    code: 'tr',
    letters: 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ',
    keyboardRows: const ['ERTYUIOPĞÜ', 'ASDFGHJKLŞİ', 'ZCVBNMÖÇ'],
  );

  static final List<Alphabet> all = [en, es, de, fr, it, pt, tr];

  static final Map<String, Alphabet> _byCode = {for (final a in all) a.code: a};

  /// The alphabet for [code], falling back to English for unknown/null codes.
  static Alphabet forLocale(String? code) => _byCode[code] ?? en;
}
