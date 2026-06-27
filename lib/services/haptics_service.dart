import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Centralized haptic feedback.
///
/// Prefers a REAL, amplitude-controlled vibration (Android's `VibrationEffect`,
/// driven by the `vibration` plugin) so a cue is actually *felt* — Flutter's
/// built-in [HapticFeedback] maps to the near-imperceptible CLOCK_TICK /
/// keyboard-tap constants on most Android devices, which is why "nothing
/// vibrates" was reported. Falls back to [HapticFeedback] when there is no
/// controllable vibrator, on web, in tests, or if the plugin call fails — and
/// every cue stays gated by the user's Haptics setting. Never throws.
class HapticsService {
  HapticsService({required this.isEnabled}) {
    // Probe the vibrator ONCE, asynchronously, and cache the result so each cue
    // stays synchronous and cheap. Fire-and-forget: until it resolves (or if it
    // fails) the service simply uses the framework-haptic fallback.
    _detectCapabilities();
  }

  bool Function() isEnabled;

  /// Whether the device exposes a vibrator the plugin can drive, and whether it
  /// supports per-call amplitude. Cached from a one-time async probe.
  bool _hasVibrator = false;
  bool _hasAmplitude = false;

  Future<void> _detectCapabilities() async {
    if (kIsWeb) return; // browsers: the HapticFeedback path only
    try {
      // Typed as nullable so this compiles whether the plugin returns bool or
      // bool? across versions, and never trips a dead-null-aware lint.
      final bool? has = await Vibration.hasVibrator();
      _hasVibrator = has == true;
      if (_hasVibrator) {
        final bool? amp = await Vibration.hasAmplitudeControl();
        _hasAmplitude = amp == true;
      }
    } catch (_) {
      // No plugin / unsupported platform: stay on the framework-haptic path.
      _hasVibrator = false;
      _hasAmplitude = false;
    }
  }

  /// Plays [ms]/[amplitude] as a real vibration when one is available, else runs
  /// the framework-haptic [fallback]. All gated by the user's Haptics setting.
  void _buzz(int ms, int amplitude, void Function() fallback) {
    if (!isEnabled()) return;
    if (!kIsWeb && _hasVibrator) {
      _safeVibrate(ms, amplitude);
      return;
    }
    fallback();
  }

  /// Fire-and-forget vibration that swallows any error (missing plugin,
  /// transient native failure) so a hiccup never bubbles up. Returns a
  /// Future<void> regardless of the plugin's return type, so the caller can
  /// discard it cleanly.
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

  /// A crisp per-keystroke tick.
  void tap() => _buzz(12, 90, HapticFeedback.lightImpact);

  /// A soft, distinct buzz when a whole word falls into place: more than a key
  /// tap, lighter than a full solve.
  void wordComplete() => _buzz(28, 165, HapticFeedback.mediumImpact);

  void success() => _buzz(38, 200, HapticFeedback.mediumImpact);

  /// The full-solve fanfare — the biggest beat in the game, so it lands the
  /// hardest, synced with the success chime, the green board wave and confetti.
  void celebrate() => _buzz(55, 255, HapticFeedback.heavyImpact);

  /// A firm error buzz for a conflicting guess (only when error checking is on).
  void error() => _buzz(45, 230, HapticFeedback.heavyImpact);
}
