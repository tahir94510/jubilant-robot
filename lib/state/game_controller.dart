import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/puzzle.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

/// Undo record: one guess assignment at a specific board position.
class _Move {
  _Move(this.cipherLetter, this.previousGuess, this.index);
  final String cipherLetter;
  final String? previousGuess;

  /// The exact board cell the edit happened at. Undo restores the cursor here,
  /// not to the letter's first occurrence — so editing the second copy of a
  /// repeated letter and undoing keeps the cursor on that copy.
  final int? index;

  Map<String, dynamic> toJson() => {
    'c': cipherLetter,
    'p': previousGuess,
    'i': index,
  };

  static _Move fromJson(Map<String, dynamic> j) =>
      _Move(j['c'] as String, j['p'] as String?, j['i'] as int?);
}

/// Owns the active [PuzzleSession]: selection, input, hints, timer,
/// completion detection, and resume-from-storage.
class GameController extends ChangeNotifier {
  GameController({required StorageService storage}) : _storage = storage;

  final StorageService _storage;

  PuzzleSession? _session;
  PuzzleSession? get session => _session;

  bool _isDaily = false;
  bool get isDaily => _isDaily;

  /// Pack the active puzzle was launched from (null for daily).
  String? _originPackId;
  String? get originPackId => _originPackId;

  /// The cursor's position within [PuzzleSession.cipherText]. Selection is
  /// tracked by board POSITION, not by cipher letter: a cipher letter can
  /// appear many times on the board, so "advance to the cell after the one I
  /// just typed" must key off the exact cell that was tapped. Keying off the
  /// letter's *first* occurrence (the old bug) flung the cursor backwards
  /// across the board whenever a repeated letter was edited.
  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  /// The cipher letter currently under the cursor. Drives the board's "every
  /// instance of this letter lights up together" cue, so it is still exposed
  /// as a letter even though selection is positional underneath.
  String? get selectedCipherLetter {
    final s = _session;
    final i = _selectedIndex;
    if (s == null || i == null || i < 0 || i >= s.cipherText.length) {
      return null;
    }
    final ch = s.cipherText[i];
    return s.cipherLetters.contains(ch) ? ch : null;
  }

  int _hintsUsed = 0;
  int get hintsUsed => _hintsUsed;

  final List<_Move> _undoStack = [];
  bool get canUndo => _undoStack.isNotEmpty;

  /// True when the most recent [enterGuess] introduced a new conflict —
  /// lets the UI give distinct feedback for that one input.
  bool _lastInputCreatedConflict = false;
  bool get lastInputCreatedConflict => _lastInputCreatedConflict;

  /// True when the most recent [enterGuess] finished a whole word without
  /// solving the puzzle (the solving keystroke belongs to the success
  /// fanfare). Drives the small "word done" sound cue.
  bool _lastInputCompletedWord = false;
  bool get lastInputCompletedWord => _lastInputCompletedWord;

  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  Duration get elapsed => _elapsed;

  /// Clock ticks publish HERE, not through notifyListeners: only the
  /// timer text should repaint each second, never the whole board.
  final ValueNotifier<Duration> elapsedListenable = ValueNotifier(
    Duration.zero,
  );

  bool _completed = false;
  bool get completed => _completed;

  /// True only while the player is viewing the full solution read-only (via
  /// [showSolution]) for an already-solved puzzle. Distinct from [completed],
  /// which drives the one-time celebration flow.
  bool _reviewingSolved = false;
  bool get reviewingSolved => _reviewingSolved;

  /// True when this quote has been solved before (this attempt is a replay).
  /// Re-entering a solved puzzle now starts a fresh, blank, fully playable
  /// board — never a spoiler-filled one — and the UI offers an on-demand
  /// "Show solution" affordance gated on this flag.
  bool _previouslySolved = false;
  bool get previouslySolved => _previouslySolved;

  /// The player's in-progress attempt, snapshotted while the read-only
  /// solution is shown so [returnToAttempt] can restore it untouched.
  Map<String, String>? _attemptGuesses;
  List<String>? _attemptRevealed;

