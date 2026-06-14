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

  void error() {
    if (isEnabled()) HapticFeedback.heavyImpact();
  }
}
