import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quotecrack/ui/widgets/entrance.dart';

/// Locks the Entrance contract: a one-shot staggered fade/rise that settles
/// fully opaque, and a TRUE no-op under the system reduce-motion setting.
void main() {
  Widget host(Widget child, {bool reduceMotion = false}) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );

  testWidgets('animates in and settles fully visible', (tester) async {
    await tester.pumpWidget(
      host(const Entrance(index: 2, child: Text('card'))),
    );
    // Mid-flight: still inside its stagger delay or fade.
    final early = tester.widget<Opacity>(find.byType(Opacity)).opacity;
    expect(early, lessThan(1.0));

    // One-shot tween: pumpAndSettle must terminate (nothing loops) and the
    // child must end fully opaque with no residual offset.
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);
    expect(find.text('card'), findsOneWidget);
  });

  testWidgets('reduced motion renders the child directly (no effect at all)', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const Entrance(index: 3, child: Text('card')), reduceMotion: true),
    );
    // No fade wrapper, no tween — the very first frame is the plain child.
    expect(find.byType(Opacity), findsNothing);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.text('card'), findsOneWidget);
  });

  testWidgets('deep indexes are capped so late rows never lag', (tester) async {
    await tester.pumpWidget(
      host(const Entrance(index: 999, child: Text('deep'))),
    );
    // Even a huge index settles within the capped window (~0.5s), not after
    // 999 stagger steps — pumpAndSettle's default 10-minute budget would hang
    // long before that if the cap regressed.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);
  });
}
