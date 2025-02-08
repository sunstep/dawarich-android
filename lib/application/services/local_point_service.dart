import 'dart:io';
import 'package:dawarich/application/converters/batch/api_batch_point_converter.dart';
import 'package:dawarich/application/converters/batch/point_batch_converter.dart';
import 'package:dawarich/application/converters/last_point_converter.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/domain/entities/local/database/batch/point_batch.dart';
import 'package:dawarich/domain/entities/local/last_point.dart';
import 'package:dawarich/domain/entities/local/point_pair.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option_result.dart';

class LocalPointService {

  final ILocalPointInterfaces _localPointInterfaces;
  final TrackerPreferencesService _trackerPreferencesService;

  LocalPointService(this._localPointInterfaces, this._trackerPreferencesService);

  Future<Result<ApiBatchPoint, String>> createPoint() async {

    Option<ApiBatchPointDto> cachedPointResult = await _localPointInterfaces.createCachedPoint();

    if (cachedPointResult case Some(value: ApiBatchPointDto cachedPointDto)) {

      ApiBatchPoint cachedPoint = cachedPointDto.toEntity();

      if (await _isUniquePoint(cachedPoint) && await _isPointNewerThanLastPoint(cachedPoint) && await _isPointDistanceGreaterThanPreference(cachedPoint) &&  await _isPointAccurateEnough(cachedPoint)) {
        await _localPointInterfaces.storePoint(cachedPointDto);
        return Ok(cachedPoint);
      } else {
        if (kDebugMode) {
          debugPrint("[DEBUG] Cached point was not acceptable for usage.");
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint("[DEBUG] Cached point was not available.");
      }
    }

    Result<ApiBatchPointDto, String> creationResult = await _localPointInterfaces.createPoint();

    if (creationResult case Ok(value: ApiBatchPointDto newPointDto)) {

      ApiBatchPoint newPoint = newPointDto.toEntity();
      Result<(), String> validationResult = await _validatePoint(newPoint);

      if (validationResult case Ok()) {
        await _localPointInterfaces.storePoint(newPointDto);
        return Ok(newPoint);
      } else {
        if (kDebugMode) {
          debugPrint("[DEBUG] Created point is too inaccurate.");
        }
        String error = validationResult.unwrapErr();
        return Err(error);
      }
    } else {
      if (kDebugMode) {
        debugPrint("[DEBUG]  point not created.");
      }

      String error = creationResult.unwrapErr();
      return Err("Failed to create point: $error");
    }



  }

  Future<bool> markBatchAsUploaded(PointBatch batch) async {

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

  Future<Result<(), String>> _validatePoint(ApiBatchPoint point) async {

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

  Future<bool> _isPointNewerThanLastPoint(ApiBatchPoint point) async {

    bool answer = false;
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      DateTime candidateTime = DateTime.parse(point.properties.timestamp);
      DateTime lastTime = DateTime.parse(lastPoint.timestamp);

      answer = candidateTime.isAfter(lastTime);
    }

    return answer;
  }

  Future<bool> _isPointDistanceGreaterThanPreference(ApiBatchPoint point) async {

    bool answer = false;
    int minimumDistance = await _trackerPreferencesService.getMinimumPointDistancePreference();
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      double lastPointLongitude = point.geometry.coordinates[0];
      double lastPointLatitude = point.geometry.coordinates[1];

      LatLng lastPointCoordinates = LatLng(lastPoint.latitude, lastPoint.longitude);
      LatLng currentPointCoordinates = LatLng(lastPointLatitude, lastPointLongitude);

      PointPair pair = PointPair(lastPointCoordinates, currentPointCoordinates);
      double distance = pair.calculateDistance();

      answer = distance > minimumDistance;
    }

    return answer;
  }

  Future<bool> _isPointAccurateEnough(ApiBatchPoint point) async {

    bool answer = false;
    LocationAccuracy requiredAccuracy = await _trackerPreferencesService.getLocationAccuracyPreference();

    double requiredAccuracyMeters = getAccuracyThreshold(requiredAccuracy);

    answer = point.properties.horizontalAccuracy < requiredAccuracyMeters;

    return answer;
  }

  Future<bool> _isUniquePoint(ApiBatchPoint candidate) async {

    bool answer = false;
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      DateTime candidateTime = DateTime.parse(candidate.properties.timestamp);
      DateTime lastTime = DateTime.parse(lastPoint.timestamp);

      answer = !candidateTime.isAtSameMomentAs(lastTime);
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

  Future<int> getBatchPointsCount() async {

    return await _localPointInterfaces.getBatchPointCount();
  }

  Future<PointBatch> getCurrentBatch() async {
    PointBatchDto batchDto =  await _localPointInterfaces.getCurrentBatch();
    PointBatch batch = batchDto.toEntity();
    return batch;
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