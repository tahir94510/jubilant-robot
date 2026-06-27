import 'package:flutter/services.dart';

/// Centralized haptic feedback (safely inert on web).
class HapticsService {
  HapticsService({required this.isEnabled});

  bool Function() isEnabled;

  /// A per-keystroke tick. Uses [HapticFeedback.lightImpact] rather than
  /// [HapticFeedback.selectionClick]: on Android the latter maps to the
  /// CLOCK_TICK constant, which most devices render as nothing perceptible (it
  /// is also suppressed unless the system "touch feedback" toggle is on), so the
  /// keyboard felt completely dead. A light impact is the lightest cue that is
  /// reliably *felt* on a phone while still being subtle enough for every key.
  void tap() {
    if (isEnabled()) HapticFeedback.lightImpact();
  }

  /// A soft, distinct buzz when a whole word falls into place: more than a
  /// key tap, lighter than a full solve.
  void wordComplete() {
    if (isEnabled()) HapticFeedback.mediumImpact();
  }

  void success() {
    if (isEnabled()) HapticFeedback.mediumImpact();
  }

  /// The full-solve fanfare — the biggest beat in the game, so it lands the
  /// hardest: a heavy impact, synced with the success chime, the green board
  /// wave and the confetti. (A solve should never feel weaker than the error
  /// buzz, which it did while this shared the medium [success] impact.)
  void celebrate() {
    if (isEnabled()) HapticFeedback.heavyImpact();
  }

  void error() {
    if (isEnabled()) HapticFeedback.heavyImpact();
  }
}
