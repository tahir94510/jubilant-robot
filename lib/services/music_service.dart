import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

/// Looping ambient background music (assets/audio/music_calm.wav, generated
/// by tool/generate_music.py): one quiet bed under the whole app.
///
/// Starts after launch — or on the first tap where autoplay is restricted
/// (web) — pauses with the app lifecycle, and is gated by the user's
/// "Music" setting. Registered as a [WidgetsBindingObserver] in main().
class MusicService with WidgetsBindingObserver {
  MusicService({required this.isEnabled});

  final bool Function() isEnabled;

  /// The bed's base level at full user volume. The mastered track already sits
  /// low under the sound effects (it peaks at ~0.55 of full scale), so the bed
  /// needs real gain here to be present rather than a whisper — the old 0.30
  /// left it inaudible once the user nudged the slider down. [setUserVolume]
  /// scales it from the Settings slider.
  static const double _baseVolume = 0.95;

  /// Fraction of the playing level the bed dips to under the success fanfare.
  /// Deliberately not near-zero: the fanfare should ride *over* the bed, not
  /// erase it, so the two never cancel each other out.
  static const double _duckFactor = 0.38;

  /// 0..1 user multiplier from settings (musicVolume).
  double _userVolume = 0.70;

  /// The level the bed plays at right now, honoring the user's choice.
  double get _targetVolume => _baseVolume * _userVolume;
  double get _duckVolume => _targetVolume * _duckFactor;

  AudioPlayer? _player;
  bool _ready = false;
  bool _playing = false;
  double _volume = 0;
  Timer? _fadeTimer;
  Timer? _duckTimer;

  /// Applies the user's music-volume preference (0..1). Fades smoothly to the
  /// new level if the bed is currently playing.
  void setUserVolume(double value) {
    _userVolume = value.clamp(0.0, 1.0);
    if (_playing && isEnabled()) {
      _duckTimer?.cancel();
      _fadeTo(_targetVolume, duration: const Duration(milliseconds: 280));
    }
  }

  Future<void> initialize() async {
    try {
      final p = AudioPlayer();
      // A long looping track, not a UI blip: the media-player path suits it
      // better than the low-latency mode SoundService uses. The global
      // audio context (game/media stream, no audio focus) set by
      // SoundService stays untouched — quiet ambience must never pause the
      // user's own podcast or music. If music ever needs different focus,
      // audioplayers supports a per-player setAudioContext on Android.
      await p.setPlayerMode(PlayerMode.mediaPlayer);
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(0);
      await p.setSource(AssetSource('audio/music_calm.wav'));
      _player = p;
      _ready = true;
    } catch (_) {
      // Audio is never worth crashing over (emulators without audio,
      // restricted web contexts...): stay silent instead.
      _ready = false;
    }
  }

  /// Starts the loop if it should play and isn't playing yet. Safe to call
  /// often: browsers reject autoplay until the first user gesture, so the
  /// app retries from a global tap listener until one attempt sticks, and
  /// every later call is a no-op.
  void ensureStarted() {
    final p = _player;
    if (!_ready || _playing || p == null || !isEnabled()) return;
    _playing = true; // optimistic; reverted if the play attempt is rejected
    unawaited(
      p
          .resume()
          .then((_) => _fadeTo(_targetVolume))
          .catchError((_) => _playing = false),
    );
  }

  /// Briefly dips the bed under the success fanfare, then restores it. The
  /// hold spans the full ~1.7 s fanfare (plus a beat) so the bed never swells
  /// back up while the solve chord is still ringing.
  void duck({Duration hold = const Duration(milliseconds: 2000)}) {
    final p = _player;
    if (!_ready || p == null || !_playing || !isEnabled()) return;
    _duckTimer?.cancel();
    _fadeTo(_duckVolume, duration: const Duration(milliseconds: 250));
    _duckTimer = Timer(hold, () {
      if (_playing && isEnabled()) _fadeTo(_targetVolume);
    });
  }

  /// Applies the Settings toggle immediately (fade in / fade out + pause).
  Future<void> setEnabled(bool on) async {
    final p = _player;
    if (!_ready || p == null) return;
    _duckTimer?.cancel(); // a toggle always outranks a pending un-duck
    if (on) {
      ensureStarted();
      // Mid-fade-out toggles still need the volume ramped back up.
      _fadeTo(_targetVolume);
    } else {
      _fadeTo(
        0,
        duration: const Duration(milliseconds: 300),
        onDone: () {
          _playing = false;
          unawaited(p.pause().catchError((_) {}));
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final p = _player;
    if (!_ready || p == null) return;
    if (state == AppLifecycleState.resumed) {
      if (_playing && isEnabled()) {
        unawaited(p.resume().catchError((_) {}));
        _fadeTo(_targetVolume, duration: const Duration(milliseconds: 600));
      }
    } else {
      // Backgrounded, covered by a call or a full-screen ad: duck out
      // smoothly before pausing so the bed never gets chopped mid-note.
      _duckTimer?.cancel();
      _fadeTo(
        0,
        duration: const Duration(milliseconds: 220),
        onDone: () => unawaited(p.pause().catchError((_) {})),
      );
    }
  }

  void _fadeTo(
    double target, {
    Duration duration = const Duration(milliseconds: 1200),
    VoidCallback? onDone,
  }) {
    _fadeTimer?.cancel();
    final p = _player;
    if (p == null) return;
    // ~60 fps steps with a smoothstep curve. Fine-grained, eased ramps avoid
    // the "zipper" crackle that coarse 50 ms linear volume jumps produced on
    // quick fades (duck, background, toggle).
    const stepMs = 16;
    final steps = (duration.inMilliseconds / stepMs).ceil().clamp(1, 100000);
    final start = _volume;
    var i = 0;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: stepMs), (t) {
      i++;
      final x = (i / steps).clamp(0.0, 1.0);
      final eased = x * x * (3 - 2 * x); // smoothstep
      _volume = (start + (target - start) * eased).clamp(0.0, 1.0);
      unawaited(p.setVolume(_volume).catchError((_) {}));
      if (i >= steps) {
        t.cancel();
        onDone?.call();
      }
    });
  }

  void dispose() {
    _fadeTimer?.cancel();
    _duckTimer?.cancel();
    _player?.dispose();
  }
}
