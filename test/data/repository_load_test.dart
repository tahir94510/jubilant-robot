import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/quote_repository.dart';

/// Verifies the REAL asset-manifest loading path (QuoteRepository.load), not
/// just the in-memory fromQuotes used elsewhere: every bundled locale must be
/// discovered, and the daily pool must stay English-only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'load() discovers every bundled locale via the asset manifest',
    () async {
      final repo = await QuoteRepository.load();

      final locales = repo.all.map((q) => q.locale).toSet();
      expect(
        locales,
        containsAll(<String>{'en', 'tr', 'es', 'de', 'fr', 'it', 'pt'}),
        reason: 'a locale pack failed to load from the manifest',
      );

      // English base plus the native packs.
      expect(repo.all.length, greaterThan(510));

      // The shared daily stays English and covers a leap year.
      expect(repo.dailyPool.every((q) => q.locale == 'en'), isTrue);
      expect(repo.dailyPool.length, greaterThanOrEqualTo(366));
    },
  );
}
