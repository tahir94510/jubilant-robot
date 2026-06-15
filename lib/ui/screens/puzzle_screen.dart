import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Captures hardware-keyboard input so the puzzle is fully playable by
  /// typing on PC, tablet, and TV — not just by tapping the on-screen keys.
  final FocusNode _keyboardFocus = FocusNode(debugLabel: 'puzzleKeyboard');

  /// Bumped each time a guess introduces a conflict; the board shakes once in
  /// response, reinforcing the red tint + error haptic + conflict chime.
  int _conflictPulse = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Shared input path for both the on-screen keyboard and physical keys, so
  /// the feedback (haptics + sound cues) is identical however the player types.
  void _onLetter(String ch) {
    final game = context.read<GameController>();
    final haptics = context.read<HapticsService>();
    final sounds = context.read<SoundService>();
    game.enterGuess(ch);
    if (game.lastInputCreatedConflict) {
      haptics.error();
      sounds.conflict();
      // enterGuess already notifies listeners (rebuild), which picks up the
      // new pulse value and drives the shake — no extra setState needed.
      _conflictPulse++;
    } else if (game.lastInputCompletedWord) {
      haptics.wordComplete();
      sounds.wordComplete();
    } else {
      haptics.tap();
      sounds.tap();
    }
  }

  void _onBackspace() {
    context.read<HapticsService>().tap();
    context.read<GameController>().clearGuess();
  }

  void _onUndo() {
    context.read<HapticsService>().tap();
    context.read<GameController>().undo();
  }

  /// Routes physical-keyboard input: letters type, Backspace/Delete clears,
  /// arrows move the cursor, and Ctrl/Cmd+Z undoes.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final game = context.read<GameController>();
    if (game.completed) return KeyEventResult.ignored;
    final key = event.logicalKey;

    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    final ctrlOrCmd =
        pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight) ||
        pressed.contains(LogicalKeyboardKey.metaLeft) ||
        pressed.contains(LogicalKeyboardKey.metaRight);
    if (ctrlOrCmd && key == LogicalKeyboardKey.keyZ) {
      if (game.canUndo) _onUndo();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      _onBackspace();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowDown) {
      game.moveSelection(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowUp) {
      game.moveSelection(-1);
      return KeyEventResult.handled;
    }
    // A typed letter (layout-aware via event.character; fall back to the
    // key's label for environments that don't populate the character).
    // Accept it only if it belongs to this puzzle's alphabet.
    final session = game.session;
    final raw = event.character ?? key.keyLabel;
    if (session != null && raw.isNotEmpty) {
      final typed = session.alphabet.normalize(raw);
      if (typed.length == 1 && session.alphabet.isLetter(typed)) {
        _onLetter(typed);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
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
      child: Focus(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKeyEvent: _handleKey,
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
            // Cap + center the board and keyboard on large screens (tablet,
            // desktop, TV) so they don't sprawl edge-to-edge; a no-op on
            // phones narrower than the cap.
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
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
                                      duration: const Duration(
                                        milliseconds: 620,
                                      ),
                                      curve: Curves.easeOut,
                                      onEnd: _goToComplete,
                                      builder: (context, wave, _) =>
                                          CipherBoard(
                                            session: session,
                                            selected: null,
                                            errorChecking:
                                                settings.errorChecking,
                                            onSelect: (_) {},
                                            solveWave: wave,
                                          ),
                                    )
                                  : _Shaker(
                                      trigger: _conflictPulse,
                                      child: CipherBoard(
                                        session: session,
                                        selected: game.selectedCipherLetter,
                                        errorChecking: settings.errorChecking,
                                        onSelect: (index) {
                                          haptics.tap();
                                          game.selectIndex(index);
                                        },
                                      ),
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
                            rows: session.alphabet.keyboardRows,
                            usedLetters: session.usedPlainLetters,
                            canUndo: game.canUndo,
                            onUndo: _onUndo,
                            onLetter: _onLetter,
                            onBackspace: _onBackspace,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plays a single damped horizontal shake whenever [trigger] changes — used
/// to punctuate a conflicting guess. Honors the system "remove animations"
/// setting by passing the child straight through.
class _Shaker extends StatefulWidget {
  const _Shaker({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<_Shaker> createState() => _ShakerState();
}

class _ShakerState extends State<_Shaker> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void didUpdateWidget(_Shaker old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger != 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Decaying sine: a couple of quick swings that settle to centre.
        final dx = t == 0 ? 0.0 : math.sin(t * math.pi * 4) * 7 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
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
