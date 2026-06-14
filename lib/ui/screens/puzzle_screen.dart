import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/haptics_service.dart';
import '../../services/music_service.dart';
import '../../services/sound_service.dart';
import '../../state/game_controller.dart';
import '../../state/settings_controller.dart';
import '../theme/palette.dart';
import '../widgets/cipher_board.dart';
import '../widgets/hint_bar.dart';
import '../widgets/puzzle_keyboard.dart';
import 'puzzle_complete_screen.dart';

/// The solving screen. Deliberately ad-free and chrome-light: just the
/// quote board, hints, and the keyboard.
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with WidgetsBindingObserver {
  bool _navigatedToComplete = false;
  bool _celebrating = false;
  bool _completeShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Idempotent: both the wave's onEnd and a back press during the wave
  /// route here, and only the first call navigates.
  void _goToComplete() {
    if (!mounted || _completeShown) return;
    _completeShown = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PuzzleCompleteScreen()),
    );
  }

  // The solve clock only runs while the puzzle is actually on screen:
  // backgrounding, calls, and full-screen overlays pause it.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final game = context.read<GameController>();
    if (state == AppLifecycleState.resumed) {
      game.resumeTimer();
    } else {
      game.stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final settings = context.watch<SettingsController>().settings;
    final haptics = context.read<HapticsService>();
    final sounds = context.read<SoundService>();
    final session = game.session;
    final palette = Theme.of(context).extension<GamePalette>()!;

    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    // Completion -> celebrate once: success cue, a left-to-right wave of
    // green across the board, then the complete screen. Reduced-motion
    // users skip the wave and navigate immediately.
    if (game.completed && !_navigatedToComplete) {
      _navigatedToComplete = true;
      haptics.success();
      sounds.success();
      // The bed dips under the fanfare and swells back afterwards.
      context.read<MusicService>().duck();
      if (MediaQuery.of(context).disableAnimations) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _goToComplete());
      } else {
        _celebrating = true;
      }
    }

    // Leaving during the 620ms celebration must not abandon the completion
    // flow — the solve is only recorded on the complete screen. Back (button
    // or gesture) skips the wave and lands there instead. Once the complete
    // screen has been shown (_completeShown), pop is allowed again so the
    // back button can NEVER dead-end on this screen.
    final intercept = _celebrating && !_completeShown;
    return PopScope(
      canPop: !intercept,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToComplete();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (intercept) {
                _goToComplete();
                return;
              }
              game.stopTimer();
              Navigator.of(context).maybePop();
            },
          ),
          title: Text(
            game.isDaily
                ? 'Daily Puzzle'
                : session.quote.difficulty.name[0].toUpperCase() +
                      session.quote.difficulty.name.substring(1),
          ),
          actions: [
            if (settings.showTimer)
              _TimerText(elapsedListenable: game.elapsedListenable),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
                  child: Column(
                    children: [
                      // The board only repaints when the game state actually
                      // changes — clock ticks repaint just the AppBar text.
                      RepaintBoundary(
                        child: _celebrating
                            // The wave drives navigation from onEnd:
                            // animation frames keep the test clock alive (a
                            // bare Future.delayed would stall pumpAndSettle).
                            ? TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 620),
                                curve: Curves.easeOut,
                                onEnd: _goToComplete,
                                builder: (context, wave, _) => CipherBoard(
                                  session: session,
                                  selected: null,
                                  errorChecking: settings.errorChecking,
                                  onSelect: (_) {},
                                  solveWave: wave,
                                ),
                              )
                            : CipherBoard(
                                session: session,
                                selected: game.selectedCipherLetter,
                                errorChecking: settings.errorChecking,
                                onSelect: (c) {
                                  haptics.tap();
                                  game.selectCipherLetter(c);
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '— ${session.quote.author}',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Controls keep a bounded text scale: the quote board above
              // honors the user's large-type preference fully, but buttons
              // and keys must never overflow on narrow screens.
              MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HintBar(),
                    const SizedBox(height: 4),
                    PuzzleKeyboard(
                      usedLetters: session.usedPlainLetters,
                      canUndo: game.canUndo,
                      onUndo: () {
                        haptics.tap();
                        game.undo();
                      },
                      onLetter: (ch) {
                        game.enterGuess(ch);
                        if (game.lastInputCreatedConflict) {
                          haptics.error();
                          sounds.conflict();
                        } else if (game.lastInputCompletedWord) {
                          // Finishing a whole word earns a brighter blip and a
                          // distinct soft buzz, not a plain key tap.
                          haptics.wordComplete();
                          sounds.wordComplete();
                        } else {
                          haptics.tap();
                          sounds.tap();
                        }
                      },
                      onBackspace: () {
                        haptics.tap();
                        game.clearGuess();
                      },
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The solve clock in the AppBar. Listens to the dedicated tick notifier so
/// each second repaints ONLY this text — never the board or keyboard.
class _TimerText extends StatelessWidget {
  const _TimerText({required this.elapsedListenable});

  final ValueListenable<Duration> elapsedListenable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: ValueListenableBuilder<Duration>(
          valueListenable: elapsedListenable,
          builder: (context, elapsed, _) {
            final minutes = elapsed.inMinutes;
            final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
            return Text(
              '$minutes:$seconds',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: scheme.onSurface.withValues(alpha: .6),
              ),
            );
          },
        ),
      ),
    );
  }
}
