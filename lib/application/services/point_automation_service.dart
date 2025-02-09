
import 'dart:async';
import 'package:dawarich/application/services/local_point_service.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class PointAutomationService {

  StreamSubscription<Result<Position, String>>? _stream;
  Timer? _cachedTimer;
  Timer? _gpsTimer;
  Position? _cachedPosition;

  final TrackerPreferencesService _trackerPreferencesService;
  final IHardwareRepository _hardwareRepository;
  final LocalPointService _localPointService;

  PointAutomationService(this._trackerPreferencesService, this._hardwareRepository, this._localPointService);

  Future<void> startTracking() async {



  }

  Future<void> startCachedTimer() async {
    _cachedTimer = Timer.periodic(const Duration(seconds: 3), _cachedTimerHandler);
  }

  Future<void> startGpsTimer() async {

    int trackingFrequency = await _trackerPreferencesService.getTrackingFrequencyPreference();
    _gpsTimer = Timer.periodic(Duration(seconds: trackingFrequency), _gpsTimerHandler);
  }

  Future<void> startStreamSubscription() async {

    LocationAccuracy accuracy = await _trackerPreferencesService.getLocationAccuracyPreference();
    int minimumDistance = await _trackerPreferencesService.getMinimumPointDistancePreference();

    Stream<Result<Position, String>> positionStream = _hardwareRepository
        .getPositionStream(
        accuracy: accuracy,
        minimumDistance: minimumDistance
    );

    _stream = positionStream.listen(_streamHandler);
  }


  Future<void> _cachedTimerHandler(Timer timer) async {

    Option<ApiBatchPoint> cachedPointResult = await _localPointService.tryCreateCachedPoint();
    if (cachedPointResult case Some(value: ApiBatchPoint point)) {
      _restartGpsTimer();
    }

  }

  Future<void> _gpsTimerHandler(Timer timer) async {

  }

  Future<void> _streamHandler(Result<Position, String> result) async {

    if (result case Ok(value: Position position)) {


    }
  }

  Future<void> _restartGpsTimer() async {
    await stopGpsTimer();
    await startGpsTimer();
  }

  Future<void> stopCachedTimer() async {

    _cachedTimer?.cancel();
    _cachedTimer = null;
  }

  Future<void> stopGpsTimer() async {
    _gpsTimer?.cancel();
    _gpsTimer = null;

  }

  Future<void> stopStreamSubscription() async {
    await _stream?.cancel();
    _stream = null;
  }




}