import 'package:dawarich/core/data/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_batch_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/result.dart';


final class BatchUploadWorkflowUseCase {

  final IApiPointRepository _api;
  final IPointLocalRepository _localPointRepository;

  BatchUploadWorkflowUseCase(
      this._api,
      this._localPointRepository,
  );


  Future<Result<(), String>> call(List<LocalPoint> points, int userId, {
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
        await _markAsUploaded(chunkIds, userId);
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
            await _markAsUploaded([point.id], userId);
            uploadedCount++;
            onChunkUploaded?.call(uploadedCount, failedChunks.length);
            continue;
          }

          failedCount++;
        } else {
          await _markAsUploaded([point.id], userId);
          uploadedCount++;
          onChunkUploaded?.call(uploadedCount, failedChunks.length);
        }
      }

      if (failedCount > 0) {
        return Err("$failedCount point(s) failed to upload after retrying.");
      }
    }

    // Clean up: delete all uploaded points except the last one
    // The last point is kept as a reference for validating new points
    await _cleanupAfterUpload(userId);

    return const Ok(());
  }

  /// After upload, delete all uploaded points except the most recent one.
  /// The last point is kept (marked as uploaded) for validation reference.
  Future<void> _cleanupAfterUpload(int userId) async {
    try {
      final deleted = await _localPointRepository.deleteUploadedPointsExceptLast(userId);
      if (kDebugMode) {
        debugPrint('[Upload] Cleanup: deleted $deleted old uploaded points, kept last for reference');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Upload] Cleanup failed: $e');
      }
    }
  }

  Future<bool> _markAsUploaded(List<int> pointIds, int userId) async {
    final result = await _localPointRepository.markBatchAsUploaded(userId, pointIds);
    return result > 0;
  }

  Future<List<LocalPoint>> _deduplicateLocalPoints(
      List<LocalPoint> points) async {
    final sorted = List<LocalPoint>.from(points)
      ..sort((a, b) => a.properties.recordTimestamp.compareTo(b.properties.recordTimestamp));

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

}