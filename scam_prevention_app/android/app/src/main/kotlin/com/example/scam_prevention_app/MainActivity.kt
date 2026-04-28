package com.example.scam_prevention_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.scamprevention/native"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkOtpProximity" -> {
                    // MOCKED: Here you would query recent SMS and Call Logs
                    // using ContentResolver and READ_SMS / READ_CALL_LOG permissions.
                    Log.d("NativeChannel", "Checking OTP Proximity...")
                    result.success(true) // Simulating we found an OTP within 2 mins
                }
                "blockBankingApps" -> {
                    val duration = call.argument<Int>("duration") ?: 15
                    // MOCKED: Here you would use an AccessibilityService to detect 
                    // foreground apps or draw a system overlay (SYSTEM_ALERT_WINDOW).
                    Log.d("NativeChannel", "Blocking banking apps for $duration minutes.")
                    result.success(null)
                }
                "triggerGuardianAlert" -> {
                    val alertType = call.argument<String>("alertType") ?: "Unknown"
                    // MOCKED: The prompt mentioned sending POST to FCM. 
                    // This can be done natively via OkHttp or via Dart.
                    Log.d("NativeChannel", "Triggering Alert: $alertType")
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
