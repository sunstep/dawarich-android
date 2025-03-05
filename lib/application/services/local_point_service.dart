import 'dart:async';
import 'dart:io';
import 'package:dawarich/application/converters/batch/local/local_point_batch_converter.dart';
import 'package:dawarich/application/converters/batch/local/local_point_converter.dart';
import 'package:dawarich/application/converters/last_point_converter.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/domain/entities/local/additional_point_data.dart';
import 'package:dawarich/domain/entities/local/last_point.dart';
import 'package:dawarich/domain/entities/local/point_pair.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_batch.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_geometry.dart';
import 'package:dawarich/domain/entities/point/batch/local/local_point_properties.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option_result.dart';

class LocalPointService {

  // StreamSubscription<Result<Position, String>>? _stream;
  // Timer? _heartbeatTimer;

  final ILocalPointRepository _localPointInterfaces;
  final IHardwareRepository _hardwareInterfaces;
  final TrackerPreferencesService _trackerPreferencesService;


  LocalPointService(this._localPointInterfaces, this._trackerPreferencesService, this._hardwareInterfaces);

  // Future<void> startTracking() async {
  //
  //   LocationAccuracy accuracy = await _trackerPreferencesService.getLocationAccuracyPreference();
  //   int minimumDistance = await _trackerPreferencesService.getMinimumPointDistancePreference();
  //   int trackingFrequency = await _trackerPreferencesService.getTrackingFrequencyPreference();
  //
  //   _heartbeatTimer = Timer.periodic(Duration(seconds: trackingFrequency), (timer) async {
  //
  //   });
  //
  //   Stream<Result<Position, String>> positionStream = _hardwareInterfaces.getPositionStream(accuracy: accuracy, minimumDistance: minimumDistance);
  //   _stream = positionStream.listen((result) {
  //
  //     if (result case Ok(value: Position position)) {
  //
  //     }
  //   });
  // }
  //
  // Future<Result<ApiBatchPoint, String>> createAutomaticPoint() async {
  //
  //
  // }

  // Future<void> stopAutomaticPointCreation() async {
  //   _heartbeatTimer?.cancel();
  //   _heartbeatTimer = null;
  //   await _stream?.cancel();
  //   _stream = null;
  // }

  Future<Result<LocalPoint, String>> createManualPoint() async {

    Result<LocalPoint, String> newPointResult = await _createNewPoint();

    if (newPointResult case Ok(value: LocalPoint newPoint)) {

      Result<(), String> validationResult = await _validatePoint(newPoint);

      if (validationResult case Ok()) {
        LocalPointDto newPointDto = newPoint.toDto();
        await _localPointInterfaces.storePoint(newPointDto);
        return Ok(newPoint);
      } else {

        if (kDebugMode) {
          debugPrint("[DEBUG] Created point did not pass validation.");
        }

        String error = validationResult.unwrapErr();
        return Err(error);
      }
    }

    if (kDebugMode) {
      debugPrint("[DEBUG] point not created.");
    }

    String error = newPointResult.unwrapErr();
    return Err("Failed to create point: $error");
  }

  Future<Option<LocalPoint>> _tryCreateCachedPoint() async {

    Option<Position> positionResult = await _hardwareInterfaces.getCachedPosition();
    AdditionalPointData additionalData = await _getAdditionalPointData();

    if (positionResult case Some(value: Position postion)) {
      LocalPoint cachedPoint = _constructPoint(postion, additionalData);

      Result<(), String> validationResult = await _validatePoint(cachedPoint);

      if (validationResult case Ok()) {

        LocalPointDto cachedPointDto = cachedPoint.toDto();
        await _localPointInterfaces.storePoint(cachedPointDto);
        return Some(cachedPoint);
      }

      if (kDebugMode) {
        debugPrint("[DEBUG] Cached point was not acceptable for usage.");
      }

    }

    if (kDebugMode) {
      debugPrint("[DEBUG] Cached point was not available.");
    }

    return const None();
  }

