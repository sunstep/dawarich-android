import 'dart:io';
import 'package:dawarich/application/converters/batch/api_batch_point_converter.dart';
import 'package:dawarich/application/converters/batch/point_batch_converter.dart';
import 'package:dawarich/application/converters/batch/batch_point_converter.dart';
import 'package:dawarich/application/services/tracker_preferences_service.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/api_batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/batch_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/local/database/batch/point_batch_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/overland/batches/request/api_batch_point.dart';
import 'package:dawarich/domain/entities/local/database/batch/batch_point.dart';
import 'package:dawarich/domain/entities/local/database/batch/point_batch.dart';
import 'package:dawarich/ui/models/local/last_point.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:option_result/option_result.dart';

class LocalPointService {

  final ILocalPointInterfaces _localPointInterfaces;
  final TrackerPreferencesService _trackerPreferencesService;

  LocalPointService(this._localPointInterfaces, this._trackerPreferencesService);

  Future<ApiBatchPoint> createPoint() async {

    Option<ApiBatchPointDto> cachedPointResult = await _localPointInterfaces.createCachedPoint();

    if (cachedPointResult case Some(value: ApiBatchPointDto cachedPointDto)) {

      ApiBatchPoint cachedPoint = cachedPointDto.toEntity();

      if (await _isPointAcceptable(cachedPoint)) {
        await _localPointInterfaces.storePoint(cachedPointDto);
        return cachedPoint;
      } else {
        if (kDebugMode) {
          debugPrint("Cached point was not acceptable for usage.");
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint("Cached point was not available.");
      }
    }

    Result<ApiBatchPointDto, String> creationResult = await _localPointInterfaces.createPoint();

    if (creationResult case Ok(value: ApiBatchPointDto newPointDto)) {

      ApiBatchPoint newPoint = newPointDto.toEntity();

      if (await _isPointAcceptable(newPoint)) {
        await _localPointInterfaces.storePoint(newPointDto);
        return newPoint;
      } else {
        debugPrint("Created point is too inaccurate.");
      }
    } else {
      if (kDebugMode) {
        debugPrint("New point not created.");
      }
    }

    String error = creationResult.unwrapErr();
    throw Exception("Failed to create point: $error");

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

  Future<bool> _isPointAcceptable(ApiBatchPoint point) async {

    LocationAccuracy requiredAccuracy = await _trackerPreferencesService.getLocationAccuracyPreference();

    double requiredAccuracyMeters = getAccuracyThreshold(requiredAccuracy);

    if (point.properties.horizontalAccuracy > requiredAccuracyMeters) {
      debugPrint(
          "Point is not accurate enough. Required accuracy: $requiredAccuracyMeters meters. Actual: ${point.properties.horizontalAccuracy} meters.");
      return false;
    }

    return true; // Point meets the accuracy requirements
  }

  Future<LastPoint?> getLastPoint() async {

    Option<BatchPointDto> pointResult = await _localPointInterfaces.getLastPoint();

    switch (pointResult) {

      case Some(value: BatchPointDto pointDto): {
        BatchPoint point = pointDto.toEntity();
        return LastPoint(
            timestamp: formatTimestamp(point.properties.timestamp),
            latitude: point.geometry.coordinates[0],
            longitude: point.geometry.coordinates[1]
        );
      }

      case None(): {
        return null;
      }
    }
  }

  String formatTimestamp(String time) {
    DateTime parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(time), isUtc: false);
    String formattedTimestamp = DateFormat('dd MMM yyyy HH:mm:ss').format(parsedTimestamp);

    return formattedTimestamp;
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