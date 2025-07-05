import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point.dart';
import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_batch_converter.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/api/api_point_dto.dart';
import 'package:dawarich/features/timeline/data_contracts/data_transfer_objects/slim_api_point_dto.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/domain/models/point/api/api_point.dart';
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/option_result.dart';
import 'package:user_session_manager/user_session_manager.dart';

final class ApiPointService {

  final IApiPointRepository _pointInterfaces;
  final UserSessionManager<int> _userSession;
  ApiPointService(this._pointInterfaces, this._userSession);


  Future<bool> uploadBatch(DawarichPointBatch batch) async {
    final List<DawarichPoint> deduplicated = await _deduplicatePoints(
        batch.points);
    DawarichPointBatch deduplicatedBatch =
        DawarichPointBatch(points: deduplicated);
    Result<(), String> result =
    await _pointInterfaces.uploadBatch(deduplicatedBatch.toDto());
    return result.isOk();
  }

  Future<List<DawarichPoint>> _deduplicatePoints(
      List<DawarichPoint> points) async {
    final sorted = List<DawarichPoint>.from(points)
      ..sort((a, b) => a.properties.timestamp.compareTo(b.properties.timestamp));

    final userId = await _requireUserId();

    final seen = <String>{};
    final deduped = <DawarichPoint>[];

    for (final p in sorted) {
      final ts  = p.properties.timestamp;
      final lon = p.geometry.coordinates[0];
      final lat = p.geometry.coordinates[1];

      final key = '$userId|$ts|$lon|$lat';
      if (seen.add(key)) {
        deduped.add(p);
      }
    }

    debugPrint('[Upload] Deduplicated from ${points.length} → ${deduped.length}');
    return deduped;
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

  Future<int> _requireUserId() async {
    final int? userId = await _userSession.getUser();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[ApiPointService] No user session found.');
    }
    return userId;
  }
}