  Future<Result<LocalPoint, String>> _createNewPoint() async {

    LocationAccuracy accuracy = await _trackerPreferencesService.getLocationAccuracyPreference();
    Result<Position, String> positionResult = await _hardwareInterfaces.getPosition(accuracy);
    AdditionalPointData additionalData = await _getAdditionalPointData();

    if (positionResult case Ok(value: Position position)) {
      LocalPoint newPoint = _constructPoint(position, additionalData);

      return Ok(newPoint);
    }

    String error = positionResult.unwrapErr();
    return Err(error);
  }

  Future<AdditionalPointData> _getAdditionalPointData() async {

    int pointsInBatch = await getBatchPointsCount();
    String trackerId = await _trackerPreferencesService.getTrackerId();
    String wifi = await _hardwareInterfaces.getWiFiStatus();
    String batteryState = await _hardwareInterfaces.getBatteryState();
    double batteryLevel = await _hardwareInterfaces.getBatteryLevel();

    return AdditionalPointData(
      currentPointsInBatch: pointsInBatch,
      deviceId: trackerId,
      wifi: wifi,
      batteryState: batteryState,
      batteryLevel: batteryLevel
    );
  }

  LocalPoint _constructPoint(Position position, AdditionalPointData additionalData) {

    final geometry = LocalPointGeometry(
      type: "Point",
      coordinates: [position.longitude, position.latitude],
    );

    final properties = LocalPointProperties(
      batteryState: additionalData.batteryState,
      batteryLevel: additionalData.batteryLevel,
      wifi: additionalData.wifi,
      timestamp: position.timestamp.toUtc().toIso8601String(),
      horizontalAccuracy: position.accuracy,
      verticalAccuracy: position.altitudeAccuracy,
      altitude: position.altitude,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
      course: 0.0,
      courseAccuracy: 0.0,
      trackId: "",
      deviceId: additionalData.deviceId,
    );

    return LocalPoint(
      id: 0,
      type: "Feature",
      geometry: geometry,
      properties: properties,
    );
  }

  Future<bool> markBatchAsUploaded(LocalPointBatch batch) async {

    final List<int> batchIds = batch.points
        .map((point) => point.id)
        .whereType<int>()
        .toList();

    if (batchIds.isEmpty) {

      if (kDebugMode) {
        debugPrint("[DEBUG] No points need to be marked as uploaded.");
      }

      return false;
    }

    Result<int, String> result = await _localPointInterfaces.markBatchAsUploaded(batchIds);

    switch (result) {

      case Ok(value: int rowsAffected): {
        return rowsAffected == batchIds.length;
      }

      case Err(value: String error): {
        if (kDebugMode) {
          debugPrint("[DEBUG]: Failed to mark batch as uploaded: $error");
        }

        return false;
      }
    }
  }

  Future<Result<(), String>> _validatePoint(LocalPoint point) async {

    if (!await _isUniquePoint(point)) {
      return const Err("This point is not unique compared to previous ones.");
    }

    if (!await _isPointNewerThanLastPoint(point)){
      return const Err("The point is older than the last tracked point.");
    }

    if (!await _isPointDistanceGreaterThanPreference(point)) {
      return const Err("The point is too close to the last point.");
    }

    if (!await _isPointAccurateEnough(point)) {
      return const Err("The point's accuracy is below the required threshold.");
    }

    return const Ok(());
  }

  Future<bool> _isPointNewerThanLastPoint(LocalPoint point) async {

    bool answer = true;
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      DateTime candidateTime = DateTime.parse(point.properties.timestamp);
      DateTime lastTime = DateTime.parse(lastPoint.timestamp);

      answer = candidateTime.isAfter(lastTime);
    }

