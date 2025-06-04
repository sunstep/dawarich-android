import 'package:dawarich/data/sources/api/v1/stats/stats_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/stats_dto.dart';
import 'package:dawarich/data_contracts/interfaces/stats_repository_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

final class StatsRepository implements IStatsRepository {

  final StatsClient _source;
  StatsRepository(this._source);

  @override
  Future<Option<StatsDTO>> getStats() async {

    final Result<StatsDTO, String> result = await _source.queryStats();

    switch (result) {

      case Ok(value: StatsDTO statsDTO): {
        return Some(statsDTO);
      }

      case Err(value: String error): {

        debugPrint("Failed to retrieve stats: $error");
        return const None();
      }
    }
  }


}