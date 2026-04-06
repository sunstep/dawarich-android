import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Background bootstrap for batch upload work.
///
/// Runs inside a WorkManager periodic task (~15 min). Handles:
///  1. **Threshold upload** – batch has enough points to upload.
///  2. **Expiration upload** – oldest un-uploaded point exceeds the
///     configured time window.
///
/// Both checks are cheap DB reads. A network call only happens when
/// there is actually work to do.
final class BatchUploadBootstrap {
  static Future<void> runInBackground() async {
    final container = ProviderContainer();
    try {
      final cfg = await container.read(apiConfigManagerProvider.future);
      if (!cfg.isConfigured) {
        if (kDebugMode) {
          debugPrint('[BatchUpload] Skipping: ApiConfig not configured');
        }
        return;
      }

      final User? user = await container.read(sessionUserProvider.future);
      if (user == null) {
        if (kDebugMode) {
          debugPrint('[BatchUpload] Skipping: no session user');
        }
        return;
      }

      final getSettings =
          await container.read(getTrackerSettingsUseCaseProvider.future);
      final settings = await getSettings(user.id);

      final localRepo =
          await container.read(pointLocalRepositoryProvider.future);
      final getCurrentBatch =
          await container.read(getCurrentBatchUseCaseProvider.future);
      final batchUploadWorkflow =
          await container.read(batchUploadWorkflowUseCaseProvider.future);

      // 1. Threshold check — upload if batch has enough points.
      final pointCount = await localRepo.getBatchPointCount(user.id);
      if (pointCount >= settings.pointsPerBatch) {
        if (kDebugMode) {
          debugPrint(
            '[BatchUpload] Threshold met ($pointCount >= ${settings.pointsPerBatch}) — uploading...',
          );
        }
        await _upload(getCurrentBatch, batchUploadWorkflow, user.id);
        return;
      }

      // 2. Expiration check — upload if oldest point exceeds the window.
      if (settings.isBatchExpirationEnabled) {
        final oldest =
            await localRepo.getOldestUnUploadedPointTimestamp(user.id);

        if (oldest != null) {
          final threshold = DateTime.now().subtract(
            Duration(minutes: settings.batchExpirationMinutes!),
          );

          if (oldest.isBefore(threshold)) {
            if (kDebugMode) {
              debugPrint(
                '[BatchUpload] Batch expired (oldest: $oldest, '
                'threshold: $threshold) — uploading...',
              );
            }
            await _upload(getCurrentBatch, batchUploadWorkflow, user.id);
            return;
          }
        }
      }

      if (kDebugMode) {
        debugPrint('[BatchUpload] Nothing to do ($pointCount points, no expiration)');
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[BatchUpload] failed: $e\n$s');
      }
    } finally {
      container.dispose();
    }
  }

  static Future<void> _upload(
    dynamic getCurrentBatch,
    dynamic batchUploadWorkflow,
    int userId,
  ) async {
    final batch = await getCurrentBatch(userId);
    if (batch.isEmpty) return;

    final result = await batchUploadWorkflow(batch, userId);
    if (kDebugMode) {
      debugPrint('[BatchUpload] Upload result: $result');
    }
  }
}

