import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/config/app_config.dart';

/// Locks the two sources of the user-facing version together. The Settings
/// screen shows [AppConfig.appVersion]; the store/build labels come from the
/// versionName in pubspec.yaml. They are hand-edited on each release, so
/// without this guard a release could bump one and forget the other — leaving
/// Settings advertising a stale version (exactly the "it still says the old
/// version after updating" symptom). Here the build fails instead.
void main() {
  test('AppConfig.appVersion matches the pubspec versionName', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    // `version: 2.10.0+48` -> capture the versionName before the build (+N).
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)(?:\+\d+)?\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml must declare a semver `version:` line',
    );
    final pubspecVersion = match!.group(1);

    expect(
      AppConfig.appVersion,
      pubspecVersion,
      reason:
          'AppConfig.appVersion (${AppConfig.appVersion}) must equal the '
          'pubspec versionName ($pubspecVersion) so Settings never shows a '
          'stale version. Bump BOTH on every release.',
    );
  });
}
