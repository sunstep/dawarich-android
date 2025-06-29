import 'package:dawarich/core/database/objectbox/entities/point/point_entity.dart';
import 'package:dawarich/core/database/objectbox/entities/point/point_geometry_entity.dart';
import 'package:dawarich/core/database/objectbox/entities/point/point_properties_entity.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data_contracts/data_transfer_objects/local/local_point_properties_dto.dart';
import 'package:dawarich/core/database/%20repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option.dart';

final class ObjectBoxPointLocalRepository implements IPointLocalRepository {

  final Store _database;
  ObjectBoxPointLocalRepository(this._database);

  @override
  Future<int> storePoint(LocalPointDto point) async {

    try {

      Box<PointGeometryEntity> geometryBox = Box<PointGeometryEntity>(_database);
      Box<PointPropertiesEntity> propertiesBox = Box<PointPropertiesEntity>(_database);
      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      int? pointId;

      _database.runInTransaction(TxMode.write, () {
          final PointGeometryEntity geometryEntity = PointGeometryEntity(
            type: point.type,
            coordinates: point.geometry.coordinates.join(',')
          );

          final PointPropertiesEntity propertiesEntity = PointPropertiesEntity(
            batteryState: point.properties.batteryState,
            batteryLevel: point.properties.batteryLevel,
            wifi: point.properties.wifi,
            timestamp: point.properties.timestamp,
            altitude: point.properties.altitude,
            speed: point.properties.speed,
            horizontalAccuracy: point.properties.horizontalAccuracy,
            verticalAccuracy: point.properties.verticalAccuracy,
            speedAccuracy: point.properties.speedAccuracy,
            course: point.properties.course,
            courseAccuracy: point.properties.courseAccuracy,
            deviceId: point.properties.deviceId
          );

          final int newGeometryId = geometryBox.put(geometryEntity);
          final int newPropertiesId = propertiesBox.put(propertiesEntity);

          final PointEntity pointEntity = PointEntity(
              type: point.type,
              isUploaded: point.isUploaded
          )
            ..geometry.targetId = newGeometryId
            ..properties.targetId = newPropertiesId
            ..user.targetId = point.userId;
          pointId = pointBox.put(pointEntity);
      });

      return pointId ?? 0;
    } on ObjectBoxException catch (obxE) {

      if (kDebugMode) {
        debugPrint('Failed to store new point: $obxE');
      }

      rethrow;
    }
  }

