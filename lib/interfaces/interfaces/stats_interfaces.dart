import 'package:option_result/option_result.dart';
import 'package:dawarich/interfaces/data_transfer_objects/api/v1/stats/response/stats_dto.dart';


abstract interface class IStatsRepository {

  Future<Option<StatsDTO>> getStats();
}