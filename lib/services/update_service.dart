import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Surfaces Google Play in-app updates so players learn about a new version
/// without leaving the app. Deliberately defensive: it is a NO-OP on anything
/// but a Play-installed Android build (web, sideload, emulator without Play,
/// iOS), and every call is wrapped so a failure can never affect launch.
///
/// Uses a *flexible* update (downloads in the background while the player keeps
/// playing). Crucially, the download is NOT auto-installed: completing a
/// flexible update restarts the app, and doing that unannounced threw players
/// out mid-session (it read as a crash). Instead [maybeStartUpdate] reports
/// "downloaded" and the app shows a "restart to update" prompt; the install
/// runs only from [completeUpdate] once the player agrees. If they ignore it,
/// Google Play finishes the stale download itself while the app is in the
/// background — either way, never a surprise exit.
class UpdateService {
  /// Checks for an update and, if one is available, runs the Play flexible
  /// download. Returns true once a new version is downloaded and staged, ready
  /// to install (pending user consent via [completeUpdate]); false in every
  /// other case. Safe to call fire-and-forget right after launch.
  Future<bool> maybeStartUpdate() async {
    // Only Play-distributed RELEASE Android builds can use in-app updates.
    // Skipping debug/profile avoids exercising the native Play flow during
    // development/testing, where it can't succeed anyway.
    if (kIsWeb ||
        !kReleaseMode ||
        defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }
      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        // Downloaded and staged — the CALLER asks the player before the
        // app-restarting install step.
        return result == AppUpdateResult.success;
      }
      if (info.immediateUpdateAllowed) {
        // Immediate (blocking, Play-driven full-screen) update only when
        // flexible isn't offered for this release. Play owns that UX,
        // including the restart.
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {
      // Not installed from Play, no Play services, offline, user cancelled,
      // platform channel missing in tests — never worth disturbing launch.
    }
    return false;
  }

  /// Installs the already-downloaded flexible update. This RESTARTS the app,
  /// so call it only after explicit user consent. Best-effort: a failure means
  /// Play completes the update in the background later instead.
  Future<void> completeUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {}
  }

  /// Play's install-status broadcast while a flexible download runs — lets the
  /// UI show a live "downloading…" indicator instead of a silent background
  /// download (which read as "the update button does nothing"). An empty
  /// stream where the platform channel is unavailable (tests, web, sideloads),
  /// so callers can subscribe unconditionally.
  Stream<InstallStatus> statusStream() {
    try {
      return InAppUpdate.installUpdateListener.handleError((_) {});
    } catch (_) {
      return const Stream.empty();
    }
  }
}
