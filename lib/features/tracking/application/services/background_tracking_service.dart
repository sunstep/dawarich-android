//
// import 'dart:async';
// import 'dart:ui';
//
// import 'package:dawarich/application/services/local_point_service.dart';
// import 'package:dawarich/application/startup/dependency_injector.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geolocator/geolocator.dart';
//
// class BackgroundTrackingService {
//   // === Public API ===========================================================
//   Future<void> start() async => _service.startService();
//   Future<void> stop()  async => _service.invoke(_kStopEvent);
//
//   // === Singleton wiring =====================================================
//   static final BackgroundTrackingService instance =
//   BackgroundTrackingService._internal();
//
//   BackgroundTrackingService._internal();
//
//   // === Implementation details ==============================================
//   static const _kChannelId   = 'dawarich_foreground';
//   static const _kNotifId     = 888;
//   static const _kStopEvent   = 'stopService';
//   static const _kSmallIcon   = 'ic_stat_dawarich_notification';
//
//   final FlutterBackgroundService _service = FlutterBackgroundService();
//   final FlutterLocalNotificationsPlugin _localNotifs =
//   FlutterLocalNotificationsPlugin();
//
//   /// Must be called once (e.g. in `main()`) before `runApp`.
//   Future<void> configure() async {
//     // Create the channel once
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       _kChannelId,
//       'Dawarich Tracking Service',
//       description: 'Shows while background location tracking is active',
//       importance: Importance.low,
//     );
//     await _localNotifs
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     // Configure the plugin (no autoStart)
//     await _service.configure(
//       androidConfiguration: AndroidConfiguration(
//         onStart: _onStart,
//         autoStart: false,
//         isForegroundMode: true,
//         notificationChannelId: _kChannelId,
//         initialNotificationTitle: 'Dawarich',
//         initialNotificationContent: 'Preparing background service …',
//         foregroundServiceNotificationId: _kNotifId,
//       ),
//       iosConfiguration: IosConfiguration(
//         onForeground: _onStart,
//         onBackground: _onStart,
//       ),
//     );
//   }
//
//   // -------------------------------------------------------------------------
//   /// Runs in its own isolate when the service starts.
//   static FutureOr<bool> _onStart(ServiceInstance service) async {
//     DartPluginRegistrant.ensureInitialized();
//
//     // Keep a reference to your LocalPointService via GetIt (in this isolate)
//     final LocalPointService lpService = getIt<LocalPointService>();
//
//     // Turn into true foreground notification
//     if (service is AndroidServiceInstance) {
//       service.setForegroundNotificationInfo(
//         title: 'Dawarich',
//         content: 'Location tracking is active',
//         icon: _kSmallIcon,
//       );
//     }
//
//     // Listen for stop signal
//     service.on(_kStopEvent).listen((_) => service.stopSelf());
//
//     // Periodic GPS + point-store job
//     Timer.periodic(const Duration(seconds: 10), (timer) async {
//       if (!(await service.isRunning())) {
//         timer.cancel();
//         return;
//       }
//       try {
//         final pos = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         await lpService.createAndStorePoint(pos);
//       } catch (e) {
//         if (kDebugMode){
//           print('bg error: $e');
//         }
//       }
//
//       // Update notification timestamp
//       if (service is AndroidServiceInstance) {
//         final plugin = FlutterLocalNotificationsPlugin();
//         await plugin.show(
//           _kNotifId,
//           'Dawarich Tracking',
//           'Last update: ${DateTime.now().toLocal().toIso8601String()}',
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               _kChannelId,
//               'Dawarich Tracking Service',
//               icon: _kSmallIcon,
//               ongoing: true,
//             ),
//           ),
//         );
//       }
//     });
//   }
// }
