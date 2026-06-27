import 'package:flutter/widgets.dart';

import '../../services/haptics_service.dart';

/// Fires a settings-gated tap haptic on every route push and pop, so opening a
/// screen, a bottom sheet or a dialog — and backing out of one — gives the same
/// tactile feedback the puzzle keyboard already does. One place covers every
/// navigation interaction in the app, instead of wiring haptics into dozens of
/// scattered `onTap`s.
///
/// Deliberately ignores the very first route (where [previousRoute] is null at
/// app launch) so the app doesn't buzz on startup, and ignores [didReplace]
/// (the puzzle → completion `pushReplacement`) so the solve celebration is never
/// muddied by a stray tap buzz under the fanfare.
class HapticRouteObserver extends NavigatorObserver {
  HapticRouteObserver(this.haptics);

  final HapticsService haptics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) haptics.tap();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    haptics.tap();
  }
}
