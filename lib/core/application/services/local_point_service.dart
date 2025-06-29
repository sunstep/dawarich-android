import 'dart:async';
import 'dart:io';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/last_point_converter.dart';
import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/core/application/services/api_point_service.dart';
import 'package:dawarich/features/tracking/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/track_repository.dart';
import 'package:dawarich/data_contracts/interfaces/user_session_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/point/local/additional_point_data.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:dawarich/core/domain/models/point/point_pair.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option_result.dart';
import 'package:user_session_manager/user_session_manager.dart';

class LocalPointService {
  final ApiPointService _api;
  final UserSessionManager<int> _userSession;
  final IPointLocalRepository _localPointInterfaces;
  final IHardwareRepository _hardwareInterfaces;
  final TrackerPreferencesService _trackerPreferencesService;
  final ITrackRepository _trackRepository;

  LocalPointService(
      this._api,
      this._userSession,
      this._localPointInterfaces,
      this._trackerPreferencesService,
      this._trackRepository,
      this._hardwareInterfaces);

  /// A private local point service helper method that checks if the current point batch is due for upload. This method gets called after a point gets stored locally.
  Future<bool> _checkBatchThreshold() async {

    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return false;
    }

    final int maxPoints =
        await _trackerPreferencesService.getPointsPerBatchPreference();
    final int currentPoints =
        await _localPointInterfaces.getBatchPointCount(userId);

    if (currentPoints < maxPoints) {
      return false;
    }

    List<LocalPointDto> localPointDtoList =
        await _localPointInterfaces.getCurrentBatch(userId);

    List<LocalPoint> localPointList = localPointDtoList.map((point) =>
        point.toDomain()).toList();
    List<DawarichPoint> apiPointList = localPointList.map((point) =>
        point.toApi()).toList();
    DawarichPointBatch fullBatch = DawarichPointBatch(points: apiPointList);

    bool uploaded = await _api.uploadBatch(fullBatch);

    if (uploaded) {
      _localPointInterfaces.markBatchAsUploaded(userId);
    } else {
      if (kDebugMode) {
        debugPrint("[DEBUG] Failed to upload batch!");
        return false;
      }
    }