  /// Starts (or resumes) a puzzle for [quote].
  ///
  /// [alreadySolved] (from [ProgressController.isSolved]) marks a replay: the
  /// board still starts blank and fully playable, but the UI exposes an
  /// on-demand "Show solution" button so the answer is never shown unbidden.
  void start(
    Quote quote, {
    required bool daily,
    String? packId,
    bool alreadySolved = false,
  }) {
    _originPackId = packId;
    _ticker?.cancel();
    final saved = _storage.readJson(StorageService.puzzleStateKey(quote.id));

    // Decode the saved state defensively: a corrupt or schema-drifted save
    // (partial write, an older/newer build's format) must never crash on
    // puzzle entry — we simply start the puzzle fresh in that case.
    Map<String, String>? savedGuesses;
    var savedRevealed = const <String>[];
    var savedHints = 0;
    var savedElapsed = 0;
    final savedUndo = <_Move>[];
    final resuming = saved != null && saved['solved'] != true;
    if (resuming) {
      try {
        savedGuesses = (saved['guesses'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as String),
        );
        savedRevealed = ((saved['revealed'] as List<dynamic>?) ?? const [])
            .cast<String>();
        savedHints = saved['hintsUsed'] as int? ?? 0;
        savedElapsed = saved['elapsedSeconds'] as int? ?? 0;
        // Undo history must survive leaving and re-entering the puzzle: the
        // stack is checkpointed to storage, not held only in memory.
        for (final m in (saved['undo'] as List<dynamic>?) ?? const []) {
          savedUndo.add(_Move.fromJson((m as Map).cast<String, dynamic>()));
        }
      } catch (_) {
        // Discard whatever was partially decoded and start fresh.
        savedGuesses = null;
        savedRevealed = const [];
        savedHints = 0;
        savedElapsed = 0;
        savedUndo.clear();
      }
    }

    _session = PuzzleSession(quote: quote, guesses: savedGuesses);
    _undoStack
      ..clear()
      ..addAll(savedUndo);
    _session!.revealed.addAll(savedRevealed);
    _hintsUsed = savedHints;
    _elapsed = Duration(seconds: savedElapsed);

    _isDaily = daily;
    _completed = false;
    _reviewingSolved = false;
    _attemptGuesses = null;
    _attemptRevealed = null;
    _lastInputCreatedConflict = false;
    _lastInputCompletedWord = false;

    // Re-opening a solved puzzle no longer spoils the answer: it starts as a
    // blank, fully playable board exactly like a fresh attempt. The solution
    // is available only on demand via [showSolution], gated on this flag.
    _previouslySolved =
        alreadySolved || (saved != null && saved['solved'] == true);

    elapsedListenable.value = _elapsed;
    _selectedIndex = _firstEmptyIndex();

    _startTicker();
    notifyListeners();
  }

  /// Clears a reviewed (or any) puzzle back to a blank board and starts a fresh
  /// attempt. Re-solving never double-counts: ProgressController already knows
  /// the quote is solved, so no extra tokens/streak are awarded.
  void replay() {
    final s = _session;
    if (s == null) return;
    s.guesses.clear();
    s.revealed.clear();
    _undoStack.clear();
    _reviewingSolved = false;
    _completed = false;
    _hintsUsed = 0;
    _elapsed = Duration.zero;
    _lastInputCreatedConflict = false;
    _lastInputCompletedWord = false;
    elapsedListenable.value = _elapsed;
    _selectedIndex = _firstEmptyIndex();
    _persistState();
    _startTicker();
    notifyListeners();
  }

  /// Fills the board with the full solution read-only for a previously-solved
  /// puzzle, snapshotting the player's current attempt so [returnToAttempt]
  /// can restore it untouched. The clock pauses while the answer is shown.
  void showSolution() {
    final s = _session;
    if (s == null || _reviewingSolved || !_previouslySolved) return;
    _attemptGuesses = Map.of(s.guesses);
    _attemptRevealed = s.revealed.toList();
    for (final c in s.cipherLetters) {
      s.guesses[c] = s.cipher.decryptLetter(c);
    }
    _reviewingSolved = true; // set first so stopTimer won't persist the fill
    stopTimer();
    notifyListeners();
  }

