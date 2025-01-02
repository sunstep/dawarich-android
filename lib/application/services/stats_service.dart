import 'package:dawarich/application/entities/api/stats/stats.dart';
import 'package:dawarich/domain/data_transfer_objects/api/stats/stats_dto.dart';
import 'package:dawarich/domain/interfaces/stats_interfaces.dart';
import 'package:option_result/option_result.dart';

class StatsService {

  final IStatsRepository _statsRepository;
  StatsService(this._statsRepository);

  Future<Option<Stats>> getStats() async {
    Option<StatsDTO> result = await _statsRepository.getStats();

    switch (result) {
      case Some(value: StatsDTO statsDTO): {
        return Some(Stats.fromDTO(statsDTO));
      }

      case None(): {
        return const None();
      }
    }
  }
}