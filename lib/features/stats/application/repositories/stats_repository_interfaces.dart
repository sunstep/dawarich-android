import 'package:option_result/option_result.dart';
import 'package:dawarich/features/stats/data/data_transfer_objects/stats_dto.dart';

abstract interface class IStatsRepository {
  Future<Option<StatsDTO>> getStats();
}
