import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/widgets/hold_repeat.dart';

void main() {
  testWidgets('a single tap fires the action exactly once', (tester) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: HoldRepeatDetector(
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );

    await tester.tap(find.byType(SizedBox));
    await tester.pump();

    expect(count, 1);
  });

  testWidgets('holding down repeats the action with an accelerating cadence', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: HoldRepeatDetector(
          onPressed: () => count++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SizedBox)),
    );
    expect(count, 1); // fires immediately on press-down

    // Before the initial delay elapses, no repeat yet.
    await tester.pump(const Duration(milliseconds: 200));
    expect(count, 1);

    // Past the initial delay, the first repeat fires.
    await tester.pump(const Duration(milliseconds: 200));
    expect(count, 2);

    // Held long enough for several accelerating repeats.
    await tester.pump(const Duration(seconds: 1));
    expect(count, greaterThan(2));

    await gesture.up();
    final afterRelease = count;
    await tester.pump(const Duration(seconds: 1));
    // Releasing stops the repeat: no further calls after pointer-up.
    expect(count, afterRelease);
  });

  testWidgets('a null onPressed mid-hold stops the repeat', (tester) async {
    var count = 0;
    Widget build(VoidCallback? onPressed) => MaterialApp(
      home: HoldRepeatDetector(
        onPressed: onPressed,
        child: const SizedBox(width: 40, height: 40),
      ),
    );

    await tester.pumpWidget(build(() => count++));
    await tester.startGesture(tester.getCenter(find.byType(SizedBox)));
    expect(count, 1);

    await tester.pump(const Duration(milliseconds: 600));
    final beforeDisable = count;
    expect(beforeDisable, greaterThan(1));

    // Reaching a boundary mid-hold (e.g. undo stack emptied, board cleared)
    // flips onPressed to null on the same widget instance: didUpdateWidget
    // must cancel the in-flight timer immediately, not on the next tick.
    await tester.pumpWidget(build(null));
    final afterDisable = count;
    await tester.pump(const Duration(seconds: 1));
    expect(count, afterDisable);
  });
}
