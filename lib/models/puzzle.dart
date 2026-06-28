import '../engine/alphabet.dart';
import '../engine/cipher.dart';
import 'quote.dart';

/// Live state of one cryptogram being solved.
///
/// The board shows [cipherText]; the player assigns a plain letter to each
/// distinct cipher letter. Identical cipher letters always share one guess,
/// so "auto-fill" is inherent to the data model.
class PuzzleSession {
  PuzzleSession({required this.quote, Map<String, String>? guesses})
    : alphabet = quote.alphabet,
      cipher = CipherMap.forQuoteId(quote.id, alphabet: quote.alphabet.letters),
      guesses = Map.of(guesses ?? const {}) {
    cipherText = cipher.encrypt(quote.normalizedText);
  }

  final Quote quote;

  /// The alphabet this puzzle plays on (drives the board and keyboard).
  final Alphabet alphabet;
  final CipherMap cipher;
  late final String cipherText;

  /// cipherLetter -> player's plain-letter guess.
  final Map<String, String> guesses;

  /// Cipher letters revealed via hints (locked, not editable).
  final Set<String> revealed = {};

  /// Distinct cipher letters present on the board. Memoized: it is a pure
  /// function of the immutable [cipherText], yet it is read on nearly every
  /// keystroke (selection, solved-check, hints), so computing it once and
  /// reusing it removes the only real repeated scan on the input hot path.
  /// Unmodifiable so the shared instance can never be mutated by a caller.
  late final Set<String> cipherLetters = Set.unmodifiable(
    alphabet.lettersOnly(cipherText).split('').toSet(),
  );

  /// Every whitespace-delimited token reduced to its alphabet letters (cells),
  /// computed once. Drives [correctWordCount] and [confirmedLetters] so neither
  /// re-tokenizes the whole quote on each keystroke. Identical tokenizing to the
  /// previous inline logic — a "word" is one token (so "well-done"/"isn't"
  /// count once), letters pulled with the quote's alphabet, empty tokens
  /// dropped — just precomputed instead of rebuilt per call.
  late final List<List<String>> _wordCells = () {
    final out = <List<String>>[];
    for (final word in cipherText.split(' ')) {
      final letters = alphabet.lettersOnly(word);
      if (letters.isEmpty) continue;
      out.add(letters.split(''));
    }
    return out;
  }();

  /// The absolute [cipherText] indices of every letter cell, grouped by word —
  /// PARALLEL to [_wordCells] (same order/length). Lets callers highlight the
  /// exact cells of a just-completed word (position-based) instead of every copy
  /// of its letters across the board. Walks the string the same way the board
  /// does (split on ' ', skip the dropped separator), so indices line up with
  /// the board's cell positions.
  late final List<List<int>> _wordCellPositions = () {
    final out = <List<int>>[];
    var pos = 0;
    for (final word in cipherText.split(' ')) {
      final positions = <int>[];
      for (final ch in word.split('')) {
        if (alphabet.isLetter(ch)) positions.add(pos);
        pos++;
      }
      pos++; // the single space separator that split(' ') removed
      if (positions.isNotEmpty) out.add(positions);
    }
    return out;
  }();

  /// Cell positions (cipherText indices) of word [wordIndex] — pairs with
  /// [correctWordIndices] so a caller can light up exactly that word's cells.
  List<int> wordCellPositions(int wordIndex) => _wordCellPositions[wordIndex];

  /// Plain letters already used as guesses (for keyboard dimming).
  Set<String> get usedPlainLetters => guesses.values.toSet();

  /// Plain letters the player can no longer place freely: the correct answers to
  /// cipher letters that are hint-revealed or locked by a completed word. The
  /// keyboard disables these (a known-correct letter typed elsewhere could only
  /// ever be wrong), while merely used-but-unconfirmed letters stay active so a
  /// guess can still be moved.
  Set<String> get lockedLetters {
    final out = <String>{};
    for (final c in revealed) {
      final g = guesses[c];
      if (g != null) out.add(g);
    }
    for (final c in confirmedLetters) {
      final g = guesses[c];
      if (g != null) out.add(g);
    }
    return out;
  }

  /// Cipher letters whose guess collides with another cipher letter's guess.
  Set<String> get conflicts {
    final byPlain = <String, List<String>>{};
    guesses.forEach((cipherL, plainL) {
      byPlain.putIfAbsent(plainL, () => []).add(cipherL);
    });
    final out = <String>{};
    for (final group in byPlain.values) {
      if (group.length > 1) out.addAll(group);
    }
    return out;
  }

  /// True when every cipher letter is guessed correctly.
  bool get isSolved {
    for (final c in cipherLetters) {
      if (guesses[c] != cipher.decryptLetter(c)) return false;
    }
    return true;
  }

  /// 0..1 share of cipher letters currently filled in.
  double get progress {
    final total = cipherLetters.length;
    if (total == 0) return 0;
    return guesses.length / total;
  }

  bool isGuessCorrect(String cipherLetter) =>
      guesses[cipherLetter] == cipher.decryptLetter(cipherLetter);

  /// Number of words currently solved correctly — drives the "word done"
  /// progress cue. EVERY whole word counts, including single-letter words
  /// (A, I): finishing any word, whatever its length, earns the chime + lock.
  ///
  /// A "word" is a whitespace-delimited token (so a hyphenated word like
  /// "well-done" or a contraction like "isn't" counts once, not as its
  /// fragments). Letters are pulled per token with the quote's alphabet so it
  /// stays correct in every language — NOT alphabet.words(), which would split
  /// on the hyphen/apostrophe too.
  int get correctWordCount {
    var count = 0;
    for (final cells in _wordCells) {
      if (cells.every(isGuessCorrect)) count++;
    }
    return count;
  }

  /// Cipher letters that belong to at least one fully-correct word (any length,
  /// single-letter words included).
  ///
  /// In a unique-solution cryptogram, once a whole word reads correctly its
  /// letter mappings are definitively right, so these letters are LOCKED (the
  /// player can't disturb them) and render in a distinct "confirmed" color —
  /// keeping them from blending into the in-progress guesses around them. Uses
  /// the same per-token, alphabet-aware tokenizing as [correctWordCount].
  Set<String> get confirmedLetters {
    final out = <String>{};
    for (final cells in _wordCells) {
      if (cells.every(isGuessCorrect)) out.addAll(cells);
    }
    return out;
  }

  /// Indices (into [_wordCells]/[wordCellPositions]) of words that are currently
  /// fully correct. Snapshotted before/after an edit so the controller can find
  /// exactly the word(s) a move just completed and highlight only their cells.
  Set<int> get correctWordIndices {
    final out = <int>{};
    for (var i = 0; i < _wordCells.length; i++) {
      if (_wordCells[i].every(isGuessCorrect)) out.add(i);
    }
    return out;
  }

  /// For persistence.
  Map<String, dynamic> toJson() => {
    'quoteId': quote.id,
    'guesses': guesses,
    'revealed': revealed.toList(),
  };
}
