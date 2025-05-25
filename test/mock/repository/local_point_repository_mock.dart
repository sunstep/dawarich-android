import 'package:dawarich/data_contracts/data_transfer_objects/local/last_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import 'package:dawarich/data_contracts/interfaces/local_point_repository_interfaces.dart';
import 'package:option_result/option_result.dart';

final class MockLocalPointRepository implements ILocalPointRepository {

  final Map<int, LocalPointDto> _points = {};
  final Map<int, LocalPointGeometryDto> _geometries = {};
  final Map<int, LocalPointPropertiesDto> _properties = {};
  
  int _nextPointId = 1;
  int _nextGeometryId = 1;
  int _nextPropertiesId = 1;
  
  @override
  Future<Result<(), String>> storePoint(LocalPointDto point) async {
    try {
      // Store geometry first
      final int geometryId = _nextGeometryId++;
      _geometries[geometryId] = point.geometry;
      
      // Store properties
      final int propertiesId = _nextPropertiesId++;
      _properties[propertiesId] = point.properties;
      
      // Store the point with references to geometry and properties
      final int pointId = _nextPointId++;
      final pointWithId = LocalPointDto(
        id: pointId,
        type: point.type,
        geometry: point.geometry,
        properties: point.properties,
        userId: point.userId,
        isUploaded: false
      );
      
      _points[pointId] = pointWithId;
      
      return const Ok(());
    } catch (e) {
      return Err("Failed to store point: $e");
    }
  }

  @override
  Future<Option<LastPointDto>> getLastPoint(int userId) async {
    try {
      // Find all points for this user
      final userPoints = _points.values
          .where((p) => p.userId == userId)
          .toList();
      
      if (userPoints.isEmpty) {
        return const None();
      }
      
      // Sort by ID (assuming higher ID means more recent)
      userPoints.sort((a, b) => b.id.compareTo(a.id));
      
      // Get the most recent point
      final lastPoint = userPoints.first;
      
      // Convert to LastPointDto
      return Some(LastPointDto(
        longitude: lastPoint.geometry.coordinates[0],
        latitude: lastPoint.geometry.coordinates[1],
        timestamp: lastPoint.properties.timestamp
      ));
    } catch (e) {
      return const None();
    }
  }

  @override
  Future<Result<LocalPointBatchDto, String>> getFullBatch(int userId) async {
    try {
      final userPoints = _points.values
          .where((p) => p.userId == userId)
          .toList();
          
      return Ok(LocalPointBatchDto(points: userPoints));
    } catch (e) {
      return Err("Failed to retrieve batch points: $e");
    }
  }

  @override
  Future<Result<LocalPointBatchDto, String>> getCurrentBatch(int userId) async {
    try {
      final userPoints = _points.values
          .where((p) => p.userId == userId && p.isUploaded == false)
          .toList();
          
      return Ok(LocalPointBatchDto(points: userPoints));
    } catch (e) {
      return Err("Failed to retrieve batch points: $e");
    }
  }

  @override
  Future<Result<int, String>> getBatchPointCount(int userId) async {
    try {
      final count = _points.values
          .where((p) => p.userId == userId && p.isUploaded == false)
          .length;
          
      return Ok(count);
    } catch (e) {
      return Err("Failed to get point count of batch: $e");
    }
  }

  @override
  Future<Result<int, String>> markBatchAsUploaded(List<int> batchIds, int userId) async {
    try {
      int rowsAffected = 0;
      
      for (final pointId in batchIds) {
        if (_points.containsKey(pointId) && _points[pointId]!.userId == userId) {
          final updatedPoint = LocalPointDto(
            id: _points[pointId]!.id,
            type: _points[pointId]!.type,
            geometry: _points[pointId]!.geometry,
            properties: _points[pointId]!.properties,
            userId: _points[pointId]!.userId,
            isUploaded: true
          );
          
          _points[pointId] = updatedPoint;
          rowsAffected++;
        }
      }
      
      return Ok(rowsAffected);
    } catch (e) {
      return Err("Failed to mark batch as uploaded: $e");
    }
  }

  @override
  Future<Result<(), String>> deletePoint(int pointId, int userId) async {
    try {
      if (!_points.containsKey(pointId) || _points[pointId]!.userId != userId) {
        return const Err("Point not found.");
      }
      
      _points.remove(pointId);
      return const Ok(());
    } catch (e) {
      return Err("Failed to delete point: $e");
    }
  }

  @override
  Future<Result<(), String>> clearBatch(int userId) async {
    try {
      // Find all point IDs that match the criteria
      final pointIdsToRemove = _points.entries
          .where((entry) => entry.value.userId == userId && entry.value.isUploaded == false)
          .map((entry) => entry.key)
          .toList();
      
      // Remove those points
      for (final id in pointIdsToRemove) {
        _points.remove(id);
      }
      
      return const Ok(());
    } catch (e) {
      return Err("Failed to clear batch: $e");
    }
  }
}