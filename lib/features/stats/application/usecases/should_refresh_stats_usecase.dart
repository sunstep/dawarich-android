

import 'package:dawarich/features/stats/application/usecases/get_last_stats_sync_usecase.dart';
import 'package:option_result/option.dart';

final class ShouldRefreshStatsUseCase {
  static const Duration _maxAge = Duration(hours: 24);

  final GetLastStatsSyncUsecase _getLastSync;

  ShouldRefreshStatsUseCase(this._getLastSync);

  Future<bool> call({required DateTime nowUtc}) async {
    final lastOpt = await _getLastSync();

    if (lastOpt case Some(value: final lastUtc)) {
      final age = nowUtc.difference(lastUtc);
      return age >= _maxAge;
    }

    return true;
  }
}