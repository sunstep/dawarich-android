import 'package:dawarich/application/converters/batch/dawarich/dawarich_point_batch_converter.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_batch.dart';
import 'package:dawarich/domain/entities/api/v1/points/response/api_point.dart';
import 'package:dawarich/domain/entities/api/v1/points/response/slim_api_point.dart';
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';

final class ApiPointService {
  final IApiPointRepository _pointInterfaces;
  ApiPointService(this._pointInterfaces);

  Future<bool> uploadBatch(DawarichPointBatch batch) async {
    Result<(), String> result =
        await _pointInterfaces.uploadBatch(batch.toDto());
    return result.isOk();
  }

  Future<Option<List<ApiPoint>>> fetchAllPoints(
      DateTime startDate, DateTime endDate, int perPage) async {
    Option<List<ApiPointDTO>> result =
        await _pointInterfaces.fetchPoints(startDate, endDate, perPage);

    switch (result) {
      case Some(value: List<ApiPointDTO> points):
        {
          return Some(points.map((point) => ApiPoint(point)).toList());
        }
      case None():
        return const None();
    }
  }

  Future<Option<List<SlimApiPoint>>> fetchAllSlimPoints(
      DateTime startDate, DateTime endDate, int perPage) async {
    Option<List<SlimApiPointDTO>> result =
        await _pointInterfaces.fetchSlimPoints(startDate, endDate, perPage);

    switch (result) {
      case Some(value: List<SlimApiPointDTO> points):
        {
          return Some(points.map((dto) => SlimApiPoint(dto)).toList());
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
    return await _pointInterfaces.getTotalPages(startDate, endDate, perPage);
  }

  List<SlimApiPoint> sortPoints(List<SlimApiPoint> data) {
    if (data.isEmpty) {
      return [];
    }

    data.sort((a, b) {
      int? timestampA = a.timestamp!;
      int? timestampB = b.timestamp!;

      return timestampA.compareTo(timestampB);
    });

    return data;
  }
}
