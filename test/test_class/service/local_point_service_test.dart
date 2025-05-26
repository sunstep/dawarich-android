import 'package:flutter_test/flutter_test.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_geometry_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/point/local/local_point_properties_dto.dart';
import 'package:option_result/option_result.dart';
import '../../mock/repository/local_point_repository_mock.dart';


void main() {
  late MockLocalPointRepository repo;
  const testUser = 1;
  const otherUser = 2;

  setUp(() {
    repo = MockLocalPointRepository();
  });

  LocalPointDto makePoint({
    required int userId,
    required double lon,
    required double lat,
    required String ts,
  }) {
    return LocalPointDto(
      id: 0,
      type: 'Feature',
      geometry: LocalPointGeometryDto(
        type: 'Point',
        coordinates: [lon, lat],
      ),
      properties: LocalPointPropertiesDto(
        batteryState: 'ok',
        batteryLevel: 0.5,
        wifi: 'none',
        timestamp: ts,
        horizontalAccuracy: 1.0,
        verticalAccuracy: 2.0,
        altitude: 3.0,
        speed: 4.0,
        speedAccuracy: 5.0,
        course: 6.0,
        courseAccuracy: 7.0,
        trackId: '',
        deviceId: 'dev1',
      ),
      userId: userId,
      isUploaded: false,
    );
  }

  group('MockLocalPointRepository', () {
    //----------------------------------------------------------------
    // storePoint
    //----------------------------------------------------------------
    test('storePoint: success increments counter & stores point', () async {
      final p = makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1');
      repo.failStorePoint = false;

      final res = await repo.storePoint(p);

      // Pattern‐match on Result
      switch (res) {
        case Ok():
        // good
          break;
        case Err(value: final err):
          fail('Expected Ok, got Err($err)');
      }

      // counter & arg
      expect(repo.storePointCount, 1);
      expect(repo.lastStoredPoint, equals(p));

      // verify it really stored
      final fullBatch = await repo.getFullBatch(testUser);
      switch (fullBatch) {
        case Ok(value: final batch):
          expect(batch.points.length, 1);
          expect(batch.points.first.id, 1);
        case Err(value: final err):
          fail('Expected Ok batch, got Err($err)');
      }
    });

    test('storePoint: failure flag returns Err and still increments', () async {
      final p = makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1');
      repo.failStorePoint = true;

      final res = await repo.storePoint(p);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final err):
          expect(err, 'Forced storePoint failure');
      }

      expect(repo.storePointCount, 1);
      expect(repo.lastStoredPoint, equals(p));
    });

    //----------------------------------------------------------------
    // getLastPoint
    //----------------------------------------------------------------
    test('getLastPoint: none when no points, counter+arg tracked', () async {
      repo.failGetLastPoint = false;
      final opt = await repo.getLastPoint(testUser);

      switch (opt) {
        case Some():
          fail('Expected None, got Some');
        case None():
        // good
          break;
      }

      expect(repo.getLastPointCount, 1);
      expect(repo.lastGetLastPointUserId, testUser);
    });

    test('getLastPoint: success returns most recent, tracks args', () async {
      // seed
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo.storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      repo.failGetLastPoint = false;

      final opt = await repo.getLastPoint(testUser);

      switch (opt) {
        case Some(value: final last):
          expect(last.longitude, 3);
          expect(last.latitude, 4);
          expect(last.timestamp, 't2');
        case None():
          fail('Expected Some, got None');
      }

      expect(repo.getLastPointCount, 1);
      expect(repo.lastGetLastPointUserId, testUser);
    });

    test('getLastPoint: failure flag yields None', () async {
      // seed so non-empty
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      repo.failGetLastPoint = true;

      final opt = await repo.getLastPoint(testUser);

      switch (opt) {
        case Some():
          fail('Expected None, got Some');
        case None():
        // good
          break;
      }

      expect(repo.getLastPointCount, 1);
    });

    //----------------------------------------------------------------
    // getFullBatch
    //----------------------------------------------------------------
    test('getFullBatch: success returns all for user, tracks args', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo.storePoint(makePoint(userId: otherUser, lon: 5, lat: 6, ts: 'tX'));
      repo.failGetFullBatch = false;

      final res = await repo.getFullBatch(testUser);

      switch (res) {
        case Ok(value: final batch):
          expect(batch.points.every((p) => p.userId == testUser), isTrue);
          expect(batch.points.length, 1);
        case Err(value: final err):
          fail('Expected Ok, got Err($err)');
      }

      expect(repo.getFullBatchCount, 1);
      expect(repo.lastGetFullBatchUserId, testUser);
    });

    test('getFullBatch: failure flag returns Err', () async {
      repo.failGetFullBatch = true;
      final res = await repo.getFullBatch(testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final err):
          expect(err, 'Forced getFullBatch failure');
      }

      expect(repo.getFullBatchCount, 1);
    });

    //----------------------------------------------------------------
    // getCurrentBatch
    //----------------------------------------------------------------
    test('getCurrentBatch: only non-uploaded points, tracks args', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo.storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      await repo.markBatchAsUploaded([1], testUser);
      repo.failGetCurrentBatch = false;

      final res = await repo.getCurrentBatch(testUser);

      switch (res) {
        case Ok(value: final batch):
          expect(batch.points.length, 1);
          expect(batch.points.first.id, 2);
        case Err(value: final err):
          fail('Expected Ok, got Err($err)');
      }

      expect(repo.getCurrentBatchCount, 1);
      expect(repo.lastGetCurrentBatchUserId, testUser);
    });

    test('getCurrentBatch: failure flag returns Err', () async {
      repo.failGetCurrentBatch = true;
      final res = await repo.getCurrentBatch(testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final err):
          expect(err, 'Forced getCurrentBatch failure');
      }

      expect(repo.getCurrentBatchCount, 1);
    });

    //----------------------------------------------------------------
    // getBatchPointCount
    //----------------------------------------------------------------
    test('getBatchPointCount: correct count, tracks args', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo.storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      await repo.markBatchAsUploaded([1], testUser);
      repo.failGetBatchCount = false;

      final res = await repo.getBatchPointCount(testUser);

      switch (res) {
        case Ok(value: final cnt):
          expect(cnt, 1);
        case Err(value: final err):
          fail('Expected Ok, got Err($err)');
      }

      expect(repo.getBatchCountCount, 1);
      expect(repo.lastGetBatchCountUserId, testUser);
    });

    test('getBatchPointCount: failure flag returns Err', () async {
      repo.failGetBatchCount = true;
      final res = await repo.getBatchPointCount(testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final err):
          expect(err, 'Forced getBatchPointCount failure');
      }

      expect(repo.getBatchCountCount, 1);
    });

    //----------------------------------------------------------------
    // markBatchAsUploaded
    //----------------------------------------------------------------
    test('markBatchAsUploaded: success', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo.storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      repo.failMarkUploaded = false;

      final res = await repo.markBatchAsUploaded([1, 2], testUser);

      switch (res) {
        case Ok(value: final updated):
          expect(updated, 2);
        case Err(value: final err):
          fail('Expected Ok, got Err($err)');
      }

      expect(repo.markUploadedCount, 1);
      expect(repo.lastMarkUploadedIds, [1, 2]);
      expect(repo.lastMarkUploadedUserId, testUser);

      final after = await repo.getCurrentBatch(testUser);
      switch (after) {
        case Ok(value: final b):
          expect(b.points, isEmpty);
        case Err():
          fail('Expected Ok after upload');
      }
    });

    test('markBatchAsUploaded: failure flag returns Err', () async {
      repo.failMarkUploaded = true;
      final res = await repo.markBatchAsUploaded([1], testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final err):
          expect(err, 'Forced markBatchAsUploaded failure');
      }

      expect(repo.markUploadedCount, 1);
    });

    //----------------------------------------------------------------
    // deletePoint
    //----------------------------------------------------------------
    test('deletePoint: success', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      repo.failDeletePoint = false;

      final res = await repo.deletePoint(1, testUser);

      switch (res) {
        case Ok():
        // ok
          break;
        case Err(value: final e):
          fail('Expected Ok, got Err($e)');
      }

      expect(repo.deletePointCount, 1);
      expect(repo.lastDeletePointId, 1);
      expect(repo.lastDeletePointUserId, testUser);

      final batch = await repo.getFullBatch(testUser);
      switch (batch) {
        case Ok(value: final b):
          expect(b.points, isEmpty);
        case Err(value: final e):
          fail('Expected Ok batch, got Err($e)');
      }
    });

    test('deletePoint: not found', () async {
      final res = await repo.deletePoint(999, testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final e):
          expect(e, 'Point not found.');
      }
    });

    test('deletePoint: failure flag returns Err', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      repo.failDeletePoint = true;

      final res = await repo.deletePoint(1, testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final e):
          expect(e, 'Forced deletePoint failure');
      }

      expect(repo.deletePointCount, 1);
    });

    //----------------------------------------------------------------
    // clearBatch
    //----------------------------------------------------------------
    test('clearBatch: success', () async {
      await repo.storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo.storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      await repo.markBatchAsUploaded([1], testUser);
      repo.failClearBatch = false;

      final res = await repo.clearBatch(testUser);

      switch (res) {
        case Ok():
        // ok
          break;
        case Err(value: final e):
          fail('Expected Ok, got Err($e)');
      }

      expect(repo.clearBatchCount, 1);
      expect(repo.lastClearBatchUserId, testUser);

      final full = await repo.getFullBatch(testUser);
      switch (full) {
        case Ok(value: final b):
          expect(b.points.length, 1);
          expect(b.points.first.id, 1);
          expect(b.points.first.isUploaded, isTrue);
        case Err(value: final e):
          fail('Expected Ok, got Err($e)');
      }
    });

    test('clearBatch: failure flag returns Err', () async {
      repo.failClearBatch = true;
      final res = await repo.clearBatch(testUser);

      switch (res) {
        case Ok():
          fail('Expected Err, got Ok');
        case Err(value: final e):
          expect(e, 'Forced clearBatch failure');
      }

      expect(repo.clearBatchCount, 1);
    });
  });
}