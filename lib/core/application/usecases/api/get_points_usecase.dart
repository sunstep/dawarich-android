

import 'package:dawarich/core/domain/models/point/api/api_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/api/api_point_dto.dart';
import 'package:option_result/option.dart';

final class GetPointsUseCase {

  final IApiPointRepository _pointInterfaces;
  GetPointsUseCase(this._pointInterfaces);

  Future<Option<List<ApiPoint>>> call({
    required DateTime startDate, required DateTime endDate, required int perPage}) async {
    Option<List<ApiPointDTO>> result =
    await _pointInterfaces.getPoints(startDate: startDate, endDate:  endDate, perPage:  perPage);


    if (result case Some(value: final List<ApiPointDTO> points)) {
      return Some(points.map((point) => ApiPoint(point)).toList());
    }

    return const None();
  }
}