  @override
  Future<List<LocalPointDto>> getFullBatch(int userId) async {

    try {
      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return [];
      }

      final query = pointBox.query(PointEntity_.user.equals(userId)).build();
      final entities = query.find();
      query.close();

      // Temporarily map entities manually
      final List<LocalPointDto> pointList = entities.map((pointEntity) {

        final geometryEntity = pointEntity.geometry.target!;
        final geometryDto = LocalPointGeometryDto(
          type: geometryEntity.type,
          coordinates: geometryEntity.coordinates
              .split(',')
              .map(double.parse)
              .toList(),
        );

        final propertiesEntity = pointEntity.properties.target!;
        final propertiesDto = LocalPointPropertiesDto(
            batteryState: propertiesEntity.batteryState,
            batteryLevel: propertiesEntity.batteryLevel,
            wifi: propertiesEntity.wifi,
            timestamp: propertiesEntity.timestamp,
            horizontalAccuracy: propertiesEntity.horizontalAccuracy,
            verticalAccuracy: propertiesEntity.verticalAccuracy,
            altitude: propertiesEntity.altitude,
            speed: propertiesEntity.speedAccuracy,
            speedAccuracy: propertiesEntity.speedAccuracy,
            course: propertiesEntity.course,
            courseAccuracy: propertiesEntity.courseAccuracy,
            deviceId: propertiesEntity.deviceId
        );

        final LocalPointDto point = LocalPointDto(
            id: pointEntity.id,
            type: pointEntity.type,
            geometry: geometryDto,
            properties: propertiesDto,
            userId: userId,
            isUploaded: pointEntity.isUploaded
        );

        return point;
      }).toList();

      return pointList;

    } on ObjectBoxException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get full batch: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<LocalPointDto>> getCurrentBatch(int userId) async {

    try {

      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return [];
      }

      final query = pointBox.query(
          PointEntity_.user.equals(userId) &
          PointEntity_.isUploaded.equals(false)
      ).build();

      final entities = query.find();
      query.close();

      // Temporarily map entities manually
      final List<LocalPointDto> pointList = entities.map((pointEntity) {

        final geometryEntity = pointEntity.geometry.target!;
        final geometryDto = LocalPointGeometryDto(
          type: geometryEntity.type,
          coordinates: geometryEntity.coordinates
              .split(',')
              .map(double.parse)
              .toList(),
        );

        final propertiesEntity = pointEntity.properties.target!;
        final propertiesDto = LocalPointPropertiesDto(
            batteryState: propertiesEntity.batteryState,
            batteryLevel: propertiesEntity.batteryLevel,
            wifi: propertiesEntity.wifi,
            timestamp: propertiesEntity.timestamp,
            horizontalAccuracy: propertiesEntity.horizontalAccuracy,
            verticalAccuracy: propertiesEntity.verticalAccuracy,
            altitude: propertiesEntity.altitude,
            speed: propertiesEntity.speedAccuracy,
            speedAccuracy: propertiesEntity.speedAccuracy,
            course: propertiesEntity.course,
            courseAccuracy: propertiesEntity.courseAccuracy,
            deviceId: propertiesEntity.deviceId
        );

        final LocalPointDto point = LocalPointDto(
            id: pointEntity.id,
            type: pointEntity.type,
            geometry: geometryDto,
            properties: propertiesDto,
            userId: userId,
            isUploaded: pointEntity.isUploaded
        );

        return point;
      }).toList();

      return pointList;

    } on ObjectBoxException catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get current batch: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Option<LastPointDto>> getLastPoint(int userId) async {

    try {

      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return const None();
      }

      final query = pointBox
          .query(PointEntity_.user.equals(userId))
          .order(PointEntity_.id, flags: Order.descending)
          .build();

      query.limit = 1;
      final entity = query.findFirst();
      query.close();

      if (entity == null) {
        return const None();
      }

      final geometry = entity.geometry.target!;
      final properties = entity.properties.target!;

      final List<String> coordinates = geometry.coordinates.split(',');

      final LastPointDto lastPoint = LastPointDto(
          timestamp: properties.timestamp,
          longitude: double.parse(coordinates[0]),
          latitude: double.parse(coordinates[1])
      );

      return Some(lastPoint);
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to get last point: $e');
      }

      rethrow;
    }
  }

  @override
  Future<int> getBatchPointCount(int userId) async {

    try {

      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return 0;
      }

      final query = pointBox
          .query(PointEntity_.user.equals(userId) &
          PointEntity_.isUploaded.equals(false))
          .build();

      final entities = query.find();
      query.close();
      return entities.length;
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to get batch point count: $e');
      }

      rethrow;
    }
  }

  /// Marks the current batch in Objectbox as uploaded
  /// Returns the amount of points marked as uploaded.
  @override
  Future<int> markBatchAsUploaded(int userId) async {

    try {
      
      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return 0;
      }
      
      final query = pointBox
          .query(PointEntity_.user.equals(userId)
          .and(PointEntity_.isUploaded.equals(false)))
          .build();

      final entities = query.find();
      query.close();

      for (final entity in entities) {
        entity.isUploaded = true;
      }

      return pointBox.putMany(entities).length;
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to mark batch as uploaded: $e');
      }

      rethrow;
    }
  }

  @override
  Future<int> deletePoint(int userId, int pointId) async {
    
    try {

      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return 0;
      }
      
      final query = pointBox
          .query(PointEntity_.user.equals(userId)
          .and(PointEntity_.id.equals(pointId)))
          .build();

      final entities = query.find();
      query.close();

      return pointBox.removeMany(entities.map((entity) => entity.id).toList());
      
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to delete point: $e');
      }

      rethrow;
    }
  }

  @override
  Future<int> clearBatch(int userId) async {

    try {

      Box<PointEntity> pointBox = Box<PointEntity>(_database);

      if (pointBox.isEmpty()) {
        return 0;
      }

      final query = pointBox
          .query(PointEntity_.user.equals(userId)
          .and(PointEntity_.isUploaded.equals(false)))
          .build();

      final int deletedRowCount = query.remove();
      return deletedRowCount;

    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to clear batch: $e');
      }

      rethrow;
    }
  }

}