import 'package:flutter/services.dart';

/// Centralized haptic feedback (safely inert on web).
class HapticsService {
  HapticsService({required this.isEnabled});

  bool Function() isEnabled;

  void tap() {
    if (isEnabled()) HapticFeedback.selectionClick();
  }

  void success() {
    if (isEnabled()) HapticFeedback.mediumImpact();
  }

  void error() {
    if (isEnabled()) HapticFeedback.heavyImpact();
  }
}
