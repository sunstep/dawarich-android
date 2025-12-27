

import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/application/converters/point/local/local_point_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/result.dart';

final class PrepareBatchUploadUseCase {

  Future<Result<List<DawarichPointBatch>, String>> call(List<LocalPoint> points, {
    void Function(int uploaded, int total)? onChunkUploaded,
  }) async {
    const int chunkSize = 250;

    final dedupedLocalPoints = await _deduplicateLocalPoints(points);

    if (dedupedLocalPoints.isEmpty) {
      debugPrint('[Upload] No new points to upload after full deduplication.');
      return const Err("All points already exist on the server.");
    }

    final List<DawarichPointBatch> chunks = <DawarichPointBatch>[];

    for (int i = 0; i < dedupedLocalPoints.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, dedupedLocalPoints.length);
      final chunk = dedupedLocalPoints.sublist(i, end);

      final List<DawarichPoint> apiPoints = chunk
          .map((point) => point.toApi())
          .toList();

      final DawarichPointBatch chunkBatch = DawarichPointBatch(points: apiPoints);
      chunks.add(chunkBatch);
    }

    return Ok(chunks);
  }

    //   final result = await _api.uploadBatch(dto);
    //
    //   if (result case Err(value: final String error)) {
    //     debugPrint('[Upload] Failed to upload chunk [$i..$end]: $error');
    //     failedChunks.addAll(chunk);
    //   } else {
    //     List<int> chunkIds = chunk.map((p) => p.id).toList();
    //     await deletePoints(chunkIds);
    //     uploaded += chunk.length;
    //     onChunkUploaded?.call(uploaded, dedupedLocalPoints.length);
    //   }
    //
    // }
    //
    // if (failedChunks.isNotEmpty) {
    //   if (kDebugMode) {
    //     debugPrint('[Batch Upload] Some batch chunks failed: retrying individually...');
    //   }
    //
    //   int failedCount = 0;
    //   int uploadedCount = 0;
    //
    //   for (final LocalPoint point in failedChunks) {
    //     final dto = DawarichPointBatch(points: [point.toApi()]).toDto();
    //     final result = await _api.uploadBatch(dto);
    //
    //     if (result case Err(value: final error)) {
    //       if (error.contains("already exists")) {
    //         await deletePoints([point.id]);
    //         uploadedCount++;
    //         onChunkUploaded?.call(uploadedCount, failedChunks.length);
    //         continue;
    //       }
    //
    //       failedCount++;
    //     } else {
    //       await deletePoints([point.id]);
    //       uploadedCount++;
    //       onChunkUploaded?.call(uploadedCount, failedChunks.length);
    //     }
    //   }
    //
    //   if (failedCount > 0) {
    //     return Err("$failedCount point(s) failed to upload after retrying.");
    //   }
    // }
    //
    // return const Ok(());


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


}