import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Audio QA as a test: every sound the app preloads must exist as a real
/// WAV, and the music bed must stay inside its size budget (it is by far
/// the largest asset in the bundle).
void main() {
  const effects = [
    'tap.wav',
    'hint.wav',
    'conflict.wav',
    'success.wav',
    'achievement.wav',
    'word.wav',
    'music_calm.wav',
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

  test('the music bed stays within its size budget', () {
    // ~52s mono 22050Hz 16-bit. A jump past the ceiling means someone
    // regenerated it at a higher rate/length and doubled the app size.
    final length = File('assets/audio/music_calm.wav').lengthSync();
    expect(length, greaterThan(1500 * 1024));
    expect(length, lessThan(3500 * 1024));
  });
}
