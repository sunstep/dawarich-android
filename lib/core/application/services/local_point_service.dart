import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
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

  bool _uploadInFlight = false;

  LocalPointService(
      this._api,
      this._userSession,
      this._localPointRepository,
      this._trackerPreferencesService,
      this._trackRepository,
      this._hardwareInterfaces
  );

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

    int uploaded = 0;
    for (int i = 0; i < dedupedLocalPoints.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, dedupedLocalPoints.length);
      final chunk = dedupedLocalPoints.sublist(i, end);

      final List<DawarichPoint> apiPoints = chunk
          .map((point) => point.toApi())
          .toList();

      final dto = DawarichPointBatch(points: apiPoints).toDto();

      final result = await _api.uploadBatch(dto);

      if (result case Err(value: final String error)) {
        debugPrint('[Upload] Failed to upload chunk [$i..$end]: $error');
        failedChunks.addAll(chunk);
      } else {
        List<int> chunkIds = chunk.map((p) => p.id).toList();
        await deletePoints(chunkIds);
        uploaded += chunk.length;
        onChunkUploaded?.call(uploaded, dedupedLocalPoints.length);
      }

    }

    if (failedChunks.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[Batch Upload] Some batch chunks failed: retrying individually...');
      }

      int failedCount = 0;
      int uploadedCount = 0;

      for (final LocalPoint point in failedChunks) {
        final dto = DawarichPointBatch(points: [point.toApi()]).toDto();
        final result = await _api.uploadBatch(dto);

        if (result case Err(value: final error)) {
          if (error.contains("already exists")) {
            await deletePoints([point.id]);
            uploadedCount++;
            onChunkUploaded?.call(uploadedCount, failedChunks.length);
            continue;
          }

          failedCount++;
        } else {
          await deletePoints([point.id]);
          uploadedCount++;
          onChunkUploaded?.call(uploadedCount, failedChunks.length);
        }
      }

      if (failedCount > 0) {
        return Err("$failedCount point(s) failed to upload after retrying.");
      }
    }

    return const Ok(());
  }

  Future<List<LocalPoint>> _deduplicateLocalPoints(
      List<LocalPoint> points) async {
    final sorted = List<LocalPoint>.from(points)
      ..sort((a, b) => a.properties.timestamp.compareTo(b.properties.timestamp));

    final seen = <String>{};
    final deduped = <LocalPoint>[];

    for (final p in sorted) {
      final key = p.deduplicationKey;

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

    return currentPoints >= maxPoints;
  }

  Future<bool> _isOnline() async {

    List<ConnectivityResult> connectivity = await Connectivity()
        .checkConnectivity();

    return !connectivity.contains(ConnectivityResult.none);
  }

  /// Creates a full point using a position object.
  Future<Result<LocalPoint, String>> createPointFromPosition(
      Position position, DateTime timestamp) async {
    final int userId = await _requireUserId();

    final AdditionalPointData additionalData =
        await _getAdditionalPointData(userId);

    LocalPoint point = _constructPoint(
        position,
        additionalData,
        userId,
        timestamp,
    );

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

  Future<void> tryUploadBatchAfterPointStore(Result<LocalPoint, String> newPoint) async {

    if (newPoint case Ok()) {
      if (_uploadInFlight) {
        if (kDebugMode) {
          debugPrint(
              "[LocalPointService] Upload already in progress; skipping.");
        }
        return;
      }

      _uploadInFlight = true;

      try {
        final uploadDueF = _checkBatchThreshold();
        final isOnlineF = _isOnline();

        final result = await Future.wait([uploadDueF, isOnlineF]);
        final bool uploadDue = result[0];
        final bool isOnline = result[1];

        if (isOnline && uploadDue) {
          final batch = await getCurrentBatch();
          if (batch.isNotEmpty) {
            final uploadResult = await prepareBatchUpload(batch);
            if (uploadResult case Err(value: final err)) {
              debugPrint("[LocalPointService] Auto-upload failed: $err");
            }
          }
        }
      } catch (e, s) {
        debugPrint("[LocalPointService] Error during auto-upload: $e\n$s");
      } finally {
        _uploadInFlight = false;
      }
    } else if (newPoint case Err(value: final err)) {
      debugPrint("[LocalPointService] Failed to store point: $err");
    }
  }

  Future<Result<(), String>> autoStoreAndUpload(LocalPoint point) async {

    final Result<LocalPoint, String> storeResult = await storePoint(point);

    if (storeResult case Err(value: final String error)) {
      return Err("Failed to store point: $error");
    }

    tryUploadBatchAfterPointStore(storeResult);

    return const Ok(());
  }

  /// The method that handles manually creating a point or when automatic tracking has not tracked a cached point for too long.
  Future<Result<LocalPoint, String>> createPointFromGps() async {

    final DateTime pointCreationTimestamp = DateTime.now().toUtc();
    final Future<bool> isTrackingAutomaticallyF = _trackerPreferencesService.getAutomaticTrackingSetting();
    final Future<LocationAccuracy> accuracyF = _trackerPreferencesService.getLocationAccuracySetting();
    final Future<int> currentTrackingFrequencyF = _trackerPreferencesService.getTrackingFrequencySetting();

    final result = await Future.wait([
      isTrackingAutomaticallyF,
      accuracyF,
      currentTrackingFrequencyF
    ]);

    final bool isTrackingAutomatically = result[0] as bool;
    final LocationAccuracy accuracy = result[1] as LocationAccuracy;
    final int currentTrackingFrequency = result[2] as int;

    final Duration autoAttemptTimeout = _clampDuration(
      Duration(seconds: currentTrackingFrequency),
      const Duration(seconds: 5),
      const Duration(seconds: 30),
    );

    final Duration autoStaleMax = _clampDuration(
      Duration(seconds: currentTrackingFrequency * 2),
      const Duration(seconds: 5),
      const Duration(seconds: 30),
    );

    const Duration manualTimeout = Duration(seconds: 15);
    const Duration manualStaleMax = Duration(seconds: 90);

    final Duration attemptTimeout = isTrackingAutomatically ? autoAttemptTimeout : manualTimeout;
    final Duration staleMax = isTrackingAutomatically ? autoStaleMax : manualStaleMax;

    Result<Position, String> posResult;

    try {
      posResult = await _hardwareInterfaces
          .getPosition(accuracy)
          .timeout(attemptTimeout);
    } on TimeoutException {
      return Err("NO_FIX_TIMEOUT");
    } catch (e) {
      return Err("POSITION_ERROR: $e");
    }

    if (posResult case Err(value: final String error)) {
      return Err(error);
    }

    final Position position = posResult.unwrap();

    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime fixTs = position.timestamp.toUtc();

    final Duration age = nowUtc.difference(fixTs);
    if (age < Duration.zero || age > staleMax) {
      return Err("STALE_FIX: age=${age.inSeconds}s (max=${staleMax.inSeconds}s)");
    }

    final Result<LocalPoint, String> pointResult = await createPointFromPosition(position, pointCreationTimestamp);

    if (pointResult case Err()) {
      return pointResult;
    }

    Result<LocalPoint, String> finalResult = pointResult;


    final point = pointResult.unwrap();
    await autoStoreAndUpload(point);

    return finalResult;
  }

  Duration _clampDuration(Duration v, Duration min, Duration max) {
    if (v < min) {
      return min;
    }
    if (v > max) {
      return max;
    }
    return v;
  }


  /// Creates a full point, position data is retrieved from cache.
  Future<Result<LocalPoint, String>> createPointFromCache() async {

    final DateTime pointCreationTimestamp = DateTime.now().toUtc();
    final Option<Position> posResult =
        await _hardwareInterfaces.getCachedPosition();

    if (posResult case None()) {
      if (kDebugMode) {
        debugPrint("[DEBUG] No cached position was available");
      }
      return const Err("[DEBUG] NO cached point was available");
    }

    if (kDebugMode) {
      debugPrint("[DEBUG] Cached position found, creating point from it.");
    }

    final Position position = posResult.unwrap();
    final Result<LocalPoint, String> pointResult =
        await createPointFromPosition(position, pointCreationTimestamp);

    if (pointResult case Err(value: String error)) {
      return Err("[DEBUG] Cached point was rejected: $error");
    }

    await autoStoreAndUpload(pointResult.unwrap());
    return pointResult;
  }

  Future<AdditionalPointData> _getAdditionalPointData(int userId) async {

    final Future<int> pointsInBatchF = getBatchPointsCount();
    final Future<String> wifiF = _hardwareInterfaces.getWiFiStatus();
    final Future<String> batteryStateF = _hardwareInterfaces.getBatteryState();
    final Future<double> batteryLevelF = _hardwareInterfaces.getBatteryLevel();
    final Future<String> deviceIdF = _trackerPreferencesService.getDeviceId();
    final Future<Option<TrackDto>> trackerIdResultF =
        _trackRepository.getActiveTrack(userId);

    final futureResults = await Future.wait([
      pointsInBatchF,
      wifiF,
      batteryStateF,
      batteryLevelF,
      deviceIdF,
      trackerIdResultF,
    ]);

    final int pointsInBatch = futureResults[0] as int;
    final String wifi = futureResults[1] as String;
    final String batteryState = futureResults[2] as String;
    final double batteryLevel = futureResults[3] as double;
    final String deviceId = futureResults[4] as String;
    final Option<TrackDto> trackerIdResult = futureResults[5] as Option<TrackDto>;

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
      Position position, AdditionalPointData additionalData, int userId, DateTime timestamp) {
    final geometry = LocalPointGeometry(
      type: "Point",
      longitude: position.longitude,
      latitude: position.latitude
    );

    final properties = LocalPointProperties(
      batteryState: additionalData.batteryState,
      batteryLevel: additionalData.batteryLevel,
      wifi: additionalData.wifi,
      timestamp: timestamp,
      horizontalAccuracy: position.accuracy,
      verticalAccuracy: position.altitudeAccuracy,
      altitude: position.altitude,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
      course: position.heading,
      courseAccuracy: position.headingAccuracy,
      trackId: additionalData.trackId,
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

    final Future<bool> isNewerF = _isPointNewerThanLastPoint(point);
    final Future<bool> isDistanceF = _isPointDistanceGreaterThanPreference(point);
    final Future<bool> isAccurateF = _isPointAccurateEnough(point);

    final results = await Future.wait([
      isNewerF,
      isDistanceF,
      isAccurateF
    ]);

    final bool isNewer = results[0];
    final bool isDistance = results[1];
    final bool isAccurate = results[2];

    if (!isNewer) {
      return const Err("Point is not newer than the last stored point.");
    }

    if (!isDistance) {
      return const Err("Point is not sufficiently distant from the last point.");
    }

    if (!isAccurate) {
      return const Err("Point does not meet the required accuracy.");
    }

    return const Ok(());
  }

  Future<bool> _isPointNewerThanLastPoint(LocalPoint point) async {
    // TODO (Future update):
    // Currently this check always passes because `_constructPoint`
    // guarantees monotonically increasing timestamps by falling back
    // to DateTime.now() if the GPS timestamp is stale.
    //
    // When we add support for last-known points (e.g. from Geolocator or
    // other apps), we need a smarter duplicate heuristic instead of just
    // comparing timestamps. Otherwise, valid "older" provider points could
    // be rejected.
    //
    // Future plan:
    // - Introduce providerTimestamp alongside stored timestamp.
    // - Replace this check with a heuristic:
    //     (a) providerTimestamp > last.providerTimestamp OR
    //     (b) significant distance moved OR
    //     (c) better accuracy
    // This will prevent duplicates without dropping legitimate points.
    //
    // For now we keep this method in place, since it does no harm and
    // preserves validation structure.
    bool answer = true;
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      DateTime candidateTime = point.properties.timestamp;
      DateTime lastTime = lastPoint.timestamp;

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
      double currentPointLongitude = point.geometry.longitude;
      double currentPointLatitude = point.geometry.latitude;

      LatLng lastPointCoordinates =
          LatLng(lastPoint.latitude, lastPoint.longitude);
      LatLng currentPointCoordinates =
          LatLng(currentPointLatitude, currentPointLongitude);

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

    if (pointResult case Some(value: final LastPointDto lastPointDto)) {
      final LastPoint lastPoint = lastPointDto.toDomain();
      return Some(lastPoint);
    }

    return const None();
  }

  Future<Stream<Option<LastPoint>>> watchLastPoint() async {
    final int userId = await _requireUserId();

    return _localPointRepository
        .watchLastPoint(userId)
        .map((option) => option.map(
            (dto) => dto.toDomain())
        );
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

  Future<bool> deletePoints(List<int> pointIds) async {
    final int userId = await _requireUserId();

    final result = await _localPointRepository.deletePoints(userId, pointIds);

    return result > 0;
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
