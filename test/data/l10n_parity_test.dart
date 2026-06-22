import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the 7-language promise at CI time. Every UI string in the English
/// template (`app_en.arb`) must exist — non-empty — in all six translated ARBs.
/// A missing key silently falls back to English at runtime, so a dropped or
/// mistyped translation would otherwise ship a half-English screen unnoticed;
/// here it fails the build instead. `localization_test.dart` only spot-checks a
/// few rendered strings — this is the exhaustive key-level guarantee.
void main() {
  const locales = ['tr', 'es', 'de', 'fr', 'it', 'pt'];

  Map<String, dynamic> readArb(String locale) =>
      jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;

  // Translatable keys only: drop gen-l10n metadata (@key) and the @@locale tag.
  Set<String> stringKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  final enKeys = stringKeys(readArb('en'));

  test('English template defines a substantial set of strings', () {
    expect(enKeys.length, greaterThan(150));
  });

  test('every English key is present in all 6 translated ARB files', () {
    for (final locale in locales) {
      final missing = enKeys.difference(stringKeys(readArb(locale)));
      expect(
        missing,
        isEmpty,
        reason:
            'app_$locale.arb is missing ${missing.length} key(s) present in '
            'app_en.arb (these fall back to English at runtime): $missing',
      );
    }
  });

  test('no translated ARB carries a key English does not define', () {
    for (final locale in locales) {
      final extra = stringKeys(readArb(locale)).difference(enKeys);
      expect(
        extra,
        isEmpty,
        reason:
            'app_$locale.arb defines ${extra.length} key(s) absent from the '
            'English template (a dead or mistyped translation): $extra',
      );
    }
  });

  test('no translated value is blank', () {
    for (final locale in locales) {
      for (final entry in readArb(locale).entries) {
        if (entry.key.startsWith('@')) continue;
        expect(
          (entry.value as String).trim(),
          isNotEmpty,
          reason: 'app_$locale.arb has a blank value for "${entry.key}"',
        );
      }
    }
  });
}
