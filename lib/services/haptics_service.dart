import 'package:flutter/services.dart';

/// Centralized haptic feedback (safely inert on web).
class HapticsService {
  HapticsService({required this.isEnabled});

  bool Function() isEnabled;

  void tap() {
    if (isEnabled()) HapticFeedback.selectionClick();
  }

  /// A soft, distinct buzz when a whole word falls into place: more than a
  /// key tap, lighter than a full solve.
  void wordComplete() {
    if (isEnabled()) HapticFeedback.lightImpact();
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
