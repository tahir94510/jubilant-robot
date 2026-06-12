import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/quote.dart';
import '../../state/game_controller.dart';
import '../../state/settings_controller.dart';
import '../widgets/brand_mark.dart';
import 'home_screen.dart';
import 'puzzle_screen.dart';

/// 30-second interactive tutorial: three short explanation steps, then a
/// real (tiny) cryptogram the player solves with the actual game UI.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// Famous, friendly, and short — the tutorial puzzle.
  static final Quote tutorialQuote = Quote(
    id: 'tutorial-001',
    text: 'Less is more.',
    author: 'Robert Browning',
    source: 'Andrea del Sarto, 1855',
    category: 'wisdom',
  );

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _page = 0;

  static const _steps = [
    (
      Icons.swap_horiz,
      'Every letter is swapped',
      'In a cryptogram, each letter of the alphabet stands for a different one. E might be K, T might be A — but the swap is consistent everywhere.',
    ),
    (
      Icons.psychology_outlined,
      'Crack it with patterns',
      'Short words are footholds: a single letter is usually A or I, and THE is everywhere. Letter frequency is your friend.',
    ),
    (
      Icons.touch_app_outlined,
      'Tap, then type',
      'Tap any cell to select that cipher letter, then choose its real letter on the keyboard. Identical letters fill in together.',
    ),
  ];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _startTutorialPuzzle() async {
    await context.read<SettingsController>().markOnboardingDone();
    if (!mounted) return;
    context.read<GameController>().start(
      OnboardingScreen.tutorialQuote,
      daily: false,
    );
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PuzzleScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (icon, title, body) = _steps[i];
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
                              color: scheme.onSurface.withValues(alpha: .65),
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
                for (var i = 0; i < _steps.length; i++)
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
                    onPressed: _page < _steps.length - 1
                        ? () => _pages.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          )
                        : _startTutorialPuzzle,
                    child: Text(
                      _page < _steps.length - 1
                          ? 'Next'
                          : 'Try one — 30 seconds',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await context
                          .read<SettingsController>()
                          .markOnboardingDone();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      }
                    },
                    child: const Text('Skip'),
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
