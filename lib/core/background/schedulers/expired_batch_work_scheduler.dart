import 'package:dawarich/core/background/workmanager/app_workmanager.dart';
import 'package:dawarich/core/background/workmanager/expired_batch_upload_worker.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

final class ExpiredBatchWorkScheduler {
  static Future<void> register(int expirationMinutes) async {
    await ensureWorkmanagerInitialized();

    final frequency = _getWorkerFrequency(expirationMinutes);

    if (kDebugMode) {
      debugPrint(
        '[ExpiredBatchWorker] Registering periodic work every '
            '${frequency.inMinutes} minutes.',
      );
    }

    await Workmanager().registerPeriodicTask(
      ExpiredBatchUploadWorker.uniqueWorkName,
      ExpiredBatchUploadWorker.uniqueWorkName,
      frequency: frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancel() async {
    await ensureWorkmanagerInitialized();

    if (kDebugMode) {
      debugPrint('[ExpiredBatchWorker] Cancelling periodic work.');
    }

    await Workmanager().cancelByUniqueName(
      ExpiredBatchUploadWorker.uniqueWorkName,
    );
  }

  static Duration _getWorkerFrequency(int expirationMinutes) {
    final minutes = expirationMinutes < 15 ? 15 : expirationMinutes;
    return Duration(minutes: minutes);
  }
}