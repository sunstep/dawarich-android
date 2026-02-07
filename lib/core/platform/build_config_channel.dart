import 'package:flutter/services.dart';

/// Provides access to native build configuration.
/// This exposes compile-time values set in Android's BuildConfig.
class BuildConfigChannel {
  static const _channel = MethodChannel('com.sunstep.dawarich/build_config');

  /// Gets the distribution flavor ('gms' or 'foss').
  /// This is a compile-time constant set via buildConfigField in gradle.
  static Future<String> getFlavor() async {
    try {
      final flavor = await _channel.invokeMethod<String>('getFlavor');
      return flavor ?? 'gms';
    } catch (_) {
      return 'gms'; // Default to GMS if channel fails
    }
  }

  /// Returns true if this is a FOSS build (F-Droid compatible).
  static Future<bool> isFoss() async {
    final flavor = await getFlavor();
    return flavor == 'foss';
  }

  /// Returns true if this is a GMS build (Play Store).
  static Future<bool> isGms() async {
    final flavor = await getFlavor();
    return flavor == 'gms';
  }
}

