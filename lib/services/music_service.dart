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

  /// Quiet by design: the bed sits well under the UI sound effects.
  static const double _targetVolume = 0.35;

  AudioPlayer? _player;
  bool _ready = false;
  bool _playing = false;
  double _volume = 0;
  Timer? _fadeTimer;

  Future<void> initialize() async {
    try {
      final p = AudioPlayer();
      // A long looping track, not a UI blip: the media-player path suits it
      // better than the low-latency mode SoundService uses. The global
      // audio context (mixWithOthers + respectSilence) stays untouched —
      // quiet ambience must never pause the user's own podcast or music.
      // If music ever needs different focus, audioplayers supports a
      // per-player setAudioContext on Android.
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

  /// Applies the Settings toggle immediately (fade in / fade out + pause).
  Future<void> setEnabled(bool on) async {
    final p = _player;
    if (!_ready || p == null) return;
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
        _fadeTo(_targetVolume, duration: const Duration(milliseconds: 500));
      }
    } else {
      // Backgrounded, covered by a call or a full-screen ad: go quiet.
      _fadeTimer?.cancel();
      unawaited(p.pause().catchError((_) {}));
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
    const stepMs = 50;
    final steps = (duration.inMilliseconds / stepMs).ceil();
    final start = _volume;
    var i = 0;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: stepMs), (t) {
      i++;
      _volume = (start + (target - start) * (i / steps)).clamp(0.0, 1.0);
      unawaited(p.setVolume(_volume).catchError((_) {}));
      if (i >= steps) {
        t.cancel();
        onDone?.call();
      }
    });
  }

  void dispose() {
    _fadeTimer?.cancel();
    _player?.dispose();
  }
}
