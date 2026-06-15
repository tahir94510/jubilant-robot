import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/screens/settings_screen.dart';

import '../fakes/test_harness.dart';

/// The UI must actually localize: the Settings screen renders its strings in
/// the selected language, and English remains the default.
void main() {
  testWidgets('Settings renders in Turkish when the locale is tr', (
    tester,
  ) async {
    final h = await Harness.create();
    await tester.pumpWidget(
      h.app(const SettingsScreen(), locale: const Locale('tr')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget); // Settings (app bar)
    expect(find.text('Uygulama dili'), findsOneWidget); // App language
    expect(find.text('Sistem varsayılanı'), findsOneWidget); // System default
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('Settings renders in English by default', (tester) async {
    final h = await Harness.create();
    await tester.pumpWidget(
      h.app(const SettingsScreen(), locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('App language'), findsOneWidget);
  });
}
