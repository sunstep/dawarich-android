import 'package:flutter_test/flutter_test.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import '../../mock/repository/local_point_repository_mock.dart';


void main() {
  late MockLocalPointRepository repository;
  const int testUserId = 1;
  const int anotherUserId = 2;

  setUp(() {
    repository = MockLocalPointRepository();
  });

  // Helper function to create a test point
  LocalPointDto createTestPoint({
    required int userId,
    required double longitude,
    required double latitude,
    required String timestamp,
  }) {
    return LocalPointDto(
      id: 0,
      type: 'Feature',
      geometry: LocalPointGeometryDto(
        type: 'Point',
        coordinates: [longitude, latitude],
      ),
      properties: LocalPointPropertiesDto(
        batteryState: 'charging',
        batteryLevel: 0.85,
        wifi: 'connected',
        timestamp: timestamp,
        horizontalAccuracy: 10.0,
        verticalAccuracy: 15.0,
        altitude: 100.0,
        speed: 5.0,
        speedAccuracy: 1.0,
        course: 90.0,
        courseAccuracy: 5.0,
        trackId: '',
        deviceId: 'test-device-id',
      ),
      userId: userId,
      isUploaded: false,
    );
  }

  group('MockLocalPointRepository', () {
    test('storePoint should store a point and assign an ID', () async {
      // Arrange
      final point = createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      );

      // Act
      final result = await repository.storePoint(point);

      // Assert
      expect(result.isOk(), true);
      
      // Verify the point was stored by checking the batch
      final batchResult = await repository.getFullBatch(testUserId);
      expect(batchResult.isOk(), true);
      expect(batchResult.unwrap().points.length, 1);
      expect(batchResult.unwrap().points[0].id, 1); // First ID should be 1
    });

    test('getLastPoint should return None when no points exist', () async {
      // Act
      final result = await repository.getLastPoint(testUserId);
      
      // Assert
      expect(result.isNone(), true);
    });

    test('getLastPoint should return the most recent point', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 11.0,
        latitude: 21.0,
        timestamp: '2023-06-15T11:00:00Z',
      ));

      // Act
      final result = await repository.getLastPoint(testUserId);
      
      // Assert
      expect(result.isSome(), true);
      final lastPoint = result.unwrap();
      expect(lastPoint.longitude, 11.0);
      expect(lastPoint.latitude, 21.0);
      expect(lastPoint.timestamp, '2023-06-15T11:00:00Z');
    });

    test('getFullBatch should return all points for a user', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 11.0,
        latitude: 21.0,
        timestamp: '2023-06-15T11:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: anotherUserId, // Different user
        longitude: 12.0,
        latitude: 22.0,
        timestamp: '2023-06-15T12:00:00Z',
      ));

      // Act
      final result = await repository.getFullBatch(testUserId);
      
      // Assert
      expect(result.isOk(), true);
      expect(result.unwrap().points.length, 2); // Only points for testUserId
    });

    test('getCurrentBatch should return only non-uploaded points', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 11.0,
        latitude: 21.0,
        timestamp: '2023-06-15T11:00:00Z',
      ));
      
      // Mark the first point as uploaded
      await repository.markBatchAsUploaded([1], testUserId);

      // Act
      final result = await repository.getCurrentBatch(testUserId);
      
      // Assert
      expect(result.isOk(), true);
      expect(result.unwrap().points.length, 1); // Only non-uploaded points
      expect(result.unwrap().points[0].id, 2); // Second point ID
    });

    test('getBatchPointCount should return count of non-uploaded points', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 11.0,
        latitude: 21.0,
        timestamp: '2023-06-15T11:00:00Z',
      ));
      
      // Mark the first point as uploaded
      await repository.markBatchAsUploaded([1], testUserId);

      // Act
      final result = await repository.getBatchPointCount(testUserId);
      
      // Assert
      expect(result.isOk(), true);
      expect(result.unwrap(), 1); // Only one non-uploaded point
    });

    test('markBatchAsUploaded should mark points as uploaded', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 11.0,
        latitude: 21.0,
        timestamp: '2023-06-15T11:00:00Z',
      ));

      // Act
      final result = await repository.markBatchAsUploaded([1, 2], testUserId);
      
      // Assert
      expect(result.isOk(), true);
      expect(result.unwrap(), 2); // Two points marked as uploaded
      
      // Verify via getCurrentBatch which should now be empty
      final batchResult = await repository.getCurrentBatch(testUserId);
      expect(batchResult.unwrap().points.isEmpty, true);
    });

    test('deletePoint should remove a point', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));

      // Act
      final result = await repository.deletePoint(1, testUserId);
      
      // Assert
      expect(result.isOk(), true);
      
      // Verify the point was deleted
      final batchResult = await repository.getFullBatch(testUserId);
      expect(batchResult.unwrap().points.isEmpty, true);
    });

    test('deletePoint should fail for non-existent point', () async {
      // Act
      final result = await repository.deletePoint(999, testUserId);
      
      // Assert
      expect(result.isErr(), true);
      expect(result.unwrapErr(), contains("Point not found"));
    });

    test('clearBatch should remove all non-uploaded points', () async {
      // Arrange
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 10.0,
        latitude: 20.0,
        timestamp: '2023-06-15T10:00:00Z',
      ));
      
      await repository.storePoint(createTestPoint(
        userId: testUserId,
        longitude: 11.0,
        latitude: 21.0,
        timestamp: '2023-06-15T11:00:00Z',
      ));
      
      // Mark the first point as uploaded
      await repository.markBatchAsUploaded([1], testUserId);

      // Act
      final result = await repository.clearBatch(testUserId);
      
      // Assert
      expect(result.isOk(), true);
      
      // Verify non-uploaded points were cleared
      final countResult = await repository.getBatchPointCount(testUserId);
      expect(countResult.unwrap(), 0);
      
      // Verify uploaded points remain
      final batchResult = await repository.getFullBatch(testUserId);
      expect(batchResult.unwrap().points.length, 1);
      expect(batchResult.unwrap().points[0].id, 1);
      expect(batchResult.unwrap().points[0].isUploaded, true);
    });
  });
}