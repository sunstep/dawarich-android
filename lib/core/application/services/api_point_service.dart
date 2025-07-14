
import 'package:dawarich/features/timeline/application/converters/slim_point_converter.dart';
import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_batch_converter.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/point/api/api_point.dart';
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/upload/dawarich_point_batch_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class ApiPointService {

  final IApiPointRepository _pointInterfaces;
  ApiPointService(this._pointInterfaces);


  Future<Result<(), String>> uploadBatch(DawarichPointBatch batch) async {

    if (batch.points.isEmpty) {
      debugPrint('[Upload] No points to upload.');
      return Err("There are no points to upload.");
    }

    DawarichPointBatchDto uploadBatchDto = batch.toDto();


    final result = await _pointInterfaces.uploadBatch(uploadBatchDto);

    if (result case Err(value: final String error)) {
      return Err(error);
    }

    return Ok(());
  }

  Future<Option<List<ApiPoint>>> getPoints({
      required DateTime startDate, required DateTime endDate, required int perPage}) async {
    Option<List<ApiPointDTO>> result =
        await _pointInterfaces.getPoints(startDate: startDate, endDate:  endDate, perPage:  perPage);

    switch (result) {
      case Some(value: List<ApiPointDTO> points):
        {
          return Some(points.map((point) => ApiPoint(point)).toList());
        }
      case None():
        return const None();
    }
  }

  Future<Option<List<SlimApiPoint>>> getSlimPoints({
      required DateTime startDate, required DateTime endDate, required int perPage}) async {
    Option<List<SlimApiPointDTO>> result =
        await _pointInterfaces.getSlimPoints(startDate: startDate, endDate:  endDate, perPage:  perPage);

    switch (result) {
      case Some(value: List<SlimApiPointDTO> points):
        {
          return Some(points.map((dto) => dto.toDomain()).toList());
        }
      case None():
        return const None();
    }
  }

  Future<bool> deletePoint(String point) async {

    Result<(), String> result = await _pointInterfaces.deletePoint(point);

    switch (result) {
      case Ok(value: ()):
        return true;
      case Err(value: String error):
        {
          debugPrint("Failed to delete point: $error");
          return false;
        }
    }
  }

  Future<int> getTotalPages(
      DateTime startDate, DateTime endDate, int perPage) async {
    return await _pointInterfaces.getTotalPages(startDate: startDate, endDate:  endDate, perPage:  perPage);
  }

}
