package com.sunstep.travel

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Avoid restoring potentially incompatible parcelables from previous runs/versions.
        super.onCreate(null)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        SystemSettingsChannel.register(flutterEngine, this)
        BuildConfigChannel.register(flutterEngine)
    }
}