import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
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
  List<int> lastDeletePointIds = [];
  int? lastDeletePointUserId;

  int clearBatchCount = 0;
  int? lastClearBatchUserId;

  @override
  Future<int> storePoint(LocalPointDto point) async {
    storePointCount++;
    lastStoredPoint = point;

    if (failStorePoint) {
      throw Exception('Simulated store point error');
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
      longitude: last.geometry.longitude,
      latitude: last.geometry.latitude,
      timestamp: last.properties.timestamp,
    ));
  }

  @override
  Stream<Option<LastPointDto>> watchLastPoint(int userId) {

    return Stream.value(getLastPoint(userId)).asyncExpand((option) async* {
      yield const None();
    });
  }

  @override
  Future<List<LocalPointDto>> getFullBatch(int userId) async {
    getFullBatchCount++;
    lastGetFullBatchUserId = userId;

    if (failGetFullBatch) {
      throw Exception('Forced getFullBatch failure');
    }

    final pts = _points.values.where((p) => p.userId == userId).toList();
    return pts;
  }

  @override
  Future<List<LocalPointDto>> getCurrentBatch(int userId) async {
    getCurrentBatchCount++;
    lastGetCurrentBatchUserId = userId;

    if (failGetCurrentBatch) {
      throw Exception('Forced getCurrentBatch failure');
    }

    final pts = _points.values
        .where((p) => p.userId == userId && p.isUploaded == false)
        .toList();
    return pts;
  }

  @override
  Stream<List<LocalPointDto>> watchCurrentBatch(int userId) {
    return Stream.value(getCurrentBatch(userId)).asyncExpand((points) async* {
      yield [];
    });
  }

  @override
  Future<int> getBatchPointCount(int userId) async {
    getBatchCountCount++;
    lastGetBatchCountUserId = userId;

    if (failGetBatchCount) {
      throw Exception('Forced getBatchPointCount failure');
    }

    final count = _points.values
        .where((p) => p.userId == userId && p.isUploaded == false)
        .length;
    return count;
  }

  @override
  Stream<int> watchBatchPointCount(int userId) {
    return Stream.value(getBatchPointCount(userId)).asyncExpand((count) async* {
      yield 0;
    });
  }

  @override
  Future<int> markBatchAsUploaded(int userId, List<int> pointIds) async {
    markUploadedCount++;
    lastMarkUploadedUserId = userId;

    if (failMarkUploaded) {
      throw Exception('Forced failure');
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
  Future<int> deletePoints(int userId, List<int> pointId) async {

    deletePointCount++;
    lastDeletePointIds = pointId;
    lastDeletePointUserId = userId;

    if (failDeletePoint) {
      throw Exception('Forced deletePoint failure');
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
      throw Exception('Forced clearBatch failure');
    }

    final toRemove = _points.entries
        .where((e) => e.value.userId == userId && e.value.isUploaded == false)
        .map((e) => e.key)
        .toList();

    _points.removeWhere((index, point) => toRemove.contains(point.id));

    return toRemove.length;
  }
}