  /// Leaves the read-only solution view and restores the player's saved
  /// attempt, resuming the clock.
  void returnToAttempt() {
    final s = _session;
    if (s == null || !_reviewingSolved) return;
    s.guesses
      ..clear()
      ..addAll(_attemptGuesses ?? const {});
    s.revealed
      ..clear()
      ..addAll(_attemptRevealed ?? const []);
    _attemptGuesses = null;
    _attemptRevealed = null;
    _reviewingSolved = false;
    if (!_completed) _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_completed) {
        _elapsed += const Duration(seconds: 1);
        elapsedListenable.value = _elapsed;
        // Autosave the clock so neither leaving the screen nor an app kill
        // rewinds it to the moment of the last letter entry.
        if (_elapsed.inSeconds % 10 == 0) _persistState();
      }
    });
  }

  void stopTimer() {
    _ticker?.cancel();
    _ticker = null;
    // Leaving the puzzle (back button, backgrounding) must checkpoint the
    // elapsed time, not just the last guess — but a read-only review of a
    // solved puzzle must never overwrite its solved save with a filled board.
    if (_session != null && !_completed && !_reviewingSolved) _persistState();
  }

  /// Restarts the ticker after a lifecycle pause (app backgrounded, ad
  /// overlay, phone call) so off-screen time never counts as solve time.
  void resumeTimer() {
    if (_session != null &&
        !_completed &&
        !_reviewingSolved &&
        _ticker == null) {
      _startTicker();
    }
  }

  int? _firstEmptyIndex() {
    final s = _session;
    if (s == null) return null;
    final t = s.cipherText;
    for (var i = 0; i < t.length; i++) {
      final ch = t[i];
      if (s.cipherLetters.contains(ch) && !s.guesses.containsKey(ch)) return i;
    }
    return null;
  }

  /// The next empty cell strictly AFTER [from] in reading order, wrapping to
  /// the first empty cell. Keyed off the cursor's real position so typing
  /// always steps forward from the tapped cell instead of jumping to a
  /// repeated letter's first occurrence.
  int? _nextEmptyIndexAfter(int? from) {
    final s = _session;
    if (s == null) return null;
    final t = s.cipherText;
    final start = from == null ? 0 : from + 1;
    for (var i = start; i < t.length; i++) {
      final ch = t[i];
      if (s.cipherLetters.contains(ch) && !s.guesses.containsKey(ch)) return i;
    }
    return _firstEmptyIndex();
  }

  int? _indexOfLetter(String cipherLetter) {
    final s = _session;
    if (s == null) return null;
    final i = s.cipherText.indexOf(cipherLetter);
    return i >= 0 ? i : null;
  }

  String? _firstEmptyLetter() {
    final s = _session;
    final i = _firstEmptyIndex();
    if (s == null || i == null) return null;
    return s.cipherText[i];
  }

  /// Selects a board cell by its position in the cipher text. This is what the
  /// board taps call: it pins the cursor to the exact cell touched.
  void selectIndex(int index) {
    final s = _session;
    if (s == null || index < 0 || index >= s.cipherText.length) return;
    if (!s.cipherLetters.contains(s.cipherText[index])) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Moves the cursor to the next ([dir] > 0) or previous board letter,
  /// wrapping around. Drives arrow-key navigation for physical keyboards,
  /// TVs, and accessibility.
  void moveSelection(int dir) {
    final s = _session;
    if (s == null) return;
    final t = s.cipherText;
    final n = t.length;
    if (n == 0) return;
    var i = _selectedIndex ?? (dir > 0 ? -1 : 0);
    for (var step = 0; step < n; step++) {
      i = (i + dir) % n;
      if (i < 0) i += n;
      if (s.cipherLetters.contains(t[i])) {
        _selectedIndex = i;
        notifyListeners();
        return;
      }
    }
  }

  /// Compatibility selector by cipher letter — focuses that letter's first
  /// occurrence. The UI selects by position via [selectIndex]; this remains
  /// for callers and tests that reason in letters.
  void selectCipherLetter(String? cipherLetter) {
    if (cipherLetter == null) {
      _selectedIndex = null;
    } else {
      _selectedIndex = _indexOfLetter(cipherLetter) ?? _selectedIndex;
    }
    notifyListeners();
  }

  /// Assigns [plainLetter] to the selected cipher letter, auto-advances to
  /// the next empty cell, and detects completion.
  void enterGuess(String plainLetter) {
    // Any new interaction invalidates the one-shot cue, even when the call
    // turns out to be a no-op (stale flags must never replay a sound).
    _lastInputCompletedWord = false;
    final s = _session;
    final target = selectedCipherLetter;
    if (s == null || target == null || _completed || _reviewingSolved) return;
    // Hint-revealed and confirmed-correct letters are locked: typing can't
    // disturb a word the player already cracked.
    if (s.revealed.contains(target) || s.confirmedLetters.contains(target)) {
      return;
    }

    _undoStack.add(_Move(target, s.guesses[target], _selectedIndex));
    final conflictsBefore = s.conflicts.length;
    final wordsBefore = s.correctWordCount;
    s.guesses[target] = plainLetter;
    _lastInputCreatedConflict = s.conflicts.length > conflictsBefore;
    _lastInputCompletedWord =
        !_lastInputCreatedConflict &&
        !s.isSolved &&
        s.correctWordCount > wordsBefore;
    _afterChange();
  }

  /// Smart backspace, matching the crossword/cryptogram convention: if the
  /// current cell holds an editable guess, clear it and stay put; otherwise
  /// (the cell is empty or locked) step back to the previous editable cell and
  /// clear that one. So repeated presses walk backwards through your entries.
  void clearGuess() {
    _lastInputCompletedWord = false;
    final s = _session;
    if (s == null || _completed || _reviewingSolved) return;

    final target = selectedCipherLetter;
    final currentEditable =
        target != null &&
        !s.revealed.contains(target) &&
        !s.confirmedLetters.contains(target);

    if (currentEditable && s.guesses.containsKey(target)) {
      // Current cell holds your own guess: clear it, keep the cursor here.
      _undoStack.add(_Move(target, s.guesses[target], _selectedIndex));
      s.guesses.remove(target);
      _afterChange(advance: false);
      return;
    }

    // Current cell is empty or locked: step back to the previous editable cell
    // and clear it (or just land there when it is already empty).
    final prev = _prevEditableIndex(_selectedIndex);
    if (prev == null) return;
    _selectedIndex = prev;
    final t = selectedCipherLetter;
    if (t != null && s.guesses.containsKey(t)) {
      _undoStack.add(_Move(t, s.guesses[t], _selectedIndex));
      s.guesses.remove(t);
    }
    _afterChange(advance: false);
  }

  /// True when board cell [i] is an editable letter cell (a cipher letter that
  /// is neither hint-revealed nor confirmed-correct).
  bool _isEditableIndex(PuzzleSession s, int i) {
    final ch = s.cipherText[i];
    if (!s.cipherLetters.contains(ch)) return false;
    return !s.revealed.contains(ch) && !s.confirmedLetters.contains(ch);
  }

  /// The nearest editable cell strictly BEFORE [from] in reading order (no
  /// wrap — backspace stops at the start of the board).
  int? _prevEditableIndex(int? from) {
    final s = _session;
    if (s == null) return null;
    final start = (from ?? s.cipherText.length) - 1;
    for (var i = start; i >= 0; i--) {
      if (_isEditableIndex(s, i)) return i;
    }
    return null;
  }

  void undo() {
    _lastInputCompletedWord = false;
    final s = _session;
    if (s == null || _undoStack.isEmpty || _completed || _reviewingSolved) {
      return;
    }
    final move = _undoStack.removeLast();
    if (move.previousGuess == null) {
      s.guesses.remove(move.cipherLetter);
    } else {
      s.guesses[move.cipherLetter] = move.previousGuess!;
    }
    // Restore the cursor to the exact cell that was edited, falling back to the
    // letter's first occurrence only for legacy saves without a stored index.
    _selectedIndex =
        move.index ?? _indexOfLetter(move.cipherLetter) ?? _selectedIndex;
    _persistState();
    notifyListeners();
  }

  /// Reveals the correct letter for the selected (or first empty) cell.
  /// Token accounting happens in EconomyController; this just mutates state.
  void revealSelected() {
    _lastInputCompletedWord = false; // hints have their own chime
    final s = _session;
    if (s == null || _completed || _reviewingSolved) return;
    var target = selectedCipherLetter ?? _firstEmptyLetter();
    // Prefer an unsolved cell: if the selected one is already correct,
    // reveal the first wrong/empty one instead so the hint always helps.
    if (target == null || s.isGuessCorrect(target)) {
      target = s.cipherLetters
          .where((c) => !s.isGuessCorrect(c))
          .fold<String?>(
            null,
            (min, c) => min == null || c.compareTo(min) < 0 ? c : min,
          );
    }
    if (target == null) return;

    _hintsUsed += 1;
    s.guesses[target] = s.cipher.decryptLetter(target);
    s.revealed.add(target);
    _selectedIndex = _indexOfLetter(target) ?? _selectedIndex;
    _undoStack.clear(); // reveals are permanent
    _afterChange();
  }

  void _afterChange({bool advance = true}) {
    final s = _session!;
    if (s.isSolved) {
      _completed = true;
      stopTimer();
      _storage.writeJson(StorageService.puzzleStateKey(s.quote.id), {
        'solved': true,
      });
    } else {
      if (advance) {
        _selectedIndex = _nextEmptyIndexAfter(_selectedIndex) ?? _selectedIndex;
      }
      _persistState();
    }
    notifyListeners();
  }

  void _persistState() {
    final s = _session;
    if (s == null) return;
    _storage.writeJson(StorageService.puzzleStateKey(s.quote.id), {
      ...s.toJson(),
      'hintsUsed': _hintsUsed,
      'elapsedSeconds': _elapsed.inSeconds,
      'undo': _undoStack.map((m) => m.toJson()).toList(),
      'solved': false,
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    elapsedListenable.dispose();
    super.dispose();
  }
}
