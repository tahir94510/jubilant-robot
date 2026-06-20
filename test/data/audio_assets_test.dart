import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Audio QA as a test: every sound the app preloads must exist as a real
/// WAV, and the music bed must stay inside its size budget (it is by far
/// the largest asset in the bundle).
void main() {
  // The low-latency UI effects stay as small WAVs (click-free, instant).
  const effects = [
    'tap.wav',
    'hint.wav',
    'conflict.wav',
    'success.wav',
    'achievement.wav',
    'word.wav',
  ];

  // The six shuffled, crossfading music beds — OGG/Vorbis to keep the bundle
  // small (16-bit WAV was ~20MB, which Play flags as a large download).
  const musicTracks = [
    'music_calm_1.ogg',
    'music_calm_2.ogg',
    'music_calm_3.ogg',
    'music_calm_4.ogg',
    'music_calm_5.ogg',
    'music_calm_6.ogg',
  ];

  test('every UI effect exists, is nonempty, and is RIFF/WAVE', () {
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

  test('every music bed exists, is nonempty, and is OGG', () {
    for (final name in musicTracks) {
      final file = File('assets/audio/$name');
      expect(file.existsSync(), isTrue, reason: '$name is missing');
      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(1000), reason: '$name too small');
      expect(
        String.fromCharCodes(bytes.take(4)),
        'OggS',
        reason: '$name lacks the OggS magic',
      );
    }
  });

  test('the music playlist stays within its total size budget', () {
    // Six ~72-88s mono OGG/Vorbis beds (~0.13MB each). The whole set must stay
    // well under 2MB — a jump past it means someone shipped WAV again or
    // bloated the bitrate, which Play flags as a large download.
    var total = 0;
    for (final name in musicTracks) {
      final length = File('assets/audio/$name').lengthSync();
      expect(length, greaterThan(40 * 1024), reason: '$name is too small');
      expect(length, lessThan(600 * 1024), reason: '$name is too big');
      total += length;
    }
    expect(total, lessThan(2 * 1024 * 1024), reason: 'playlist too large');
  });
}
