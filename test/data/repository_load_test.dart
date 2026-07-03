import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/engine/quote_repository.dart';
import 'package:quotecrack/models/pack.dart';

/// Verifies the REAL asset-manifest loading path (QuoteRepository.load), not
/// just the in-memory fromQuotes used elsewhere: every bundled locale must be
/// discovered, and the daily pool must stay English-only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const supportedLocales = ['en', 'tr', 'es', 'de', 'fr', 'it', 'pt'];

  test(
    'load() discovers every bundled locale via the asset manifest',
    () async {
      final repo = await QuoteRepository.load();

      final locales = repo.all.map((q) => q.locale).toSet();
      expect(
        locales,
        containsAll(supportedLocales.toSet()),
        reason: 'a locale pack failed to load from the manifest',
      );

      // English base plus the native packs.
      expect(repo.all.length, greaterThan(510));

      // The shared daily stays English and covers a leap year.
      expect(repo.dailyPool.every((q) => q.locale == 'en'), isTrue);
      expect(repo.dailyPool.length, greaterThanOrEqualTo(366));
    },
  );

  test('every locale has a native, homogeneous daily pool (streak-integrity '
      'guard)', () async {
    final repo = await QuoteRepository.load();

    // Home decides "daily solved today?" by the UI locale, but the solve is
    // recorded under the QUOTE's locale (puzzle_complete_screen). Those two
    // agree only while dailyPoolFor(locale) never triggers its English
    // fallback: if a locale shipped without native dailies, its daily solves
    // would land in the 'en' profile and that language's streak would
    // silently never advance. This locks the invariant that makes the pair
    // of lookups consistent.
    for (final locale in supportedLocales) {
      final pool = repo.dailyPoolFor(locale);
      expect(
        pool,
        isNotEmpty,
        reason: 'locale "$locale" has an empty daily pool',
      );
      expect(
        pool.every((q) => q.locale == locale),
        isTrue,
        reason:
            'locale "$locale" fell back to another language\'s daily pool — '
            'its daily solves would be recorded into the wrong profile',
      );
    }
  });

  test('every language fills every pack — all four difficulty rungs, all four '
      'themes, and the premium Classics pack', () async {
    final repo = await QuoteRepository.load();

    for (final locale in supportedLocales) {
      for (final pack in Pack.catalog) {
        final quotes = repo.forPack(pack, activeLocale: locale);
        expect(
          quotes,
          isNotEmpty,
          reason:
              'locale "$locale" has no quotes in pack "${pack.id}" — a player '
              'switching to that language would see an empty pack',
        );
        // Every quote actually belongs to this language and this pack.
        expect(
          quotes.every((q) => q.locale == locale),
          isTrue,
          reason: 'pack "${pack.id}" leaked a non-$locale quote',
        );
      }

      // The premium Classics pack must be genuinely stocked, not a token
      // one-off, in every language.
      final classics = repo.forPack(
        Pack.byId('classics'),
        activeLocale: locale,
      );
      expect(
        classics.length,
        greaterThanOrEqualTo(20),
        reason: 'locale "$locale" has a thin premium Classics pack',
      );
    }
  });
}
