import 'dart:async';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Centralized, platform-aware haptic feedback.
///
/// One cue API for the whole app; the *delivery* is chosen per platform so each
/// device gets the feedback that actually feels right there:
///
///  * **iOS / macOS** → Flutter's [HapticFeedback] (the Taptic engine:
///    light/medium/heavy impacts). The `vibration` plugin on iOS maps to a
///    coarse ~0.5s system buzz that is wrong for a per-keystroke tick, so we
///    never use it there.
///  * **Android** → a REAL, amplitude-controlled vibration via the `vibration`
///    plugin (Android's `VibrationEffect`) so a cue is genuinely *felt* —
///    Flutter's built-in [HapticFeedback] maps to the near-imperceptible
///    CLOCK_TICK / keyboard-tap constants on most Android devices, which is why
///    "nothing vibrates" was reported. Falls back to [HapticFeedback] when the
///    device exposes no controllable vibrator.
///  * **Web / other desktop** → [HapticFeedback] (a graceful no-op on most).
///
/// Every cue is gated by the user's Haptics setting and never throws.
class HapticsService {
  HapticsService({required this.isEnabled}) {
    // Probe the vibrator ONCE, asynchronously, and cache the result so each cue
    // stays synchronous and cheap. Fire-and-forget: until it resolves (or if it
    // fails) the service simply uses the framework-haptic fallback.
    _detectCapabilities();
  }

  bool Function() isEnabled;

  /// True only on a platform where we drive the `vibration` plugin directly
  /// (Android). iOS/macOS use the Taptic engine; web/other desktop have no
  /// motor we manage, so they take the framework-haptic path.
  static bool get _usesVibrationPlugin =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the device exposes a vibrator the plugin can drive, and whether it
  /// supports per-call amplitude. Cached from a one-time async probe; only ever
  /// true on the [_usesVibrationPlugin] path.
  bool _hasVibrator = false;
  bool _hasAmplitude = false;

  Future<void> _detectCapabilities() async {
    if (!_usesVibrationPlugin) return; // iOS/web/desktop: HapticFeedback only
    try {
      _hasVibrator = await Vibration.hasVibrator();
      if (_hasVibrator) {
        _hasAmplitude = await Vibration.hasAmplitudeControl();
      }
    } catch (_) {
      // No plugin / unsupported platform: stay on the framework-haptic path.
      _hasVibrator = false;
      _hasAmplitude = false;
    }
  }

  /// Plays [ms]/[amplitude] as a real vibration when one is available (Android
  /// with a controllable motor), else runs the framework-haptic [fallback]
  /// (iOS Taptic engine, web/desktop). All gated by the user's Haptics setting.
  void _buzz(int ms, int amplitude, void Function() fallback) {
    if (!isEnabled()) return;
    if (_usesVibrationPlugin && _hasVibrator) {
      // Decouple the motor from any sound effect dispatched in the SAME frame
      // (puzzle input plays a cue and buzzes together). A bare microtask still
      // landed the motor's current spike during the clip's attack/decay, which
      // couples into the speaker amp and reads as a click/crackle on the wrong-
      // letter cue. A short fixed delay moves the spike clear of the clip's
      // body so the software-induced part of that crackle is gone. (The residual
      // is pure hardware coupling, which only the Haptics toggle fully removes.)
      Timer(
        const Duration(milliseconds: 20),
        () => _safeVibrate(ms, amplitude),
      );
      return;
    }
    fallback();
  }

  /// Fire-and-forget vibration that swallows any error (missing plugin,
  /// transient native failure) so a hiccup never bubbles up. Always returns a
  /// `Future<void>` so the caller can discard it cleanly.
  Future<void> _safeVibrate(int ms, int amplitude) async {
    try {
      if (_hasAmplitude) {
        await Vibration.vibrate(duration: ms, amplitude: amplitude);
      } else {
        await Vibration.vibrate(duration: ms);
      }
    } catch (_) {
      // A vibration that fails mid-game should never surface to the player.
    }
  }

  // A deliberate weight ladder, each step clearly distinct from the next so the
  // hand can tell a keystroke from a word-lock from a full solve. The baseline
  // tap was bumped from 12ms/90 — too faint to feel next to the much heavier
  // error buzz, which read as "only errors vibrate". Now every interaction is
  // noticeably felt while staying proportional to its meaning:
  //   tap 18/130  <  word 30/180  <  success 42/215  <  error 48/235  <  solve 60/255
  // (ms duration / 0-255 amplitude on Android devices with amplitude control;
  // devices without it still get a real buzz of that DURATION, so the ladder
  // survives. iOS maps each step to the matching Taptic impact weight below.)

  /// A crisp per-keystroke / navigation tick — light but clearly felt.
  void tap() => _buzz(18, 130, HapticFeedback.selectionClick);

  /// A soft, distinct buzz when a whole word falls into place: more than a key
  /// tap, lighter than a full solve.
  void wordComplete() => _buzz(30, 180, HapticFeedback.mediumImpact);

  void success() => _buzz(42, 215, HapticFeedback.mediumImpact);

  /// The full-solve fanfare — the biggest beat in the game, so it lands the
  /// hardest, synced with the success chime, the green board wave and confetti.
  void celebrate() => _buzz(60, 255, HapticFeedback.heavyImpact);

  /// A firm error buzz for a conflicting guess (only when error checking is on).
  void error() => _buzz(48, 235, HapticFeedback.heavyImpact);
}
