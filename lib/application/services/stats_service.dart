import 'package:dawarich/domain/entities/api/v1/stats/response/stats.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/stats_dto.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
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