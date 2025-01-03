
import 'package:dawarich/data/sources/api/stats/stats_source.dart';
import 'package:dawarich/domain/data_transfer_objects/api/stats/response/stats_dto.dart';
import 'package:dawarich/domain/interfaces/stats_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

class StatsRepository implements IStatsRepository {

  final StatsSource _source;
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