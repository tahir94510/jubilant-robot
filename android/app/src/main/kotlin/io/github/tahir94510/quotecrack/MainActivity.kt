package io.github.tahir94510.quotecrack

import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "quotecrack/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// Opens this app's system notification settings — the recovery path when
    /// POST_NOTIFICATIONS is denied (Android 13+ won't re-prompt once denied).
    /// Falls back to the app details page on OEMs/older OS without the action.
    private fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            startActivity(intent)
        } catch (e: Exception) {
            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            try {
                startActivity(fallback)
            } catch (_: Exception) {
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Phones stay portrait (the board + on-screen keyboard are designed for a
        // tall layout); large screens are left FREE to rotate and resize. Google
        // Play's large-screen quality checks (and Android's large-screen
        // orientation behavior) penalise a hard orientation lock on tablets and
        // foldables, so we decide by the device's smallest width: >= 600dp is a
        // tablet/foldable and gets the unrestricted (system-default) orientation,
        // anything smaller is a phone and is pinned portrait. Done at RUNTIME (not
        // via android:screenOrientation) so the static manifest scan never drops
        // landscape form factors from the device catalog. main.dart applies the
        // same 600dp rule to the Flutter UI as a second layer.
        requestedOrientation = if (resources.configuration.smallestScreenWidthDp >= 600) {
            ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
        } else {
            ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        }
        super.onCreate(savedInstanceState)
        // Backward-compatible edge-to-edge, straight from Play's pre-launch
        // recommendation for SDK 35+ targets: Android 15+ forces edge-to-edge
        // by itself, but OLDER versions only draw behind the system bars when
        // the app opts in natively. Flutter's SystemUiMode.edgeToEdge does opt
        // in from Dart, yet only once the engine is up — this native call makes
        // the very first frame edge-to-edge on every Android version and
        // clears the Console advisory. (FlutterActivity is not a
        // ComponentActivity, so androidx.activity's enableEdgeToEdge() is not
        // available; WindowCompat is its documented equivalent.) The app's
        // SafeArea/PageBody insets are already in place on every screen.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        // Paint the post-splash window to match the APP's chosen theme, not the
        // device's. The cream system splash hands off to this window while Flutter
        // initialises; NormalTheme's windowBackground follows the DEVICE theme, so
        // a light-themed app on a dark device (or vice versa) used to flash the
        // wrong background here before the first frame. Best-effort: any failure
        // leaves the theme's device-based surface untouched.
        try {
            window.setBackgroundDrawable(
                ColorDrawable(if (appPrefersDark()) 0xFF161512.toInt() else 0xFFF7F4EC.toInt()),
            )
        } catch (_: Exception) {
        }
    }

    /// Reads the app's saved theme preference (shared_preferences' legacy store)
    /// to decide whether the launch window should be dark. "dark" -> dark;
    /// "light"/"sepia" -> light; "system"/absent/unreadable -> follow the device.
    /// Deliberately tolerant (regex over the settings JSON, broad catch): a parse
    /// miss simply falls back to the device theme, never crashes the launch.
    private fun appPrefersDark(): Boolean {
        val deviceDark = (resources.configuration.uiMode and
            Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        return try {
            val prefs = getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE,
            )
            val json = prefs.getString("flutter.settings.v1", null) ?: return deviceDark
            val mode = Regex("\"themeMode\"\\s*:\\s*\"(\\w+)\"")
                .find(json)?.groupValues?.getOrNull(1)
            when (mode) {
                "dark" -> true
                "light", "sepia" -> false
                else -> deviceDark
            }
        } catch (_: Exception) {
            deviceDark
        }
    }
}
