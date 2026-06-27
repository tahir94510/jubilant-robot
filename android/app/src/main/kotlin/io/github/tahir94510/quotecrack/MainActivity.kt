package io.github.tahir94510.quotecrack

import android.content.pm.ActivityInfo
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Lock to portrait at RUNTIME, not via android:screenOrientation in the
        // manifest. A static manifest orientation lock makes Google Play drop
        // landscape-only form factors (Android Automotive head units, a few
        // landscape tablets) from the supported-device catalog. Setting it here
        // keeps the app portrait on phones (and the launch splash upright) while
        // leaving those devices installable, because Play's static manifest scan
        // never sees this runtime call. main.dart also pins portrait for the
        // Flutter UI as a second layer.
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        super.onCreate(savedInstanceState)
    }
}
