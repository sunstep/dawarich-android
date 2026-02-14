import 'dart:async';
import 'package:dawarich/features/batch/application/usecases/batch_upload_workflow_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/check_batch_threshold_usecase.dart';
import 'package:dawarich/features/batch/application/usecases/get_current_batch_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/get_batch_point_count_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/notifications/show_tracker_notification_usecase.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/create_point_from_location_stream_workflow.dart';
import 'package:dawarich/features/tracking/application/usecases/point_creation/store_point_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class PointAutomationService {
  bool _isTracking = false;
  bool _writeBusy = false;
  StreamSubscription<Result<dynamic, String>>? _locationStreamSub;

  final CreatePointFromLocationStreamWorkflow _createPointFromLocationStream;
  final StorePointUseCase _storePoint;
  final GetBatchPointCountUseCase _getBatchPointCount;
  final ShowTrackerNotificationUseCase _showTrackerNotification;
  final CheckBatchThresholdUseCase _checkBatchThreshold;
  final GetCurrentBatchUseCase _getCurrentBatch;
  final BatchUploadWorkflowUseCase _batchUploadWorkflow;

  PointAutomationService(
    this._createPointFromLocationStream,
    this._storePoint,
    this._getBatchPointCount,
    this._showTrackerNotification,
    this._checkBatchThreshold,
    this._getCurrentBatch,
    this._batchUploadWorkflow,
  );

  Future<void> startTracking(int userId) async {
    if (_isTracking) return;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Starting automatic tracking with location stream...");
    }

    _isTracking = true;

    // Use location stream for automatic tracking - more battery efficient
    // than polling because the OS can optimize location updates
    final pointStream = _createPointFromLocationStream.getPointStream(userId);

    _locationStreamSub = pointStream.listen(
      (result) async {
        await _handleLocationUpdate(result, userId);
      },
      onError: (error, stackTrace) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Stream error: $error\n$stackTrace");
        }
      },
      onDone: () {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Location stream completed");
        }
      },
      cancelOnError: false, // Continue listening even if there's an error
    );
  }

  /// Stop everything if user logs out, or toggles the preference off.
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    if (kDebugMode) {
      debugPrint("[PointAutomation] Stopping automatic tracking...");
    }

    _isTracking = false;
    await _locationStreamSub?.cancel();
    _locationStreamSub = null;
  }

  /// Handles location updates from the stream
  Future<void> _handleLocationUpdate(Result<dynamic, String> result, int userId) async {
    if (_writeBusy) {
      if (kDebugMode) {
        debugPrint("[PointAutomation] Skipping location update, write busy.");
      }
      return;
    }

    _writeBusy = true;

    try {
      if (result case Ok(value: final point)) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Storing point from location stream");
        }

        final storeResult = await _storePoint(point);

        if (storeResult case Ok()) {
          await _notify(userId);
          await _checkAndUploadBatch(userId);
        } else if (storeResult case Err(value: final err)) {
          debugPrint("[PointAutomation] Failed to store point: $err");
        }
      } else if (result case Err(value: final err)) {
        debugPrint("[PointAutomation] Point creation error: $err");
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error handling location update: $e\n$s");
    } finally {
      _writeBusy = false;
    }
  }

  Future<void> _checkAndUploadBatch(int userId) async {
    try {
      final shouldUpload = await _checkBatchThreshold(userId);
      if (shouldUpload) {
        if (kDebugMode) {
          debugPrint("[PointAutomation] Batch threshold reached, uploading...");
        }
        final batch = await _getCurrentBatch(userId);
        if (batch.isNotEmpty) {
          final result = await _batchUploadWorkflow(batch, userId);
          if (result case Ok()) {
            if (kDebugMode) {
              debugPrint("[PointAutomation] Batch upload successful.");
            }
          } else if (result case Err(value: final err)) {
            debugPrint("[PointAutomation] Batch upload failed: $err");
          }
        }
      }
    } catch (e, s) {
      debugPrint("[PointAutomation] Error checking/uploading batch: $e\n$s");
    }
  }

  Future<void> _notify(int userId) async {
    try {
      await _showTrackerNotification(
        title: 'Tracking location...',
        body: 'Last updated at ${DateTime.now().toLocal().toIso8601String()}, '
            '${await _getBatchPointCount(userId)} points in batch.',
      );
    } catch (e, s) {
      debugPrint("[PointAutomation] Notify error: $e\n$s");
    }
  }
}
