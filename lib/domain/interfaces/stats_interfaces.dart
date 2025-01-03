import 'package:option_result/option_result.dart';
import 'package:dawarich/domain/data_transfer_objects/api/stats/response/stats_dto.dart';


abstract interface class IStatsRepository {

  Future<Option<StatsDTO>> getStats();
}