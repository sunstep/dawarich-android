import 'dart:async';
import 'dart:io';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_batch_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/last_point_converter.dart';
import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/application/services/tracker_settings_service.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/track_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/i_track_repository.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
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
import 'package:session_box/session_box.dart';

final class LocalPointService {
  final IApiPointRepository _api;
  final SessionBox<User> _userSession;
  final IPointLocalRepository _localPointRepository;
  final IHardwareRepository _hardwareInterfaces;
  final TrackerSettingsService _trackerPreferencesService;
  final ITrackRepository _trackRepository;

  LocalPointService(
      this._api,
      this._userSession,
      this._localPointRepository,
      this._trackerPreferencesService,
      this._trackRepository,
      this._hardwareInterfaces);

  Future<Result<(), String>> prepareBatchUpload(List<LocalPoint> points, {
    void Function(int uploaded, int total)? onChunkUploaded,
  }) async {

    final List<LocalPoint> failedChunks = [];
    const int chunkSize = 250;

    final dedupedLocalPoints = await _deduplicateLocalPoints(points);

    if (dedupedLocalPoints.isEmpty) {
      debugPrint('[Upload] No new points to upload after full deduplication.');
      return const Err("All points already exist on the server.");
    }

    for (int i = 0; i < dedupedLocalPoints.length; i += chunkSize) {
      final end = (i + chunkSize) > dedupedLocalPoints.length
          ? dedupedLocalPoints.length
          : (i + chunkSize);
      final chunk = dedupedLocalPoints.sublist(i, end);

      List<DawarichPoint> apiPoints = chunk
          .map((point) => point.toApi())
          .toList();

      final dto = DawarichPointBatch(points: apiPoints).toDto();

      final result = await _api.uploadBatch(dto);

      if (result case Err(value: final String error)) {
        debugPrint('[Upload] Failed to upload chunk [$i..$end]: $error');
        failedChunks.addAll(chunk);
      } else {
        await markBatchAsUploaded(chunk);
        onChunkUploaded?.call(end, dedupedLocalPoints.length);
      }

    }

    if (failedChunks.isNotEmpty) {
      return Err("${failedChunks.length} points were failed to be uploaded.");
    }

    return const Ok(());
  }

  Future<List<LocalPoint>> _deduplicateLocalPoints(
      List<LocalPoint> points) async {
    final sorted = List<LocalPoint>.from(points)
      ..sort((a, b) => a.properties.timestamp.compareTo(b.properties.timestamp));

    final userId = await _requireUserId();

    final seen = <String>{};
    final deduped = <LocalPoint>[];

    for (final p in sorted) {
      final ts  = p.properties.timestamp;
      final lon = p.geometry.longitude;
      final lat = p.geometry.latitude;

      final key = '$userId|$ts|$lon|$lat';
      if (seen.add(key)) {
        deduped.add(p);
      }
    }

    debugPrint('[Upload] Deduplicated from ${points.length} → ${deduped.length}');
    return deduped;
  }

  /// A private local point service helper method that checks if the current point batch is due for upload. This method gets called after a point gets stored locally.
  Future<bool> _checkBatchThreshold() async {

    final int userId = await _requireUserId();

    final int maxPoints =
        await _trackerPreferencesService.getPointsPerBatchSetting();
    final int currentPoints =
        await _localPointRepository.getBatchPointCount(userId);

    return currentPoints < maxPoints;
  }

  /// Creates a full point using a position object.
  Future<Result<LocalPoint, String>> createPointFromPosition(
      Position position) async {
    final int userId = await _requireUserId();

    final AdditionalPointData additionalData =
        await _getAdditionalPointData(userId);
    LocalPoint point = _constructPoint(position, additionalData, userId);

    Result<(), String> validationResult = await _validatePoint(point);

    if (validationResult case Err(value: String validationError)) {
      return Err("Point validation did not pass: $validationError");
    }

    return Ok(point);
  }

  Future<Result<LocalPoint, String>> storePoint(LocalPoint point) async {
    final LocalPointDto pointDto = point.toDto();
    final int storeResult = await _localPointRepository.storePoint(pointDto);

    return storeResult > 0
        ? Ok(point)
        : Err("Failed to store point");
  }

  /// The method that handles manually creating a point or when automatic tracking has not tracked a cached point for too long.
  Future<Result<LocalPoint, String>> createPointFromGps({bool persist = true}) async {
    final LocationAccuracy accuracy =
        await _trackerPreferencesService.getLocationAccuracySetting();
    final Result<Position, String> posResult =
        await _hardwareInterfaces.getPosition(accuracy);

    if (posResult case Err(value: final String error)) {
      return Err(error);
    }

    final Position position = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
        await createPointFromPosition(position);

    if (pointResult case Err()) {
      return pointResult;
    }

    if (!persist) {
      return pointResult;
    }

    final Result<LocalPoint, String> storeResult = await storePoint(
        pointResult.unwrap()
    );

    final bool uploadDue = await _checkBatchThreshold();

    if (uploadDue) {
      final List<LocalPoint> batch = await getCurrentBatch();
      if (batch.isNotEmpty) {
        final Result<(), String> uploadResult = await prepareBatchUpload(batch);
        if (uploadResult case Err(value: String error)) {
          return Err("Failed to upload batch: $error");
        }
      }
    }

    return storeResult;
  }

