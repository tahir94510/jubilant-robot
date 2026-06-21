import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Brand-asset QA as a test: every committed store/icon raster must exist and
/// have the exact dimensions Google Play and the launcher expect. These are
/// generated deterministically by tool/generate_icons.py; locking their size
/// here catches a botched regeneration (wrong canvas, missing locale variant,
/// truncated file) before it ships.
///
/// We read the PNG header directly — width/height live big-endian in the IHDR
/// chunk at byte offsets 16 and 20 — so no image package dependency is needed.
void main() {
  // The Play feature graphic is localized: each Play Console listing language
  // can carry its own. tool/generate_icons.py emits one per locale plus the
  // canonical English filename.
  const featureLocales = ['en', 'tr', 'de', 'es', 'fr', 'it', 'pt'];

  ({int width, int height}) pngSize(File file) {
    final bytes = file.readAsBytesSync();
    // 8-byte signature, then the IHDR chunk: 4-byte length, "IHDR", then the
    // 4-byte width and 4-byte height.
    expect(
      bytes.length,
      greaterThan(24),
      reason: '${file.path} is too small to be a PNG',
    );
    const sig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    for (var i = 0; i < sig.length; i++) {
      expect(bytes[i], sig[i], reason: '${file.path} is not a PNG');
    }
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    return (width: data.getUint32(16), height: data.getUint32(20));
  }

  void expectAsset(String path, int w, int h) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: '$path is missing');
    final size = pngSize(file);
    expect(size, (
      width: w,
      height: h,
    ), reason: '$path must be ${w}x$h, got ${size.width}x${size.height}');
  }

  test('app icon masters exist at the right size', () {
    // True 2K source masters (generate_icons.py draws at 4096 and downscales).
    expectAsset('assets/icon/icon.png', 2048, 2048);
    expectAsset('assets/icon/icon_foreground.png', 2048, 2048);
    expectAsset('assets/icon/icon_monochrome.png', 2048, 2048);
  });

  test('Play listing icon is 512x512', () {
    expectAsset('store_assets/play_icon_512.png', 512, 512);
  });

  test('feature graphic exists for every locale at 1024x500', () {
    // Canonical English filename Play uses by default.
    expectAsset('store_assets/feature_graphic.png', 1024, 500);
    // Per-language variants for localized store listings.
    for (final loc in featureLocales) {
      expectAsset('store_assets/feature_graphic_$loc.png', 1024, 500);
    }
  });
}
