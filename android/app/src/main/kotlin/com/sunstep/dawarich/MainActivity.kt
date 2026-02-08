package com.sunstep.dawarich

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        SystemSettingsChannel.register(flutterEngine, this)
        BuildConfigChannel.register(flutterEngine)
    }
}