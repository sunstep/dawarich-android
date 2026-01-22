
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'background_tracking_service.dart';
import 'db_gate.dart';


@pragma('vm:entry-point')
void backgroundTrackingEntry(ServiceInstance backgroundService) {

  if (kDebugMode) {
    debugPrint('[Background] Entry point reached');
  }

  WidgetsFlutterBinding.ensureInitialized();

  final gate = DbGate(initiallyOpen: false);

  backgroundService.on('db_gate_open').listen((_) {
    if (kDebugMode) {
      debugPrint('[Background] db_gate_open received → opening DB gate');
    }
    gate.open();
  });


  BackgroundTrackingEntry.registerListeners(backgroundService);
  backgroundService.invoke('ready');

  unawaited(() async {
    try {
      await BackgroundTrackingEntry.checkBackgroundTracking(backgroundService, gate);
    } catch (e, s) {
      debugPrint('[Background] Fatal in checkBackgroundTracking: $e\n$s');
      await BackgroundTrackingEntry.shutdown(backgroundService, 'fatal error');
    }
  }());
}