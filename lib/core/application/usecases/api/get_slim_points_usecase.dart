

import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/timeline/application/converters/slim_point_converter.dart';
import 'package:dawarich/features/timeline/data/data_transfer_objects/slim_api_point_dto.dart';
import 'package:option_result/option.dart';

final class GetSlimPointsUseCase {

  final IApiPointRepository _pointInterfaces;
  GetSlimPointsUseCase(this._pointInterfaces);

  Future<Option<List<SlimApiPoint>>> call({
    required DateTime startDate, required DateTime endDate, required int perPage,
  }) async {
    Option<List<SlimApiPointDTO>> result =
    await _pointInterfaces.getSlimPoints(startDate: startDate, endDate:  endDate, perPage:  perPage);

    if (result case Some(value: final List<SlimApiPointDTO> points)) {
      return Some(points.map((dto) => dto.toDomain()).toList());
    }

    return const None();
  }

}