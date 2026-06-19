import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Surfaces Google Play in-app updates so players learn about a new version
/// without leaving the app. Deliberately defensive: it is a NO-OP on anything
/// but a Play-installed Android build (web, sideload, emulator without Play,
/// iOS), and every call is wrapped so a failure can never affect launch.
///
/// Uses a *flexible* update (downloads in the background while the player keeps
/// playing, then installs on completion) — the least disruptive option.
class UpdateService {
  /// Checks for an update and, if one is available, starts a background
  /// flexible download and installs it once ready. Safe to call fire-and-forget
  /// right after launch.
  Future<void> maybePromptUpdate() async {
    // Only Play-distributed Android builds can use in-app updates.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }
      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          // The new version is downloaded; complete it (a no-op if the user
          // dismissed the system prompt).
          await InAppUpdate.completeFlexibleUpdate();
        }
      } else if (info.immediateUpdateAllowed) {
        // Fall back to an immediate (blocking) update only if flexible isn't
        // offered for this release.
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {
      // Not installed from Play, no Play services, offline, user cancelled,
      // platform channel missing in tests — never worth disturbing launch.
    }
  }
}
