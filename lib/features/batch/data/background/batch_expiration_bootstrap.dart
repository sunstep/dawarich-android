import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Background bootstrap for checking whether pending batches have expired
/// based on the user's configured [batchExpirationMinutes] and uploading
/// them if they have.
///
/// Designed to run inside a WorkManager periodic task. The check is
/// intentionally cheap: it only reads the oldest un-uploaded point timestamp,
/// compares it against the configured threshold, and triggers an upload only
/// when necessary.
final class BatchExpirationBootstrap {
  static Future<void> runInBackground() async {
    final container = ProviderContainer();
    try {
      final cfg = await container.read(apiConfigManagerProvider.future);
      if (!cfg.isConfigured) {
        if (kDebugMode) {
          debugPrint('[BatchExpiration] Skipping: ApiConfig not configured');
        }
        return;
      }

      final User? user = await container.read(sessionUserProvider.future);
      if (user == null) {
        if (kDebugMode) {
          debugPrint('[BatchExpiration] Skipping: no session user');
        }
        return;
      }

      final getSettings =
          await container.read(getTrackerSettingsUseCaseProvider.future);
      final settings = await getSettings(user.id);

      if (!settings.isBatchExpirationEnabled) {
        if (kDebugMode) {
          debugPrint('[BatchExpiration] Skipping: batch expiration disabled');
        }
        return;
      }

      final localRepo =
          await container.read(pointLocalRepositoryProvider.future);
      final oldest =
          await localRepo.getOldestUnUploadedPointTimestamp(user.id);

      if (oldest == null) {
        if (kDebugMode) {
          debugPrint('[BatchExpiration] Skipping: no pending points');
        }
        return;
      }

      final expirationThreshold = DateTime.now().subtract(
        Duration(minutes: settings.batchExpirationMinutes!),
      );

      if (oldest.isAfter(expirationThreshold)) {
        if (kDebugMode) {
          debugPrint(
            '[BatchExpiration] Batch not yet expired. '
            'Oldest: $oldest, threshold: $expirationThreshold',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          '[BatchExpiration] Batch expired! Oldest: $oldest, '
          'threshold: $expirationThreshold — uploading...',
        );
      }

      final getCurrentBatch =
          await container.read(getCurrentBatchUseCaseProvider.future);
      final batchUploadWorkflow =
          await container.read(batchUploadWorkflowUseCaseProvider.future);

      final batch = await getCurrentBatch(user.id);
      if (batch.isEmpty) return;

      final result = await batchUploadWorkflow(batch, user.id);

      if (kDebugMode) {
        debugPrint('[BatchExpiration] Upload result: $result');
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[BatchExpiration] failed: $e\n$s');
      }
    } finally {
      container.dispose();
    }
  }
}

