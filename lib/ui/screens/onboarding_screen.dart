import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/quote.dart';
import '../../state/game_controller.dart';
import '../../state/settings_controller.dart';
import '../theme/palette.dart';
import '../widgets/brand_mark.dart';
import 'home_screen.dart';
import 'puzzle_screen.dart';

/// 30-second interactive tutorial: three short explanation steps, then a
/// real (tiny) cryptogram the player solves with the actual game UI.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.replay = false});

  /// True when opened from Settings as a refresher ("Replay tutorial"): the
  /// flow then layers onto the existing stack and returns the player to where
  /// they came from, and NEVER touches saved progress or the onboarding flag —
  /// versus the first-run flow, which marks onboarding done and rebuilds Home.
  final bool replay;

  /// The tutorial puzzle, one per language. These are chosen for *repeated
  /// words* ("there is a", "damlaya", "va… va… va"), not brevity: in a
  /// cryptogram repetition gives the footholds that make a solve feel easy,
  /// whereas a terse line like "Less is more." is actually expert-hard. The
  /// very first puzzle also greets players in their own language.
  static final Map<String, Quote> _tutorialQuotes = {
    'en': Quote(
      id: 'tutorial-en',
      text: 'Where there is a will, there is a way.',
      author: 'English proverb',
      source: 'Traditional',
      category: 'wisdom',
    ),
    'tr': Quote(
      id: 'tutorial-tr',
      text: 'Damlaya damlaya göl olur.',
      author: 'Türk atasözü',
      source: 'Geleneksel',
      category: 'turkish',
      locale: 'tr',
    ),
    'es': Quote(
      id: 'tutorial-es',
      text: 'Poco a poco se anda lejos.',
      author: 'Refrán español',
      source: 'Tradicional',
      category: 'spanish',
      locale: 'es',
    ),
    'de': Quote(
      id: 'tutorial-de',
      text: 'Ende gut, alles gut.',
      author: 'Deutsches Sprichwort',
      source: 'Überliefert',
      category: 'german',
      locale: 'de',
    ),
    'fr': Quote(
      id: 'tutorial-fr',
      text: "Petit à petit, l'oiseau fait son nid.",
      author: 'Proverbe français',
      source: 'Traditionnel',
      category: 'french',
      locale: 'fr',
    ),
    'it': Quote(
      id: 'tutorial-it',
      text: 'Chi va piano, va sano e va lontano.',
      author: 'Proverbio italiano',
      source: 'Tradizionale',
      category: 'italian',
      locale: 'it',
    ),
    'pt': Quote(
      id: 'tutorial-pt',
      text: 'Quem não arrisca, não petisca.',
      author: 'Provérbio português',
      source: 'Tradicional',
      category: 'portuguese',
      locale: 'pt',
    ),
  };

  /// The tutorial puzzle for [locale], falling back to English.
  static Quote tutorialQuoteFor(String locale) =>
      _tutorialQuotes[locale] ?? _tutorialQuotes['en']!;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _page = 0;

  static const _icons = [
    Icons.swap_horiz,
    Icons.psychology_outlined,
    Icons.touch_app_outlined,
  ];

  static String _title(AppLocalizations l10n, int i) =>
      [l10n.onbStep1Title, l10n.onbStep2Title, l10n.onbStep3Title][i];

  static String _body(AppLocalizations l10n, int i) =>
      [l10n.onbStep1Body, l10n.onbStep2Body, l10n.onbStep3Body][i];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _startTutorialPuzzle() async {
    final locale = Localizations.localeOf(context).languageCode;
    if (!widget.replay) {
      await context.read<SettingsController>().markOnboardingDone();
      if (!mounted) return;
    }
    context.read<GameController>().start(
      OnboardingScreen.tutorialQuoteFor(locale),
      daily: false,
    );
    final navigator = Navigator.of(context);
    if (widget.replay) {
      // Refresher from Settings: just layer the tutorial puzzle on top so
      // backing out returns the player to where they came from, untouched.
      navigator.push(MaterialPageRoute(builder: (_) => const PuzzleScreen()));
      return;
    }
    // First run: Home slides UNDER the stack with no animation; the player sees
    // one smooth transition straight into the puzzle (the old
    // pushReplacement+push pair ran two stacked animations — a visible
    // home-screen flash that read as a glitch).
    navigator.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (_) => false,
    );
    navigator.push(MaterialPageRoute(builder: (_) => const PuzzleScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<GamePalette>()!;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _icons.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final icon = _icons[i];
                  final title = _title(l10n, i);
                  final body = _body(l10n, i);
                  // Centered on roomy screens, scrollable on tiny ones with
                  // huge system text — a fixed Column overflowed 320x640
                  // at 1.6x scale.
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // The first page introduces the brand itself; the
                          // rest keep their topic icons.
                          if (i == 0)
                            const BrandMark(size: 96)
                          else
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Icon(
                                icon,
                                size: 48,
                                color: scheme.primary,
                              ),
                            ),
                          const SizedBox(height: 28),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: palette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _icons.length; i++)
                  Container(
                    width: i == _page ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _page < _icons.length - 1
                        ? () => _pages.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          )
                        : _startTutorialPuzzle,
                    child: Text(
                      _page < _icons.length - 1 ? l10n.onbNext : l10n.onbTryOne,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Refresher: just close back to where it was opened from;
                      // never re-mark onboarding or rebuild Home.
                      if (widget.replay) {
                        Navigator.of(context).pop();
                        return;
                      }
                      await context
                          .read<SettingsController>()
                          .markOnboardingDone();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      }
                    },
                    child: Text(widget.replay ? l10n.onbDone : l10n.onbSkip),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