  /// Creates a full point, position data is retrieved from cache.
  Future<Result<LocalPoint, String>> createPointFromCache({bool persist = true}) async {
    final Option<Position> posResult =
        await _hardwareInterfaces.getCachedPosition();

    if (posResult case None()) {
      return const Err("[DEBUG] NO cached point was available");
    }

    final Position position = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
        await createPointFromPosition(position);

    if (pointResult case Err(value: String error)) {
      return Err("[DEBUG] Cached point was rejected: $error");
    }

    if (!persist) {
      return pointResult;
    }

    return await storePoint(pointResult.unwrap());
  }

  Future<AdditionalPointData> _getAdditionalPointData(int userId) async {
    int pointsInBatch = await getBatchPointsCount();

    final String wifi = await _hardwareInterfaces.getWiFiStatus();
    final String batteryState = await _hardwareInterfaces.getBatteryState();
    final double batteryLevel = await _hardwareInterfaces.getBatteryLevel();
    final String deviceId = await _trackerPreferencesService.getDeviceId();
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
      longitude: position.longitude,
      latitude: position.latitude
    );

    final properties = LocalPointProperties(
      batteryState: additionalData.batteryState,
      batteryLevel: additionalData.batteryLevel,
      wifi: additionalData.wifi,
      timestamp: position.timestamp.toUtc(),
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

  Future<bool> markBatchAsUploaded(List<LocalPoint> points) async {

    final int userId = await _requireUserId();

    if (points.isEmpty) {
      if (kDebugMode) {
        debugPrint("[DEBUG] No points need to be marked as uploaded.");
      }

      return false;
    }


    final pointIds = points.map((p) => p.id).whereType<int>().toList();
    int result = await _localPointRepository.markBatchAsUploaded(userId, pointIds);


    return result > 0;
  }

  Future<Result<(), String>> _validatePoint(LocalPoint point) async {

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
      DateTime candidateTime = point.properties.timestamp;
      DateTime lastTime = DateTime.parse(lastPoint.timestamp);

      answer = candidateTime.isAfter(lastTime);
    }

    return answer;
  }

  Future<bool> _isPointDistanceGreaterThanPreference(LocalPoint point) async {
    bool answer = true;
    int minimumDistance =
        await _trackerPreferencesService.getMinimumPointDistanceSetting();
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      double lastPointLongitude = point.geometry.longitude;
      double lastPointLatitude = point.geometry.latitude;

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
        await _trackerPreferencesService.getLocationAccuracySetting();

    double requiredAccuracyMeters = _getAccuracyThreshold(requiredAccuracy);

    answer = candidate.properties.horizontalAccuracy < requiredAccuracyMeters;

    return answer;
  }

  Future<Option<LastPoint>> getLastPoint() async {
    final int userId = await _requireUserId();

    Option<LastPointDto> pointResult =
        await _localPointRepository.getLastPoint(userId);

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

  Future<Stream<Option<LastPoint>>> watchLastPoint() async {
    final int userId = await _requireUserId();

    return _localPointRepository
        .watchLastPoint(userId)
        .map((option) => option.map(
            (dto) => dto.toDomain())
        );
  }


  Future<List<LocalPoint>> _getFullBatch() async {

    final int userId = await _requireUserId();

    List<LocalPointDto> result =
        await _localPointRepository.getFullBatch(userId);

    List<LocalPoint> batch = result.map((point) => point.toDomain()).toList();

    return batch;
  }

  Future<int> getBatchPointsCount() async {
    final int userId = await _requireUserId();

    int result =
        await _localPointRepository.getBatchPointCount(userId);


    return result;
  }

  Future<Stream<int>> watchBatchPointsCount() async {
    final int userId = await _requireUserId();

    return _localPointRepository.watchBatchPointCount(userId);
  }

  Future<List<LocalPoint>> getCurrentBatch() async {

    final int userId = await _requireUserId();

    List<LocalPointDto> pointBatchDto =
        await _localPointRepository.getCurrentBatch(userId);

    List<LocalPoint> batch = pointBatchDto.map(
            (point) => point.toDomain()).toList();
      return batch;
  }

  Future<Stream<List<LocalPoint>>> watchCurrentBatch() async {

    final int userId = await _requireUserId();

    return _localPointRepository.watchCurrentBatch(userId)
        .map((dtos) => dtos.map((dto) => dto.toDomain()).toList());
  }

  Future<bool> deletePoint(int pointId) async {
    final int userId = await _requireUserId();

    final result = await _localPointRepository.deletePoint(userId, pointId);

    return result == 1;
  }

  Future<bool> clearBatch() async {
    final int? userId = _userSession.getUserId();

    if (userId == null) {
      return false;
    }

    final result = await _localPointRepository.clearBatch(userId);
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

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[ApiPointService] No user session found.');
    }
    return userId;
  }
}