    return answer;
  }

  Future<bool> _isPointDistanceGreaterThanPreference(LocalPoint point) async {

    bool answer = true;
    int minimumDistance = await _trackerPreferencesService.getMinimumPointDistancePreference();
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      double lastPointLongitude = point.geometry.coordinates[0];
      double lastPointLatitude = point.geometry.coordinates[1];

      LatLng lastPointCoordinates = LatLng(lastPoint.latitude, lastPoint.longitude);
      LatLng currentPointCoordinates = LatLng(lastPointLatitude, lastPointLongitude);

      PointPair pair = PointPair(lastPointCoordinates, currentPointCoordinates);
      double distance = pair.calculateDistance();

      answer = distance >= minimumDistance;
    }

    return answer;
  }

  Future<bool> _isPointAccurateEnough(LocalPoint candidate) async {

    bool answer = false;
    LocationAccuracy requiredAccuracy = await _trackerPreferencesService.getLocationAccuracyPreference();

    double requiredAccuracyMeters = getAccuracyThreshold(requiredAccuracy);

    answer = candidate.properties.horizontalAccuracy < requiredAccuracyMeters;

    return answer;
  }

  Future<bool> _isUniquePoint(LocalPoint candidate) async {

    final LocalPointBatch batch = await _getFullBatch();
    bool answer = true;
    int batchIndex = 0;

    DateTime candidateTime = DateTime.parse(candidate.properties.timestamp);

    while (answer == true && batchIndex < batch.points.length) {

      LocalPoint batchPoint = batch.points[batchIndex];
      String batchPointTimeString = batchPoint.properties.timestamp;
      DateTime batchPointTime = DateTime.parse(batchPointTimeString);

      answer = !candidateTime.isAtSameMomentAs(batchPointTime);
    }

    return answer;
  }

  Future<Option<LastPoint>> getLastPoint() async {

    Option<LastPointDto> pointResult = await _localPointInterfaces.getLastPoint();

    switch (pointResult) {

      case Some(value: LastPointDto pointDto): {
        return Some(pointDto.toEntity());
      }

      case None(): {
        return const None();
      }
    }
  }

  Future<LocalPointBatch> _getFullBatch() async {

    Result<LocalPointBatchDto, String> result = await _localPointInterfaces.getFullBatch();

    if (result case Ok(value: LocalPointBatchDto pointBatchDto)) {
      LocalPointBatch batch = pointBatchDto.toEntity();

      return batch;
    }

    String error = result.unwrapErr();
    throw Exception("Failed to retrieve full batch: $error");
  }

  Future<int> getBatchPointsCount() async {

    Result<int, String> result = await _localPointInterfaces.getBatchPointCount();

    if (result case Ok(value: int pointCount)) {
      return pointCount;
    }

    String error = result.unwrapErr();
    throw Exception("Failed to retrieve point count in batch: $error");
  }

  Future<LocalPointBatch> getCurrentBatch() async {

    Result<LocalPointBatchDto, String> batchResult =  await _localPointInterfaces.getCurrentBatch();

    if (batchResult case Ok(value: LocalPointBatchDto pointBatchDto)) {
      LocalPointBatch pointBatch =  pointBatchDto.toEntity();
      return pointBatch;
    }

    String error = batchResult.unwrapErr();
    throw Exception("Failed to retrieve current batch: $error");
  }

  Future<bool> deletePoint(int pointId) async {
    
    final result = await _localPointInterfaces.deletePoint(pointId);
    return result.isOk();
  }

  Future<bool> clearBatch() async {
    final result = await _localPointInterfaces.clearBatch();
    return result.isOk();
  }


  double getAccuracyThreshold(LocationAccuracy accuracy) {
    if (Platform.isIOS) {
      switch (accuracy) {
        case LocationAccuracy.lowest:
          return 3000; // iOS Lowest accuracy
        case LocationAccuracy.low:
          return 1000; // iOS Low accuracy
        case LocationAccuracy.medium:
          return 100; // iOS Medium accuracy
        case LocationAccuracy.high:
          return 10; // iOS High accuracy
        case LocationAccuracy.bestForNavigation:
          return 0; // iOS Navigation-specific accuracy
        case LocationAccuracy.reduced:
          return 3000; // iOS Reduced accuracy
        default:
          throw ArgumentError("Unsupported LocationAccuracy value: $accuracy");
      }
    } else if (Platform.isAndroid) {
      switch (accuracy) {
        case LocationAccuracy.lowest:
          return 500; // Android Passive accuracy
        case LocationAccuracy.low:
          return 500; // Android Low power accuracy
        case LocationAccuracy.medium:
          return 500; // Android Balanced power accuracy
        case LocationAccuracy.high:
          return 100; // Android High accuracy
        case LocationAccuracy.best:
          return 100; // Android matches High accuracy
        default:
          throw ArgumentError("Unsupported LocationAccuracy value: $accuracy");
      }
    } else {
      // Default for unsupported platforms
      throw UnsupportedError("Unsupported platform for LocationAccuracy handling.");
    }
  }
}