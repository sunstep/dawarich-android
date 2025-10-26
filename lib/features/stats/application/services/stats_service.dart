import 'package:dawarich/features/stats/domain/stats.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/stats_dto.dart';
import 'package:dawarich/features/stats/application/repositories/stats_repository_interfaces.dart';
import 'package:option_result/option_result.dart';

class StatsService {
  final IStatsRepository _statsRepository;
  StatsService(this._statsRepository);

  Future<Option<Stats>> getStats() async {
    Option<StatsDTO> result = await _statsRepository.getStats();

    switch (result) {
      case Some(value: StatsDTO statsDTO):
        {
          return Some(Stats.fromDTO(statsDTO));
        }

      case None():
        {
          return const None();
        }
    }
  }
}
