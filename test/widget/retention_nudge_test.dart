import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/screens/puzzle_screen.dart';

import '../fakes/test_harness.dart';
import 'puzzle_flow_test.dart' show solveByTapping;

/// The one-time streak-protection invite: appears exactly once, right
/// after a daily solve, and any answer dismisses it forever.
void main() {
  Future<Harness> solveDaily(WidgetTester tester, {bool daily = true}) async {
    final h = await Harness.create();
    h.game.start(shortQuote, daily: daily);
    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();
    return h;
  }

  // The card sits below the fold of the (lazy) results list.
  Future<void> revealNudge(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.text('Remind me daily'), 150);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToBottom(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
  }

  testWidgets('accepting the invite schedules the daily reminder', (
    tester,
  ) async {
    final h = await solveDaily(tester);

    await revealNudge(tester);
    expect(find.text('Protect your streak'), findsOneWidget);

    await tester.tap(find.text('Remind me daily'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.reminderEnabled, isTrue);
    expect(h.settings.settings.reminderNudgeDone, isTrue);
    expect(h.notifications.scheduledAt, isNotNull);
    expect(find.text('Protect your streak'), findsNothing);

    h.game.stopTimer();
  });

  testWidgets('"Not now" dismisses it forever without enabling anything', (
    tester,
  ) async {
    final h = await solveDaily(tester);

    await revealNudge(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.reminderEnabled, isFalse);
    expect(h.settings.settings.reminderNudgeDone, isTrue);
    expect(h.notifications.scheduledAt, isNull);
    expect(find.text('Protect your streak'), findsNothing);

    h.game.stopTimer();
  });

  testWidgets('a denied first request leaves it off and never re-nags', (
    tester,
  ) async {
    final h = await solveDaily(tester);
    // A genuine block: the OS refuses and reports notifications off (no real
    // grant to fall back to). The first tap shows the system prompt (denied
    // here), so the reminder stays off — no custom dialog, the invite is just
    // dismissed. An explicit "No" is respected, not redirected to settings.
    h.notifications.permissionGranted = false;
    h.notifications.osEnabled = false;

    await revealNudge(tester);
    await tester.tap(find.text('Remind me daily'));
    await tester.pumpAndSettle();

    expect(h.settings.settings.reminderEnabled, isFalse);
    expect(h.settings.settings.reminderNudgeDone, isTrue);
    // First denial respects the "No": no system-settings redirect.
    expect(h.notifications.openSettingsCalls, 0);
    expect(find.text('Protect your streak'), findsNothing);

    h.game.stopTimer();
  });

  testWidgets('pack (non-daily) solves never show the invite', (tester) async {
    final h = await solveDaily(tester, daily: false);

    await scrollToBottom(tester);
    expect(find.text('Protect your streak'), findsNothing);

    h.game.stopTimer();
  });

  testWidgets('already-enabled reminders suppress the invite', (tester) async {
    final h = await Harness.create();
    await h.settings.setReminder(enabled: true);
    h.game.start(shortQuote, daily: true);
    await tester.pumpWidget(h.app(const PuzzleScreen()));
    await tester.pump();
    await solveByTapping(tester, h);
    await tester.pumpAndSettle();

    await scrollToBottom(tester);
    expect(find.text('Protect your streak'), findsNothing);

    h.game.stopTimer();
  });
}
