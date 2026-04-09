

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class DbKeyProvider {

  final FlutterSecureStorage _ss = const FlutterSecureStorage();
  static const _k = 'db_key_v1';

  Future<String> getOrCreateHexKey() async {


    String? e;
    try {
      e = await _ss.read(key: _k).timeout(const Duration(seconds: 5));
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[DbKeyProvider] SecureStorage read timed out or failed: $err');
      }
      rethrow;
    }

    if (e != null && e.isNotEmpty) {
      return e;
    }

    final Random rnd = Random.secure();
    final List<int> bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    final String hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    try {
      await _ss.write(key: _k, value: hex)
          .timeout(const Duration(seconds: 5));
    } catch (err) {
      if (kDebugMode) {
        debugPrint('[DbKeyProvider] SecureStorage write timed out or failed: $err');
      }
      rethrow;
    }
    return hex;
  }

}