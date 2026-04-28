// lib/native/scam_prevention_channel.dart
import 'package:flutter/services.dart';

class ScamPreventionChannel {
  static const MethodChannel _channel = MethodChannel('com.example.scamprevention/native');

  /// Checks if an SMS arrived within 2 mins of an unknown call.
  /// Returns a boolean or a string status.
  Future<bool> checkOtpProximity() async {
    try {
      final bool result = await _channel.invokeMethod('checkOtpProximity');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check OTP proximity: '${e.message}'.");
      return false;
    }
  }

  /// Triggers an overlay if banking apps are opened.
  /// durationMinutes: how long to keep the block active.
  Future<void> blockBankingApps(int durationMinutes) async {
    try {
      await _channel.invokeMethod('blockBankingApps', {'duration': durationMinutes});
    } on PlatformException catch (e) {
      print("Failed to block banking apps: '${e.message}'.");
    }
  }

  /// Sends a payload to backend to trigger FCM to the Guardian.
  /// (Using native for this is optional, but defined as per requirements)
  Future<void> triggerGuardianAlert(String alertType) async {
    try {
      await _channel.invokeMethod('triggerGuardianAlert', {'alertType': alertType});
    } on PlatformException catch (e) {
      print("Failed to trigger alert: '${e.message}'.");
    }
  }
}
