import 'package:dawarich/features/tracking/data/data_transfer_objects/point/last_point_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/local/local_point_dto.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/local/local_point_geometry_dto.dart';
import 'package:dawarich/core/point_data/data/data_transfer_objects/local/local_point_properties_dto.dart';
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
        longitude: lon,
        latitude: lat
      ),
      properties: LocalPointPropertiesDto(
        batteryState: 'ok',
        batteryLevel: 0.5,
        wifi: 'none',
        timestamp: DateTime.parse(ts),
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

      final id = await repo.storePoint(p);

      if (id < 1) {
        fail('New point id smaller than 1)');
      }
      
      // counter & arg
      expect(repo.storePointCount, 1);
      expect(repo.lastStoredPoint, equals(p));

      // verify it really stored
      final batch = await repo.getFullBatch(testUser);
      expect(batch.length, 1);
      expect(batch.first.id, 1);
    });

    test('storePoint: failure flag throws exception and still increments', () async {
      final p = makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1');
      repo.failStorePoint = true;

      expect(
        () => repo.storePoint(p),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Simulated store point error')
        )),
      );

      expect(repo.storePointCount, 1);
      expect(repo.lastStoredPoint, equals(p));
    });

    //----------------------------------------------------------------
    // getLastPoint
    //----------------------------------------------------------------
    test('getLastPoint: none when no points, counter+arg tracked', () async {
      repo.failGetLastPoint = false;
      final opt = await repo.getLastPoint(testUser);

      expect(opt, isA<None>());

      expect(repo.getLastPointCount, 1);
      expect(repo.lastGetLastPointUserId, testUser);
    });

    test('getLastPoint: success returns most recent, tracks args', () async {
      // seed
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo
          .storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      repo.failGetLastPoint = false;

      final opt = await repo.getLastPoint(testUser);

      expect(opt, isA<Some<LastPointDto>>());
      if (opt is Some<LastPointDto>) {
        final last = opt.value;
        expect(last.longitude, 3);
        expect(last.latitude, 4);
        expect(last.timestamp, 't2');
      }

      expect(repo.getLastPointCount, 1);
      expect(repo.lastGetLastPointUserId, testUser);
    });

    test('getLastPoint: failure flag yields None', () async {
      // seed so non-empty
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      repo.failGetLastPoint = true;

      final opt = await repo.getLastPoint(testUser);
      
      expect(opt, isA<None>());
      expect(repo.getLastPointCount, 1);
    });

    //----------------------------------------------------------------
    // getFullBatch
    //----------------------------------------------------------------
    test('getFullBatch: success returns all for user, tracks args', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo
          .storePoint(makePoint(userId: otherUser, lon: 5, lat: 6, ts: 'tX'));
      repo.failGetFullBatch = false;

      final batch = await repo.getFullBatch(testUser);

      expect(batch.every((p) => p.userId == testUser), isTrue);
      expect(batch.length, 1);

      expect(repo.getFullBatchCount, 1);
      expect(repo.lastGetFullBatchUserId, testUser);
    });

    test('getFullBatch: failure flag throws exception', () async {
      repo.failGetFullBatch = true;
      
      expect(
        () => repo.getFullBatch(testUser),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Forced getFullBatch failure')
        )),
      );

      expect(repo.getFullBatchCount, 1);
    });

    //----------------------------------------------------------------
    // getCurrentBatch
    //----------------------------------------------------------------
    test('getCurrentBatch: only non-uploaded points, tracks args', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo
          .storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      await repo.markBatchAsUploaded(testUser, [1]); // Mark first as uploaded
      repo.failGetCurrentBatch = false;

      final batch = await repo.getCurrentBatch(testUser);

      expect(batch.length, 0); // Since all points are marked as uploaded

      expect(repo.getCurrentBatchCount, 1);
      expect(repo.lastGetCurrentBatchUserId, testUser);
    });

    test('getCurrentBatch: failure flag throws exception', () async {
      repo.failGetCurrentBatch = true;
      
      expect(
        () => repo.getCurrentBatch(testUser),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Forced getCurrentBatch failure')
        )),
      );

      expect(repo.getCurrentBatchCount, 1);
    });

    //----------------------------------------------------------------
    // getBatchPointCount
    //----------------------------------------------------------------
    test('getBatchPointCount: correct count, tracks args', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo
          .storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      await repo.markBatchAsUploaded(testUser, [1]); // Mark first as uploaded
      repo.failGetBatchCount = false;

      final cnt = await repo.getBatchPointCount(testUser);
      
      expect(cnt, 0); // All points are marked as uploaded

      expect(repo.getBatchCountCount, 1);
      expect(repo.lastGetBatchCountUserId, testUser);
    });

    test('getBatchPointCount: failure flag throws exception', () async {
      repo.failGetBatchCount = true;
      
      expect(
        () => repo.getBatchPointCount(testUser),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Forced getBatchPointCount failure')
        )),
      );

      expect(repo.getBatchCountCount, 1);
    });

    //----------------------------------------------------------------
    // markBatchAsUploaded
    //----------------------------------------------------------------
    test('markBatchAsUploaded: success', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo
          .storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      repo.failMarkUploaded = false;

      final updated = await repo.markBatchAsUploaded(testUser, [1, 2]);

      expect(updated, 2);

      expect(repo.markUploadedCount, 1);
      expect(repo.lastMarkUploadedIds, [1, 2]);
      expect(repo.lastMarkUploadedUserId, testUser);

      final batch = await repo.getCurrentBatch(testUser);
      expect(batch, isEmpty);
    });

    test('markBatchAsUploaded: failure flag throws exception', () async {
      repo.failMarkUploaded = true;
      
      expect(
        () => repo.markBatchAsUploaded(testUser, [1, 2]),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Forced markBatchAsUploaded failure')
        )),
      );

      expect(repo.markUploadedCount, 1);
    });

    //----------------------------------------------------------------
    // deletePoint
    //----------------------------------------------------------------
    test('deletePoint: success', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      repo.failDeletePoint = false;

      final result = await repo.deletePoints(testUser, [1]);

      expect(result, 1);

      expect(repo.deletePointCount, 1);
      expect(repo.lastDeletePointIds, [1]);
      expect(repo.lastDeletePointUserId, testUser);

      final batch = await repo.getFullBatch(testUser);
      expect(batch, isEmpty);
    });

    test('deletePoint: not found', () async {
      expect(
        () => repo.deletePoints(testUser, [999]),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Point not found')
        )),
      );
    });

    test('deletePoint: failure flag throws exception', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      repo.failDeletePoint = true;

      expect(
        () => repo.deletePoints(testUser, [1]),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Forced deletePoint failure')
        )),
      );

      expect(repo.deletePointCount, 1);
    });

    //----------------------------------------------------------------
    // clearBatch
    //----------------------------------------------------------------
    test('clearBatch: success', () async {
      await repo
          .storePoint(makePoint(userId: testUser, lon: 1, lat: 2, ts: 't1'));
      await repo
          .storePoint(makePoint(userId: testUser, lon: 3, lat: 4, ts: 't2'));
      repo.failClearBatch = false;

      final count = await repo.clearBatch(testUser);

      expect(count, 2);

      expect(repo.clearBatchCount, 1);
      expect(repo.lastClearBatchUserId, testUser);

      final full = await repo.getFullBatch(testUser);
      expect(full, isEmpty);
    });

    test('clearBatch: failure flag throws exception', () async {
      repo.failClearBatch = true;
      
      expect(
        () => repo.clearBatch(testUser),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('Forced clearBatch failure')
        )),
      );

      expect(repo.clearBatchCount, 1);
    });
  });
}