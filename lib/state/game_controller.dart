import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/puzzle.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

/// Undo record: one guess assignment.
class _Move {
  _Move(this.cipherLetter, this.previousGuess);
  final String cipherLetter;
  final String? previousGuess;
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

  String? _selectedCipherLetter;
  String? get selectedCipherLetter => _selectedCipherLetter;

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

  /// Starts (or resumes) a puzzle for [quote].
  void start(Quote quote, {required bool daily, String? packId}) {
    _originPackId = packId;
    _ticker?.cancel();
    final saved = _storage.readJson(StorageService.puzzleStateKey(quote.id));

    Map<String, String>? savedGuesses;
    if (saved != null && saved['solved'] != true) {
      savedGuesses = (saved['guesses'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      );
    }

    _session = PuzzleSession(quote: quote, guesses: savedGuesses);
    if (saved != null && saved['solved'] != true) {
      _session!.revealed.addAll(
        ((saved['revealed'] as List<dynamic>?) ?? const []).cast<String>(),
      );
      _hintsUsed = saved['hintsUsed'] as int? ?? 0;
      _elapsed = Duration(seconds: saved['elapsedSeconds'] as int? ?? 0);
    } else {
      _hintsUsed = 0;
      _elapsed = Duration.zero;
    }

    _isDaily = daily;
    _completed = false;
    _lastInputCreatedConflict = false;
    _lastInputCompletedWord = false;
    elapsedListenable.value = _elapsed;
    _selectedCipherLetter = _firstEmptyCipherLetter();
    _undoStack.clear();

    _startTicker();
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
    // elapsed time, not just the last guess.
    if (_session != null && !_completed) _persistState();
  }

  /// Restarts the ticker after a lifecycle pause (app backgrounded, ad
  /// overlay, phone call) so off-screen time never counts as solve time.
  void resumeTimer() {
    if (_session != null && !_completed && _ticker == null) {
      _startTicker();
    }
  }

  String? _firstEmptyCipherLetter() {
    final s = _session;
    if (s == null) return null;
    for (final ch in s.cipherText.split('')) {
      if (s.cipherLetters.contains(ch) && !s.guesses.containsKey(ch)) {
        return ch;
      }
    }
    return null;
  }

  void selectCipherLetter(String? cipherLetter) {
    _selectedCipherLetter = cipherLetter;
    notifyListeners();
  }

  /// Assigns [plainLetter] to the selected cipher letter, auto-advances to
  /// the next empty cell, and detects completion.
  void enterGuess(String plainLetter) {
    // Any new interaction invalidates the one-shot cue, even when the call
    // turns out to be a no-op (stale flags must never replay a sound).
    _lastInputCompletedWord = false;
    final s = _session;
    final target = _selectedCipherLetter;
    if (s == null || target == null || _completed) return;
    if (s.revealed.contains(target)) return;

    _undoStack.add(_Move(target, s.guesses[target]));
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

  void clearGuess() {
    _lastInputCompletedWord = false;
    final s = _session;
    final target = _selectedCipherLetter;
    if (s == null || target == null || _completed) return;
    if (s.revealed.contains(target)) return;
    if (!s.guesses.containsKey(target)) return;

    _undoStack.add(_Move(target, s.guesses[target]));
    s.guesses.remove(target);
    _afterChange(advance: false);
  }

  void undo() {
    _lastInputCompletedWord = false;
    final s = _session;
    if (s == null || _undoStack.isEmpty || _completed) return;
    final move = _undoStack.removeLast();
    if (move.previousGuess == null) {
      s.guesses.remove(move.cipherLetter);
    } else {
      s.guesses[move.cipherLetter] = move.previousGuess!;
    }
    _selectedCipherLetter = move.cipherLetter;
    _persistState();
    notifyListeners();
  }

  /// Reveals the correct letter for the selected (or first empty) cell.
  /// Token accounting happens in EconomyController; this just mutates state.
  void revealSelected() {
    _lastInputCompletedWord = false; // hints have their own chime
    final s = _session;
    if (s == null || _completed) return;
    var target = _selectedCipherLetter ?? _firstEmptyCipherLetter();
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
        _selectedCipherLetter =
            _firstEmptyCipherLetter() ?? _selectedCipherLetter;
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
