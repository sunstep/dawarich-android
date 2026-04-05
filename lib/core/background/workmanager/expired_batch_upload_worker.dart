import 'package:dawarich/core/di/providers/core_providers.dart';
import 'package:dawarich/core/di/providers/session_providers.dart';
import 'package:dawarich/core/di/providers/usecase_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:option_result/result.dart';

final class ExpiredBatchUploadWorker {
  static const String uniqueWorkName = 'expired-batch-upload-check';

  /// Executes the expired-batch-upload task logic.
  /// Called by [appWorkmanagerCallbackDispatcher] — do NOT call
  /// [Workmanager().initialize] here.
  static Future<void> execute() async {
    ProviderContainer? container;

    try {
      if (kDebugMode) {
        debugPrint('[ExpiredBatchWorker] Starting worker...');
      }

      container = ProviderContainer();
      await container.read(coreProvider.future);

      final session = await container.read(sessionBoxProvider.future);
      final user = await session.refreshSession();

      if (user == null) {
        if (kDebugMode) {
          debugPrint('[ExpiredBatchWorker] No user session, skipping.');
        }
        return;
      }

      final checkExpiredBatch =
          await container.read(checkAndUploadExpiredBatchUseCaseProvider.future);

      final result = await checkExpiredBatch(user.id);

      if (result case Ok(value: final didUpload)) {
        if (kDebugMode) {
          if (didUpload) {
            debugPrint('[ExpiredBatchWorker] Expired batch uploaded.');
          } else {
            debugPrint('[ExpiredBatchWorker] No expired batch to upload.');
          }
        }
      } else if (result case Err(value: final err)) {
        debugPrint('[ExpiredBatchWorker] Expired batch check failed: $err');
      }
    } catch (e, s) {
      debugPrint('[ExpiredBatchWorker] Fatal worker error: $e\n$s');
      // This is an opportunistic check, not a mission-critical exact job.
    } finally {
      container?.dispose();
    }
  }
}