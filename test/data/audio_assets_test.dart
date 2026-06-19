import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Audio QA as a test: every sound the app preloads must exist as a real
/// WAV, and the music bed must stay inside its size budget (it is by far
/// the largest asset in the bundle).
void main() {
  // The six shuffled, crossfading music beds (tool/generate_music.py).
  const musicTracks = [
    'music_calm_1.wav',
    'music_calm_2.wav',
    'music_calm_3.wav',
    'music_calm_4.wav',
    'music_calm_5.wav',
    'music_calm_6.wav',
  ];

  const effects = [
    'tap.wav',
    'hint.wav',
    'conflict.wav',
    'success.wav',
    'achievement.wav',
    'word.wav',
    ...musicTracks,
  ];

  test('every audio asset exists, is nonempty, and is RIFF/WAVE', () {
    for (final name in effects) {
      final file = File('assets/audio/$name');
      expect(file.existsSync(), isTrue, reason: '$name is missing');
      final bytes = file.readAsBytesSync();
      expect(
        bytes.length,
        greaterThan(1000),
        reason: '$name is suspiciously small',
      );
      expect(
        String.fromCharCodes(bytes.take(4)),
        'RIFF',
        reason: '$name lacks the RIFF magic',
      );
      expect(
        String.fromCharCodes(bytes.skip(8).take(4)),
        'WAVE',
        reason: '$name lacks the WAVE magic',
      );
    }
  });

  test('the music playlist stays within its total size budget', () {
    // Six ~72-88s mono 22.05kHz 16-bit beds (~3.4MB each), kept light on
    // purpose. Each must be a real, non-trivial track, and the whole set must
    // stay under a sane ceiling — a jump past it means someone regenerated at
    // a higher rate/length (or added tracks) and bloated the app size.
    var total = 0;
    for (final name in musicTracks) {
      final length = File('assets/audio/$name').lengthSync();
      expect(length, greaterThan(2500 * 1024), reason: '$name is too small');
      expect(length, lessThan(5000 * 1024), reason: '$name is too big');
      total += length;
    }
    expect(total, lessThan(26 * 1024 * 1024), reason: 'playlist too large');
  });
}
