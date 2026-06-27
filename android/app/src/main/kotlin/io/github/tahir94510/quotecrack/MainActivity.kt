package io.github.tahir94510.quotecrack

import android.content.Intent
import android.content.pm.ActivityInfo
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
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
    }
}
