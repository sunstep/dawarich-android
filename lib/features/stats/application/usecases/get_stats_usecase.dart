

import 'package:dawarich/features/stats/application/repositories/stats_repository_interfaces.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/stats/stats_dto.dart';
import 'package:dawarich/features/stats/domain/stats/stats.dart';
import 'package:option_result/option.dart';

final class GetStatsUseCase {

  final IStatsRepository _statsRepository;
  GetStatsUseCase(this._statsRepository);

  Future<Option<Stats>> call() async {
    Option<StatsDTO> result = await _statsRepository.getStats();

    if (result case Some(value: StatsDTO statsDTO)) {
      return Some(Stats.fromDTO(statsDTO));
    }

    return const None();
  }
}