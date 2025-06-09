import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:option_result/option_result.dart';

final class MockLocalPointRepository implements ILocalPointRepository {
  final Map<int, LocalPointDto> _points = {};
  final Map<int, LocalPointGeometryDto> _geoms = {};
  final Map<int, LocalPointPropertiesDto> _props = {};

  int _nextPointId = 1;
  int _nextGeometryId = 1;
  int _nextPropertiesId = 1;

  bool failStorePoint = false;
  bool failGetLastPoint = false;
  bool failGetFullBatch = false;
  bool failGetCurrentBatch = false;
  bool failGetBatchCount = false;
  bool failMarkUploaded = false;
  bool failDeletePoint = false;
  bool failClearBatch = false;

  int storePointCount = 0;
  LocalPointDto? lastStoredPoint;

  int getLastPointCount = 0;
  int? lastGetLastPointUserId;

  int getFullBatchCount = 0;
  int? lastGetFullBatchUserId;

  int getCurrentBatchCount = 0;
  int? lastGetCurrentBatchUserId;

  int getBatchCountCount = 0;
  int? lastGetBatchCountUserId;

  int markUploadedCount = 0;
  List<int>? lastMarkUploadedIds;
  int? lastMarkUploadedUserId;

  int deletePointCount = 0;
  int? lastDeletePointId;
  int? lastDeletePointUserId;

  int clearBatchCount = 0;
  int? lastClearBatchUserId;

  @override
  Future<Result<(), String>> storePoint(LocalPointDto point) async {
    storePointCount++;
    lastStoredPoint = point;

    if (failStorePoint) {
      return const Err('Forced storePoint failure');
    }

    // simulate id & separate storage
    final geomId = _nextGeometryId++;
    final propId = _nextPropertiesId++;
    final pointId = _nextPointId++;

    _geoms[geomId] = point.geometry;
    _props[propId] = point.properties;
    _points[pointId] = LocalPointDto(
      id: pointId,
      type: point.type,
      geometry: point.geometry,
      properties: point.properties,
      userId: point.userId,
      isUploaded: false,
    );

    return const Ok(());
  }

  @override
  Future<Option<LastPointDto>> getLastPoint(int userId) async {
    getLastPointCount++;
    lastGetLastPointUserId = userId;

    if (failGetLastPoint) {
      return const None();
    }

    final userPoints = _points.values.where((p) => p.userId == userId).toList();
    if (userPoints.isEmpty) return const None();

    userPoints.sort((a, b) => b.id.compareTo(a.id));
    final last = userPoints.first;
    return Some(LastPointDto(
      longitude: last.geometry.coordinates[0],
      latitude: last.geometry.coordinates[1],
      timestamp: last.properties.timestamp,
    ));
  }

  @override
  Future<Result<LocalPointBatchDto, String>> getFullBatch(int userId) async {
    getFullBatchCount++;
    lastGetFullBatchUserId = userId;

    if (failGetFullBatch) {
      return const Err('Forced getFullBatch failure');
    }

    final pts = _points.values.where((p) => p.userId == userId).toList();
    return Ok(LocalPointBatchDto(points: pts));
  }

  @override
  Future<Result<LocalPointBatchDto, String>> getCurrentBatch(int userId) async {
    getCurrentBatchCount++;
    lastGetCurrentBatchUserId = userId;

    if (failGetCurrentBatch) {
      return const Err('Forced getCurrentBatch failure');
    }

    final pts = _points.values
        .where((p) => p.userId == userId && p.isUploaded == false)
        .toList();
    return Ok(LocalPointBatchDto(points: pts));
  }

  @override
  Future<Result<int, String>> getBatchPointCount(int userId) async {
    getBatchCountCount++;
    lastGetBatchCountUserId = userId;

    if (failGetBatchCount) {
      return const Err('Forced getBatchPointCount failure');
    }

    final count = _points.values
        .where((p) => p.userId == userId && p.isUploaded == false)
        .length;
    return Ok(count);
  }

  @override
  Future<Result<int, String>> markBatchAsUploaded(
      List<int> batchIds, int userId) async {
    markUploadedCount++;
    lastMarkUploadedIds = batchIds;
    lastMarkUploadedUserId = userId;

    if (failMarkUploaded) {
      return const Err('Forced markBatchAsUploaded failure');
    }

    var affected = 0;
    for (final id in batchIds) {
      final p = _points[id];
      if (p != null && p.userId == userId) {
        _points[id] = LocalPointDto(
          id: p.id,
          type: p.type,
          geometry: p.geometry,
          properties: p.properties,
          userId: p.userId,
          isUploaded: true,
        );
        affected++;
      }
    }
    return Ok(affected);
  }

  @override
  Future<Result<(), String>> deletePoint(int pointId, int userId) async {
    deletePointCount++;
    lastDeletePointId = pointId;
    lastDeletePointUserId = userId;

    if (failDeletePoint) {
      return const Err('Forced deletePoint failure');
    }

    final p = _points[pointId];
    if (p == null || p.userId != userId) {
      return const Err('Point not found.');
    }
    _points.remove(pointId);
    return const Ok(());
  }

  @override
  Future<Result<(), String>> clearBatch(int userId) async {
    clearBatchCount++;
    lastClearBatchUserId = userId;

    if (failClearBatch) {
      return const Err('Forced clearBatch failure');
    }

    final toRemove = _points.entries
        .where((e) => e.value.userId == userId && e.value.isUploaded == false)
        .map((e) => e.key)
        .toList();
    for (final id in toRemove) {
      _points.remove(id);
    }
    return const Ok(());
  }
}
