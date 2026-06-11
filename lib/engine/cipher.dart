/// Letter-substitution cipher generation.
///
/// Engine rule: only ever use [DeterministicRng]/[stableStringHash] here —
/// see deterministic_rng.dart for why.
library;

import 'deterministic_rng.dart';

const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// A substitution mapping: `cipherOf[plainLetter] = cipherLetter`.
///
/// Generated with Sattolo's algorithm, which produces a permutation that is
/// a single 26-cycle. A cycle of length 26 cannot have fixed points, so no
/// letter ever encodes to itself — guaranteed, no rejection loop needed.
class CipherMap {
  CipherMap._(this._plainToCipher, this._cipherToPlain);

  factory CipherMap.fromSeed(int seed) {
    final rng = DeterministicRng(fmix32(seed));
    final indices = _sattolo(26, rng);
    final plainToCipher = <String, String>{};
    final cipherToPlain = <String, String>{};
    for (var i = 0; i < 26; i++) {
      final plain = alphabet[i];
      final cipher = alphabet[indices[i]];
      plainToCipher[plain] = cipher;
      cipherToPlain[cipher] = plain;
    }
    return CipherMap._(plainToCipher, cipherToPlain);
  }

  /// Same quote id -> same cipher on every device and platform, so friends
  /// can compare notes on the daily puzzle.
  factory CipherMap.forQuoteId(String quoteId) =>
      CipherMap.fromSeed(stableStringHash(quoteId));

  final Map<String, String> _plainToCipher;
  final Map<String, String> _cipherToPlain;

  String encryptLetter(String plain) => _plainToCipher[plain]!;

  String decryptLetter(String cipher) => _cipherToPlain[cipher]!;

  /// Encrypts uppercase text; anything outside A-Z passes through.
  String encrypt(String normalizedText) {
    final out = StringBuffer();
    for (final ch in normalizedText.split('')) {
      out.write(_plainToCipher[ch] ?? ch);
    }
    return out.toString();
  }
}

/// Sattolo's algorithm: like Fisher-Yates but `j` is drawn strictly below
/// `i`, which yields a uniformly random *cyclic* permutation (single
/// 26-cycle => derangement).
List<int> _sattolo(int n, DeterministicRng rng) {
  final a = List<int>.generate(n, (i) => i);
  for (var i = n - 1; i > 0; i--) {
    final j = rng.nextInt(i); // 0..i-1, never i itself
    final t = a[i];
    a[i] = a[j];
    a[j] = t;
  }
  return a;
}

/// Uppercases and folds typographic characters so only plain ASCII remains.
/// Only A-Z participates in the cipher; punctuation renders as-is.
String normalizeQuoteText(String raw) {
  return raw
      .replaceAll('‘', "'")
      .replaceAll('’', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('…', '...')
      .toUpperCase();
}

/// Just the A-Z letters of a normalized text.
String lettersOnly(String normalizedText) =>
    normalizedText.replaceAll(RegExp('[^A-Z]'), '');
