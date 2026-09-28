package com.example.voice_orb_example

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.voice_orb/control"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    override fun onPostResume() {
        super.onPostResume()
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val step = intent?.getStringExtra("step")
        val preset = intent?.getStringExtra("preset")
        val compact = intent?.getStringExtra("compact")
        val settings = intent?.getStringExtra("settings")
        if (step != null) {
            methodChannel?.invokeMethod("setTourStep", step.toIntOrNull() ?: 0)
        }
        if (preset != null) {
            methodChannel?.invokeMethod("setPreset", preset)
        }
        if (compact != null) {
            methodChannel?.invokeMethod("setCompact", compact == "true")
        }
        if (settings != null) {
            methodChannel?.invokeMethod("setSettings", settings == "true")
        }
    }
}
