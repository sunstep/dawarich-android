

import 'package:dawarich/features/stats/application/usecases/get_last_stats_sync_usecase.dart';

final class ShouldRefreshStatsUseCase {
  static const Duration _maxAge = Duration(hours: 24);

  final GetLastStatsSyncUsecase _getLastSync;

  ShouldRefreshStatsUseCase(this._getLastSync);

  Future<bool> call(int userId, {required DateTime nowUtc}) async {
    final DateTime? lastUtc = await _getLastSync(userId);

    if (lastUtc == null) {
      return true;
    }

    final age = nowUtc.difference(lastUtc);
    return age >= _maxAge;
  }
}