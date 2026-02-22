
import 'package:dawarich/features/stats/application/repositories/stats_repository_interfaces.dart';
import 'package:option_result/option.dart';

final class GetLastStatsSyncUsecase {

  final IStatsRepository _statsRepository;
  GetLastStatsSyncUsecase(this._statsRepository);

  Future<DateTime?> call() async {
    final result = await _statsRepository.getLastSyncedAt();
    if (result case Some(value: DateTime lastSyncedAt)) {
      return lastSyncedAt;
    }

    return null;
  }

}