    return true;
  }

  /// Creates a full point using a position object.
  Future<Result<LocalPoint, String>> createAndStorePoint(
      Position position) async {
    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return Err("Must be logged in to create points");
    }

    final AdditionalPointData additionalData =
        await _getAdditionalPointData(userId);
    LocalPoint point = _constructPoint(position, additionalData, userId);

    Result<(), String> validationResult = await _validatePoint(point);

    if (validationResult case Err(value: String validationError)) {
      return Err("Point validation did not pass: $validationError");
    }

    LocalPointDto pointDto = point.toDto();
    final int storeResult =
        await _localPointInterfaces.storePoint(pointDto);
    await _checkBatchThreshold();

    return storeResult > 0
        ? Ok(point)
        : Err("Failed to store point");
  }

  /// The method that handles manually creating a point or when automatic tracking has not tracked a cached point for too long.
  Future<Result<LocalPoint, String>> createPointFromGps() async {
    final LocationAccuracy accuracy =
        await _trackerPreferencesService.getLocationAccuracyPreference();
    final Result<Position, String> posResult =
        await _hardwareInterfaces.getPosition(accuracy);

    if (posResult case Err(value: final String error)) {
      return Err(error);
    }

    final Position position = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
        await createAndStorePoint(position);

    return pointResult;
  }

  /// Creates a full point, position data is retrieved from cache.
  Future<Result<LocalPoint, String>> createPointFromCache() async {
    final Option<Position> posResult =
        await _hardwareInterfaces.getCachedPosition();

    if (posResult case None()) {
      return const Err("[DEBUG] NO cached point was available");
    }

    final Position position = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
        await createAndStorePoint(position);

    if (pointResult case Err(value: String error)) {
      return Err("[DEBUG] Cached point was rejected: $error");
    }

    final LocalPoint point = pointResult.unwrap();
    return Ok(point);
  }

  Future<AdditionalPointData> _getAdditionalPointData(int userId) async {
    int pointsInBatch = await getBatchPointsCount();

    final String wifi = await _hardwareInterfaces.getWiFiStatus();
    final String batteryState = await _hardwareInterfaces.getBatteryState();
    final double batteryLevel = await _hardwareInterfaces.getBatteryLevel();
    final String deviceId = await _trackerPreferencesService.getTrackerId();
    final Option<TrackDto> trackerIdResult =
        await _trackRepository.getActiveTrack(userId);

    String? trackId;

    if (trackerIdResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();
      trackId = track.trackId;
    }

    return AdditionalPointData(
        currentPointsInBatch: pointsInBatch,
        deviceId: deviceId,
        trackId: trackId,
        wifi: wifi,
        batteryState: batteryState,
        batteryLevel: batteryLevel);
  }

  LocalPoint _constructPoint(
      Position position, AdditionalPointData additionalData, int userId) {
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
        userId: userId,
        isUploaded: false);
  }

  Future<bool> markBatchAsUploaded(List<LocalPoint> batch) async {

    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return false;
    }

    final List<int> batchIds =
        batch.map((point) => point.id).whereType<int>().toList();

    if (batchIds.isEmpty) {
      if (kDebugMode) {
        debugPrint("[DEBUG] No points need to be marked as uploaded.");
      }

      return false;
    }

    int result = await _localPointInterfaces.markBatchAsUploaded(userId);

    return result > 0;
  }

  Future<Result<(), String>> _validatePoint(LocalPoint point) async {
    if (!await _isUniquePoint(point)) {
      return const Err("This point is not unique compared to previous ones.");
    }

    if (!await _isPointNewerThanLastPoint(point)) {
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
    int minimumDistance =
        await _trackerPreferencesService.getMinimumPointDistancePreference();
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      double lastPointLongitude = point.geometry.coordinates[0];
      double lastPointLatitude = point.geometry.coordinates[1];

      LatLng lastPointCoordinates =
          LatLng(lastPoint.latitude, lastPoint.longitude);
      LatLng currentPointCoordinates =
          LatLng(lastPointLatitude, lastPointLongitude);

      PointPair pair = PointPair(lastPointCoordinates, currentPointCoordinates);
      double distance = pair.calculateDistance();

      answer = distance >= minimumDistance;
    }

    return answer;
  }

  Future<bool> _isPointAccurateEnough(LocalPoint candidate) async {
    bool answer = false;
    LocationAccuracy requiredAccuracy =
        await _trackerPreferencesService.getLocationAccuracyPreference();

    double requiredAccuracyMeters = _getAccuracyThreshold(requiredAccuracy);

    answer = candidate.properties.horizontalAccuracy < requiredAccuracyMeters;

    return answer;
  }

  Future<bool> _isUniquePoint(LocalPoint candidate) async {
    final List<LocalPoint> batch = await _getFullBatch();
    bool answer = true;
    int batchIndex = 0;

    DateTime candidateTime = DateTime.parse(candidate.properties.timestamp);

    while (answer == true && batchIndex < batch.length) {
      LocalPoint batchPoint = batch[batchIndex];
      String batchPointTimeString = batchPoint.properties.timestamp;
      DateTime batchPointTime = DateTime.parse(batchPointTimeString);

      answer = !candidateTime.isAtSameMomentAs(batchPointTime);
      batchIndex++;
    }

    return answer;
  }

  Future<Option<LastPoint>> getLastPoint() async {
    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return const None();
    }

    Option<LastPointDto> pointResult =
        await _localPointInterfaces.getLastPoint(userId);

    switch (pointResult) {
      case Some(value: LastPointDto pointDto):
        {
          return Some(pointDto.toDomain());
        }

      case None():
        {
          return const None();
        }
    }
  }

  Future<List<LocalPoint>> _getFullBatch() async {

    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return [];
    }

    List<LocalPointDto> result =
        await _localPointInterfaces.getFullBatch(userId);

    List<LocalPoint> batch = result.map((point) => point.toDomain()).toList();

    return batch;
  }

  Future<int> getBatchPointsCount() async {
    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return 0;
    }

    int result =
        await _localPointInterfaces.getBatchPointCount(userId);


    return result;
  }

  Future<List<LocalPoint>> getCurrentBatch() async {

    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return [];
    }

    List<LocalPointDto> pointBatchDto =
        await _localPointInterfaces.getCurrentBatch(userId);

    List<LocalPoint> batch = pointBatchDto.map((point) => point.toDomain()).toList();
      return batch;
  }

  Future<bool> deletePoint(int pointId) async {
    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return false;
    }

    final result = await _localPointInterfaces.deletePoint(userId, pointId);

    return result == 1;
  }

  Future<bool> clearBatch() async {
    final int? userId = await _userSession.getUser();

    if (userId == null) {
      return false;
    }

    final result = await _localPointInterfaces.clearBatch(userId);
    return result > 0;
  }

  double _getAccuracyThreshold(LocationAccuracy accuracy) {
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
      throw UnsupportedError(
          "Unsupported platform for LocationAccuracy handling.");
    }
  }
}
