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
    // Only an EDITABLE cell counts as "selected": a cursor that ever rests on a
    // locked (hint-revealed / confirmed) cell would otherwise light that letter
    // up and confuse which letter is really being edited.
    if (!_isEditableIndex(s, i)) return null;
    return s.cipherText[i];
  }

  int _hintsUsed = 0;
  int get hintsUsed => _hintsUsed;

  final List<_Move> _undoStack = [];
  bool get canUndo => _undoStack.isNotEmpty;

  /// Redo mirror of [_undoStack]: undone moves land here so they can be
  /// re-applied. Any fresh edit (via [_afterChange]) clears it — a new branch
  /// invalidates the redo history. Persisted per puzzle like the undo stack.
  final List<_Move> _redoStack = [];
  bool get canRedo => _redoStack.isNotEmpty;

  /// True when the most recent [enterGuess] introduced a new conflict —
  /// lets the UI give distinct feedback for that one input.
  bool _lastInputCreatedConflict = false;
  bool get lastInputCreatedConflict => _lastInputCreatedConflict;

  /// True when the most recent [enterGuess] finished a whole word without
  /// solving the puzzle (the solving keystroke belongs to the success
  /// fanfare). Drives the small "word done" sound cue.
  bool _lastInputCompletedWord = false;
  bool get lastInputCompletedWord => _lastInputCompletedWord;

  /// The cipher letter most recently LOCKED — found and locked either by a hint
  /// reveal or by a typed guess that just completed a word (confirmed). Drives
  /// the board's chess-style "last move" highlight: that letter and every copy
  /// carry a distinct fill so the eye stays on the latest letter you nailed
  /// down. It is STABLE by design: it moves ONLY when a new letter locks, and is
  /// untouched by tentative typing, delete, undo, redo or cursor navigation.
  /// Cleared on solve and on (re)start so a finished/fresh board reads clean.
  String? _lastLockedCipherLetter;
  String? get lastLockedCipherLetter => _lastLockedCipherLetter;

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
    final savedRedo = <_Move>[];
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
        // Undo/redo history must survive leaving and re-entering the puzzle:
        // both stacks are checkpointed to storage, not held only in memory.
        for (final m in (saved['undo'] as List<dynamic>?) ?? const []) {
          savedUndo.add(_Move.fromJson((m as Map).cast<String, dynamic>()));
        }
        for (final m in (saved['redo'] as List<dynamic>?) ?? const []) {
          savedRedo.add(_Move.fromJson((m as Map).cast<String, dynamic>()));
        }
      } catch (_) {
        // Discard whatever was partially decoded and start fresh.
        savedGuesses = null;
        savedRevealed = const [];
        savedHints = 0;
        savedElapsed = 0;
        savedUndo.clear();
        savedRedo.clear();
      }
    }

    _session = PuzzleSession(quote: quote, guesses: savedGuesses);
    _undoStack
      ..clear()
      ..addAll(savedUndo);
    _redoStack
      ..clear()
      ..addAll(savedRedo);
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
    _lastLockedCipherLetter = null;

    // Re-opening a solved puzzle no longer spoils the answer: it starts as a
    // blank, fully playable board exactly like a fresh attempt. The solution
    // is available only on demand via [showSolution], gated on this flag.
    _previouslySolved =
        alreadySolved || (saved != null && saved['solved'] == true);

    elapsedListenable.value = _elapsed;
    _selectedIndex = _firstEmptyIndex();

    // Remember the last non-daily puzzle so Home can offer a "Continue" card.
    // Written both per-language (legacy) and to a single GLOBAL record that Home
    // actually reads — so the card shows the true last puzzle regardless of UI
    // language. The daily has its own card, so it never participates here.
    if (!daily) {
      _storage.writeJson(StorageService.lastOpenKey(quote.locale), {
        'quoteId': quote.id,
        'packId': packId,
      });
      _storage.writeJson(StorageService.lastOpenGlobalKey, {
        'quoteId': quote.id,
        'packId': packId,
        'locale': quote.locale,
      });
    }

    _startTicker();
    notifyListeners();
  }

  /// The id (and origin pack) of the last non-daily puzzle opened in [locale],
  /// or null if none. Per-language; retained for callers/tests that reason by
  /// locale. Home uses [lastOpenGlobal].
  ({String quoteId, String? packId})? lastOpen(String locale) {
    final j = _storage.readJson(StorageService.lastOpenKey(locale));
    final id = j?['quoteId'];
    if (id is! String) return null;
    return (quoteId: id, packId: j?['packId'] as String?);
  }

  /// The single most-recently-opened non-daily puzzle across ALL languages —
  /// drives Home's "Continue" card so it always reflects the real last puzzle,
  /// not just one matching the UI language. The caller should still confirm it
  /// is genuinely [hasInProgress] before offering it.
  ({String quoteId, String? packId})? lastOpenGlobal() {
    final j = _storage.readJson(StorageService.lastOpenGlobalKey);
    final id = j?['quoteId'];
    if (id is! String) return null;
    return (quoteId: id, packId: j?['packId'] as String?);
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
    _redoStack.clear();
    _reviewingSolved = false;
    _completed = false;
    _hintsUsed = 0;
    _elapsed = Duration.zero;
    _lastInputCreatedConflict = false;
    _lastInputCompletedWord = false;
    _lastLockedCipherLetter = null;
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
    _lastLockedCipherLetter = null;
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
    _lastLockedCipherLetter = null;
    if (!_completed) _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    // Idempotent restart: cancel any live timer first so a caller that starts
    // the clock without routing through stopTimer (e.g. replay()) can never
    // leave a second periodic timer ticking against the same session.
    _ticker?.cancel();
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

  /// True when [quoteId] has a saved, partially-filled attempt that has not
  /// been solved — so list screens can show it as "in progress", distinct from
  /// untouched and finished. Reads the lightweight saved state directly.
  bool hasInProgress(String quoteId) {
    final j = _storage.readJson(StorageService.puzzleStateKey(quoteId));
    if (j == null || j['solved'] == true) return false;
    final g = j['guesses'];
    return g is Map && g.isNotEmpty;
  }

  /// Selects a board cell by its position in the cipher text. This is what the
  /// board taps call: it pins the cursor to the exact cell touched.
  void selectIndex(int index) {
    final s = _session;
    if (s == null || index < 0 || index >= s.cipherText.length) return;
    // Tapping a non-letter or a LOCKED cell must not move the cursor onto it
    // (the selection highlight is suppressed on locked cells, so the cursor
    // would appear to vanish). Editable cells only.
    if (!_isEditableIndex(s, index)) return;
    _selectedIndex = index;
    notifyListeners();
  }

  /// Moves the cursor to the next ([dir] > 0) or previous board letter, WRAPPING
  /// around at the ends: ▶ on the last letter jumps to the first, and ◀ on the
  /// first jumps to the last. Locked cells are skipped. Drives the on-screen
  /// ◀ ▶ keys and arrow-key navigation (physical keyboards, TVs, accessibility).
  void moveSelection(int dir) {
    final i = _adjacentLetterIndex(dir, wrap: true);
    if (i == null) return;
    _selectedIndex = i;
    notifyListeners();
  }

  /// The nearest EDITABLE board cell strictly after ([dir] > 0) / before
  /// ([dir] < 0) the cursor. Locked (hint-revealed / confirmed) cells are
  /// skipped so the ◀ ▶ arrows always land on a cell the player can type into.
  /// When [wrap] is true and no editable cell exists ahead in that direction,
  /// it continues from the OPPOSITE edge so the cursor loops around the board
  /// (excluding the current cell, so a board with a single editable letter
  /// stays a no-op). Returns null only when there is no other editable cell.
  int? _adjacentLetterIndex(int dir, {bool wrap = false}) {
    final s = _session;
    if (s == null) return null;
    final t = s.cipherText;
    final from = _selectedIndex ?? (dir > 0 ? -1 : t.length);
    for (var i = from + dir; i >= 0 && i < t.length; i += dir) {
      if (_isEditableIndex(s, i)) return i;
    }
    if (!wrap) return null;
    // Wrapped pass: scan from the opposite edge toward the cursor, skipping the
    // current cell, so ▶ at the end lands on the first letter and ◀ at the
    // start lands on the last.
    final cur = _selectedIndex;
    final start = dir > 0 ? 0 : t.length - 1;
    for (var i = start; i >= 0 && i < t.length; i += dir) {
      if (i != cur && _isEditableIndex(s, i)) return i;
    }
    return null;
  }

  /// Whether the ◀ (previous letter) control should be enabled — true whenever
  /// moving back (wrapping around the start) would land on a different editable
  /// cell. Disabled only when one or zero editable cells remain.
  bool get canMovePrev => _adjacentLetterIndex(-1, wrap: true) != null;

  /// Whether the ▶ (next letter) control should be enabled — true whenever
  /// moving forward (wrapping around the end) would land on a different editable
  /// cell. Disabled only when one or zero editable cells remain.
  bool get canMoveNext => _adjacentLetterIndex(1, wrap: true) != null;

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

    // Re-typing the letter the cell already holds is a no-op edit: don't rewrite
    // it or push a redundant undo entry — just walk forward to the next empty
    // cell (the natural "skip" the player expects).
    if (s.guesses[target] == plainLetter) {
      _selectedIndex =
          _nextEmptyEditableIndexAfter(_selectedIndex) ??
          _nextEditableIndexAfter(_selectedIndex) ??
          _selectedIndex;
      notifyListeners();
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
    // The "last move" highlight tracks the last letter that gets LOCKED, not
    // every keystroke: it moves here only when this guess just completed a word
    // (so [target] is now confirmed). A tentative guess leaves it on the
    // previously locked letter — as do delete / undo / navigation.
    if (s.confirmedLetters.contains(target)) {
      _lastLockedCipherLetter = target;
    }
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

  /// The next editable cell strictly AFTER [from] in reading order, wrapping to
  /// the first editable cell. Unlike [_nextEmptyIndexAfter] this stops on the
  /// next editable letter whether it is filled or empty (only hint-revealed and
  /// confirmed-correct cells are skipped) — so typing walks cell by cell and a
  /// filled-but-unconfirmed letter can be revised in place.
  int? _nextEditableIndexAfter(int? from) {
    final s = _session;
    if (s == null) return null;
    final t = s.cipherText;
    final start = from == null ? 0 : from + 1;
    for (var i = start; i < t.length; i++) {
      if (_isEditableIndex(s, i)) return i;
    }
    for (var i = 0; i < t.length; i++) {
      if (_isEditableIndex(s, i)) return i;
    }
    return null;
  }

  /// The next EMPTY editable cell strictly AFTER [from], wrapping to the first.
  /// Skips cells whose cipher letter already holds a guess, so after typing a
  /// letter (which auto-fills all its copies) the cursor jumps straight to the
  /// next blank instead of pausing on a just-filled copy — the "smart cursor".
  /// Returns null when every editable cell is already filled.
  int? _nextEmptyEditableIndexAfter(int? from) {
    final s = _session;
    if (s == null) return null;
    final t = s.cipherText;
    bool empty(int i) => _isEditableIndex(s, i) && !s.guesses.containsKey(t[i]);
    final start = from == null ? 0 : from + 1;
    for (var i = start; i < t.length; i++) {
      if (empty(i)) return i;
    }
    for (var i = 0; i < t.length; i++) {
      if (empty(i)) return i;
    }
    return null;
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
    // Undo must respect the lock: never revert a hint-revealed letter or one
    // that belongs to a completed, confirmed word. Discard any such entries
    // from the top of the stack and undo the first genuinely editable move.
    _Move? move;
    while (_undoStack.isNotEmpty) {
      final m = _undoStack.removeLast();
      if (s.revealed.contains(m.cipherLetter) ||
          s.confirmedLetters.contains(m.cipherLetter)) {
        continue;
      }
      move = m;
      break;
    }
    if (move == null) {
      _persistState(); // stack trimmed of stale locked entries
      notifyListeners();
      return;
    }
    // Capture the current ("after") value so redo can re-apply it.
    final redoValue = s.guesses[move.cipherLetter];
    if (move.previousGuess == null) {
      s.guesses.remove(move.cipherLetter);
    } else {
      s.guesses[move.cipherLetter] = move.previousGuess!;
    }
    _redoStack.add(_Move(move.cipherLetter, redoValue, move.index));
    // Restore the cursor to the exact cell that was edited, falling back to the
    // letter's first occurrence only for legacy saves without a stored index.
    _selectedIndex =
        move.index ?? _indexOfLetter(move.cipherLetter) ?? _selectedIndex;
    _persistState();
    notifyListeners();
  }

  /// Re-applies the most recently undone move. Lock-aware like [undo]: skips
  /// redo entries whose letter has since been confirmed/revealed. Re-applying
  /// can complete the puzzle, so it runs the same completion check (without
  /// clearing the redo stack, which only a fresh edit does).
  void redo() {
    _lastInputCompletedWord = false;
    final s = _session;
    if (s == null || _redoStack.isEmpty || _completed || _reviewingSolved) {
      return;
    }
    _Move? move;
    while (_redoStack.isNotEmpty) {
      final m = _redoStack.removeLast();
      if (s.revealed.contains(m.cipherLetter) ||
          s.confirmedLetters.contains(m.cipherLetter)) {
        continue;
      }
      move = m;
      break;
    }
    if (move == null) {
      _persistState();
      notifyListeners();
      return;
    }
    // The inverse goes back onto the undo stack so the move can be undone again.
    final undoValue = s.guesses[move.cipherLetter];
    if (move.previousGuess == null) {
      s.guesses.remove(move.cipherLetter);
    } else {
      s.guesses[move.cipherLetter] = move.previousGuess!;
    }
    _undoStack.add(_Move(move.cipherLetter, undoValue, move.index));
    _selectedIndex =
        move.index ?? _indexOfLetter(move.cipherLetter) ?? _selectedIndex;
    if (s.isSolved) {
      _completed = true;
      stopTimer();
      _storage.writeJson(StorageService.puzzleStateKey(s.quote.id), {
        'solved': true,
      });
    } else {
      _persistState();
    }
    notifyListeners();
  }

  /// Reveals the correct letter for the selected (or first empty) cell.
  /// Token accounting happens in EconomyController; this just mutates state.
  /// True when at least one cipher letter is not yet guessed correctly — i.e. a
  /// reveal hint would actually uncover something. Drives the hint button's
  /// enabled state so a token is never spent on a finished/all-correct board
  /// (e.g. after filling the whole quote with reveals).
  bool get canRevealMore {
    final s = _session;
    if (s == null || _completed || _reviewingSolved) return false;
    return s.cipherLetters.any((c) => !s.isGuessCorrect(c));
  }

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
    // A hint is also a "last found" letter: the chess-style last-move highlight
    // lands on the just-revealed cell too (not only typed letters), and holds
    // there until the next letter is placed.
    _lastLockedCipherLetter = target;
    // Advance the cursor forward from where the PLAYER was, not from the
    // revealed letter's first occurrence — otherwise hinting late in the quote
    // flung the cursor backward to an earlier copy. Fall back to the revealed
    // letter's position only when there is no current selection.
    final revealFrom = _selectedIndex ?? _indexOfLetter(target);
    _selectedIndex =
        _nextEmptyEditableIndexAfter(revealFrom) ??
        _nextEditableIndexAfter(revealFrom) ??
        _selectedIndex;
    _undoStack.clear(); // reveals are permanent
    _afterChange(advance: false);
  }

  void _afterChange({bool advance = true}) {
    // A fresh edit forks history: any redo future is no longer reachable.
    _redoStack.clear();
    final s = _session!;
    if (s.isSolved) {
      _completed = true;
      // A finished board reads clean: drop the last-entered highlight.
      _lastLockedCipherLetter = null;
      stopTimer();
      _storage.writeJson(StorageService.puzzleStateKey(s.quote.id), {
        'solved': true,
      });
    } else {
      if (advance) {
        // Smart cursor: skip filled cells (including the copies just
        // auto-filled) and land on the next empty one, falling back to the next
        // editable cell only when every blank is gone (a full, unconfirmed board).
        _selectedIndex =
            _nextEmptyEditableIndexAfter(_selectedIndex) ??
            _nextEditableIndexAfter(_selectedIndex) ??
            _selectedIndex;
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
      'redo': _redoStack.map((m) => m.toJson()).toList(),
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
