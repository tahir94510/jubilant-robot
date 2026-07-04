import 'dart:io';
import 'dart:typed_data';

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

  test('every UI effect is click-free: silent edges, no clipping', () {
    // A cue that starts/ends at a non-zero sample CLICKS when it (re)triggers,
    // and a peak at full scale hard-clips when cues overlap — both read as
    // the "crackle" the SoLoud migration eliminated. The generator applies
    // raised-cosine edge fades to true zero (tool/generate_sounds.py); this
    // locks that property so a regenerated asset can never sneak a click back.
    for (final name in effects) {
      final bytes = File('assets/audio/$name').readAsBytesSync();
      final data = bytes.buffer.asByteData();
      // Walk RIFF chunks to the PCM payload ('data'); 16-bit little-endian.
      var offset = 12;
      int dataStart = -1, dataLength = 0;
      while (offset + 8 <= bytes.length) {
        final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
        final size = data.getUint32(offset + 4, Endian.little);
        if (id == 'data') {
          dataStart = offset + 8;
          dataLength = size;
          break;
        }
        offset += 8 + size + (size.isOdd ? 1 : 0);
      }
      expect(dataStart, greaterThan(0), reason: '$name has no data chunk');

      final sampleCount = dataLength ~/ 2;
      int sampleAt(int i) => data.getInt16(dataStart + i * 2, Endian.little);

      var peak = 0;
      for (var i = 0; i < sampleCount; i++) {
        final a = sampleAt(i).abs();
        if (a > peak) peak = a;
      }
      // Headroom: at or past full scale the SUM of overlapping cues clips.
      expect(
        peak / 32768,
        lessThan(0.95),
        reason: '$name peaks near full scale — overlapping cues will clip',
      );
      // Silent edges: first/last samples at (near) zero = click-free
      // trigger and tail. Threshold 1% of full scale (~-40 dBFS).
      expect(
        sampleAt(0).abs() / 32768,
        lessThan(0.01),
        reason: '$name starts abruptly (click on trigger)',
      );
      expect(
        sampleAt(sampleCount - 1).abs() / 32768,
        lessThan(0.01),
        reason: '$name ends abruptly (click on tail)',
      );
    }
  });

  test('the music playlist stays within its total size budget', () {
    // Six ~72-88s 44.1kHz STEREO OGG/Vorbis beds (~0.2MB each). The whole set
    // must stay well under 2MB — a jump past it means someone shipped WAV again
    // or bloated the bitrate, which Play flags as a large download.
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
