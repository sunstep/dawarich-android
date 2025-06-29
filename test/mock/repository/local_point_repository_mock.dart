import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:dawarich/core/database/%20repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:option_result/option_result.dart';

final class MockLocalPointRepository implements IPointLocalRepository {
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
  Future<int> storePoint(LocalPointDto point) async {
    storePointCount++;
    lastStoredPoint = point;

    if (failStorePoint) {
      throw ObjectBoxException('Simulated store point error');
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

    return pointId;
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
  Future<List<LocalPointDto>> getFullBatch(int userId) async {
    getFullBatchCount++;
    lastGetFullBatchUserId = userId;

    if (failGetFullBatch) {
      throw ObjectBoxException('Forced getFullBatch failure');
    }

    final pts = _points.values.where((p) => p.userId == userId).toList();
    return pts;
  }

  @override
  Future<List<LocalPointDto>> getCurrentBatch(int userId) async {
    getCurrentBatchCount++;
    lastGetCurrentBatchUserId = userId;

    if (failGetCurrentBatch) {
      throw ObjectBoxException('Forced getCurrentBatch failure');
    }

    final pts = _points.values
        .where((p) => p.userId == userId && p.isUploaded == false)
        .toList();
    return pts;
  }

  @override
  Future<int> getBatchPointCount(int userId) async {
    getBatchCountCount++;
    lastGetBatchCountUserId = userId;

    if (failGetBatchCount) {
      throw ObjectBoxException('Forced getBatchPointCount failure');
    }

    final count = _points.values
        .where((p) => p.userId == userId && p.isUploaded == false)
        .length;
    return count;
  }

  @override
  Future<int> markBatchAsUploaded(int userId) async {
    markUploadedCount++;
    lastMarkUploadedUserId = userId;

    if (failMarkUploaded) {
      throw ObjectBoxException('Forced failure');
    }

    var affected = 0;
    _points.forEach((id, p) {
      if (p.userId == userId && !p.isUploaded) {
        _points[id]?.copyWith(isUploaded: true);
        affected++;
      }
    });
    return affected;
  }

  @override
  Future<int> deletePoint(int userId, int pointId) async {

    deletePointCount++;
    lastDeletePointId = pointId;
    lastDeletePointUserId = userId;

    if (failDeletePoint) {
      throw ObjectBoxException('Forced deletePoint failure');
    }

    final int originalLength = _points.length;

    _points.removeWhere((index, point) =>
      point.userId == userId && point.id == pointId
    );

    final int currentLength = _points.length;
    return originalLength - currentLength;
  }

  @override
  Future<int> clearBatch(int userId) async {
    clearBatchCount++;
    lastClearBatchUserId = userId;

    if (failClearBatch) {
      throw ObjectBoxException('Forced clearBatch failure');
    }

    final toRemove = _points.entries
        .where((e) => e.value.userId == userId && e.value.isUploaded == false)
        .map((e) => e.key)
        .toList();

    _points.removeWhere((index, point) => toRemove.contains(point.id));

    return toRemove.length;
  }
}
