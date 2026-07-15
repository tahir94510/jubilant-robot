import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/services/sound_service.dart';

/// Locks the voice-protection policy that fixes the "cue cut off mid-ring"
/// bug: every meaningful cue must be protected from SoLoud's voice-culling,
/// with only the disposable 55 ms keystroke tap left unprotected (it is the
/// correct victim under voice-pool pressure, and it gets its own concurrency
/// cap instead). A future cue added to the asset list must make a deliberate
/// choice here — this test turns forgetting into a red build.
void main() {
  // The full effect family shipped in assets/audio (mirrors SoundService's
  // private asset list; audio_assets_test verifies the files themselves).
  const allCues = {
    'tap.wav',
    'hint.wav',
    'conflict.wav',
    'success.wav',
    'achievement.wav',
    'word.wav',
  };

  test('every cue except the keystroke tap is protected from voice-culling', () {
    expect(
      SoundService.protectedCues,
      allCues.difference({'tap.wav'}),
      reason:
          'an unprotected bell can be culled mid-ring during a typing burst — '
          'the exact "sound cuts off" bug this policy fixes',
    );
  });

  test('the tap concurrency cap is small enough to spare the voice pool but '
      'large enough that human typing never trips it', () {
    expect(SoundService.maxConcurrentTaps, greaterThanOrEqualTo(4));
    expect(SoundService.maxConcurrentTaps, lessThanOrEqualTo(16));
  });
}
