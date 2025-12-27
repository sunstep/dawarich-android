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
import 'package:dawarich/features/tracking/data/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
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

  final IPointLocalRepository _localPointRepository;
  final IHardwareRepository _hardwareInterfaces;
  final TrackerSettingsService _trackerPreferencesService;
  final ITrackRepository _trackRepository;

  bool _uploadInFlight = false;

  LocalPointService(
      this._api,
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





  Future<AdditionalPointData> _getAdditionalPointData(int userId) async {

    final Future<String> wifiF = _hardwareInterfaces.getWiFiStatus();
    final Future<String> batteryStateF = _hardwareInterfaces.getBatteryState();
    final Future<double> batteryLevelF = _hardwareInterfaces.getBatteryLevel();
    final Future<String> deviceIdF = _trackerPreferencesService.getDeviceId();
    final Future<Option<TrackDto>> trackerIdResultF =
        _trackRepository.getActiveTrack(userId);

    final futureResults = await Future.wait([
      wifiF,
      batteryStateF,
      batteryLevelF,
      deviceIdF,
      trackerIdResultF,
    ]);

    final String wifi = futureResults[0] as String;
    final String batteryState = futureResults[1] as String;
    final double batteryLevel = futureResults[2] as double;
    final String deviceId = futureResults[3] as String;
    final Option<TrackDto> trackerIdResult = futureResults[4] as Option<TrackDto>;

    String? trackId;

    if (trackerIdResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();
      trackId = track.trackId;
    }

    return AdditionalPointData(
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






}
