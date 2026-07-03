import 'package:flutter/foundation.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

/// Applies the player's refresh-rate preference to the display.
///
/// Normal mode unlocks high refresh (90/120Hz) where the OEM pins Flutter
/// apps to 60Hz (MIUI, some Samsung skins); battery saver asks for the
/// panel's LOWEST rate instead, trading silkiness for power draw — a real
/// lever on 120Hz OLEDs. Android-only underneath; a guarded, silent no-op on
/// web/tests/other platforms so it can never affect launch or gameplay.
class DisplayService {
  Future<void> apply({required bool batterySaver}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      if (batterySaver) {
        await FlutterDisplayMode.setLowRefreshRate();
      } else {
        await FlutterDisplayMode.setHighRefreshRate();
      }
    } catch (e) {
      debugPrint('Display-mode request failed (continuing): $e');
    }
  }
}
