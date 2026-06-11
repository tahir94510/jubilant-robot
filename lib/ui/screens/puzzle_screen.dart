import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/haptics_service.dart';
import '../../state/game_controller.dart';
import '../../state/settings_controller.dart';
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
    final session = game.session;
    final scheme = Theme.of(context).colorScheme;

    if (session == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    // Completion -> celebrate once, replace with the complete screen.
    if (game.completed && !_navigatedToComplete) {
      _navigatedToComplete = true;
      haptics.success();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PuzzleCompleteScreen()),
          );
        }
      });
    }

    final minutes = game.elapsed.inMinutes;
    final seconds = (game.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            game.stopTimer();
            Navigator.of(context).pop();
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '$minutes:$seconds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface.withValues(alpha: .6),
                  ),
                ),
              ),
            ),
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
                    CipherBoard(
                      session: session,
                      selected: game.selectedCipherLetter,
                      errorChecking: settings.errorChecking,
                      onSelect: (c) {
                        haptics.tap();
                        game.selectCipherLetter(c);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '— ${session.quote.author}',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: scheme.onSurface.withValues(alpha: .45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                haptics.tap();
                game.enterGuess(ch);
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
    );
  }
}
