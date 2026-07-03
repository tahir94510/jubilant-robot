import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/screens/puzzle_complete_screen.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';
import 'package:quotecrack/ui/widgets/puzzle_keyboard.dart';

import '../fakes/test_harness.dart';

/// Taps the correct key for whichever cipher letter is currently selected,
/// until the puzzle is solved.
Future<void> solveByTapping(WidgetTester tester, Harness h) async {
  for (var safety = 0; safety < 60; safety++) {
    final session = h.game.session!;
    if (session.isSolved) break;
    final target = h.game.selectedCipherLetter;
    expect(target, isNotNull, reason: 'a cell should always be selected');
    final plain = session.cipher.decryptLetter(target!);
    await tester.tap(
      find.descendant(
        of: find.byType(PuzzleKeyboard),
        matching: find.text(plain),
      ),
    );
    await tester.pump();
  }
}

void main() {
  testWidgets('player solves a puzzle end to end', (tester) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    await solveByTapping(tester, h);
    expect(h.game.session!.isSolved, isTrue);

    // Completion navigates to the celebration screen.
    await tester.pumpAndSettle();
    expect(find.byType(PuzzleCompleteScreen), findsOneWidget);
    expect(find.textContaining('Robert Browning'), findsOneWidget);

    // Recording happened exactly once.
    expect(h.progress.stats.totalSolved, 1);
    expect(h.economy.completedCount, 1);

    // The interstitial decision was delegated with the right counter.
    expect(h.ads.interstitialRequests, [1]);

    h.game.stopTimer();
  });

  testWidgets('daily solve records streak and shows share button', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: true);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();

    expect(h.progress.stats.currentStreak, 1);
    expect(h.progress.dailySolvedToday, isTrue);
    expect(find.text('Share result'), findsOneWidget);

    h.game.stopTimer();
  });

  testWidgets('replaying a solved puzzle farms no tokens or interstitials', (
    tester,
  ) async {
    final h = await Harness.create();

    // First solve: earns a token, advances the cadence counter.
    h.game.start(shortQuote, daily: false);
    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();
    final tokensAfterFirst = h.economy.tokens;
    expect(h.economy.completedCount, 1);
    expect(h.ads.interstitialRequests, hasLength(1));

    // Replay the same puzzle: stats, tokens, and ads must not move.
    // (Reset the widget tree first — otherwise the Navigator keeps showing
    // the previous completion route.)
    await tester.pumpWidget(const SizedBox());
    h.game.start(shortQuote, daily: false);
    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();

    expect(h.progress.stats.totalSolved, 1);
    expect(h.economy.tokens, tokensAfterFirst);
    expect(h.economy.completedCount, 1);
    expect(h.ads.interstitialRequests, hasLength(1));

    h.game.stopTimer();
  });

  testWidgets('solve clock pauses while the app is backgrounded', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    await tester.pump(const Duration(seconds: 2));
    final beforeBackground = h.game.elapsed;
    expect(beforeBackground.inSeconds, greaterThanOrEqualTo(2));

    // Background the app: the ticker must stop counting.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 30));
    expect(h.game.elapsed, beforeBackground);

    // Foreground again: counting resumes from where it left off.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 2));
    expect(
      h.game.elapsed.inSeconds,
      inInclusiveRange(
        beforeBackground.inSeconds + 1,
        beforeBackground.inSeconds + 3,
      ),
    );

    h.game.stopTimer();
  });

  testWidgets('hint reveals a correct letter and spends a token', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final tokensBefore = h.economy.tokens;
    await tester.tap(find.textContaining('Reveal letter'));
    await tester.pump();

    expect(h.economy.tokens, tokensBefore - 1);
    expect(h.game.hintsUsed, 1);
    final s = h.game.session!;
    final revealed = s.revealed.single;
    expect(s.guesses[revealed], s.cipher.decryptLetter(revealed));

    h.game.stopTimer();
  });

  testWidgets('at zero tokens the hint button shows (0), disables, and the '
      'rewarded +3 stays available', (tester) async {
    final h = await Harness.create();
    while (h.economy.tokens > 0) {
      h.economy.spendHintToken();
    }
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final label = find.text('Reveal letter (0)');
    expect(label, findsOneWidget);
    final button = tester.widget<OutlinedButton>(
      find.ancestor(of: label, matching: find.byType(OutlinedButton)).first,
    );
    expect(button.enabled, isFalse);

    // Tapping the dead button must not reveal anything for free.
    await tester.tap(label, warnIfMissed: false);
    await tester.pump();
    expect(h.game.hintsUsed, 0);

    // The way out is the rewarded ad, which stays visible.
    expect(find.text('+3'), findsOneWidget);

    h.game.stopTimer();
  });

  testWidgets('word reveal opens the selected word and charges its price', (
    tester,
  ) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: false); // "Less is more."

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // Cursor on "LESS": 3 distinct letters -> the button shows the price.
    expect(h.game.wordHintCost, 3);
    final tokensBefore = h.economy.tokens;

    await tester.tap(find.textContaining('Reveal word'));
    await tester.pump();

    expect(h.economy.tokens, tokensBefore - 3);
    expect(h.game.hintsUsed, 3);
    expect(h.game.session!.revealed, hasLength(3));

    h.game.stopTimer();
  });

  testWidgets('word reveal disables when the player cannot afford it', (
    tester,
  ) async {
    final h = await Harness.create();
    // Leave fewer tokens than "LESS" costs (3).
    while (h.economy.tokens > 2) {
      h.economy.spendHintToken();
    }
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    final label = find.textContaining('Reveal word');
    final button = tester.widget<OutlinedButton>(
      find.ancestor(of: label, matching: find.byType(OutlinedButton)).first,
    );
    expect(button.enabled, isFalse);

    // A dead tap must neither reveal nor charge.
    await tester.tap(label, warnIfMissed: false);
    await tester.pump();
    expect(h.game.hintsUsed, 0);
    expect(h.economy.tokens, 2);

    h.game.stopTimer();
  });

  testWidgets(
    'a stale-enabled hint tap after tokens hit zero mutates nothing',
    (tester) async {
      final h = await Harness.create();
      // Down to exactly one token so the button builds enabled.
      while (h.economy.tokens > 1) {
        h.economy.spendHintToken();
      }
      h.game.start(shortQuote, daily: false);

      await tester.pumpWidget(h.app(const PuzzleScreen()));
      await tester.pump();

      // Give the undo stack something to lose if the guard ever regressed.
      final target = h.game.selectedCipherLetter!;
      h.game.enterGuess(h.game.session!.cipher.decryptLetter(target));
      await tester.pump();
      expect(h.game.canUndo, isTrue);

      // Drain the last token WITHOUT pumping: the frame on screen still shows
      // the enabled button whose closure captured the pre-drain state — a
      // deterministic simulation of the rebuild-to-tap race.
      h.economy.spendHintToken();
      expect(h.economy.tokens, 0);

      await tester.tap(find.textContaining('Reveal letter'));
      await tester.pump();

      // The tap-time re-check must have bailed before any mutation.
      expect(h.game.hintsUsed, 0);
      expect(h.game.session!.revealed, isEmpty);
      expect(h.game.canUndo, isTrue, reason: 'undo history must be preserved');
      expect(h.economy.tokens, 0, reason: 'tokens must never go negative');

      h.game.stopTimer();
    },
  );

  testWidgets('rewarded +3 greys out when no ad is available (offline), and '
      'grants nothing when tapped', (tester) async {
    final h = await Harness.create();
    // Offline / no fill: no rewarded ad is loaded.
    h.ads.rewardedAvailableNotifier.value = false;
    h.game.start(shortQuote, daily: false);

    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();

    // The button is still shown, but disabled — never a free hint offline.
    final label = find.text('+3');
    expect(label, findsOneWidget);
    OutlinedButton rewardedButton() => tester.widget<OutlinedButton>(
      find.ancestor(of: label, matching: find.byType(OutlinedButton)).first,
    );
    expect(rewardedButton().enabled, isFalse);

    final tokensBefore = h.economy.tokens;
    await tester.tap(label, warnIfMissed: false);
    await tester.pump();
    expect(h.ads.rewardedShown, 0); // no ad shown
    expect(h.economy.tokens, tokensBefore); // no tokens granted

    // Once an ad loads, the button enables and a watch grants the reward.
    h.ads.rewardedAvailableNotifier.value = true;
    await tester.pump();
    expect(rewardedButton().enabled, isTrue);
    await tester.tap(label);
    await tester.pump();
    expect(h.ads.rewardedShown, 1);
    expect(h.economy.tokens, tokensBefore + 3);

    h.game.stopTimer();
  });
}
