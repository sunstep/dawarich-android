import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/api_point_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/response/slim_api_point_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mock/repository/api_point_repository_mock.dart';

void main() {
  late ApiPointRepositoryMock repo;

  setUp(() {
    repo = ApiPointRepositoryMock()
      ..stubHeaders      = {'x-total-pages': '3'}
      ..stubPoints       = [
        ApiPointDTO({
          'latitude': '10.0',
          'longitude': '20.0',
          'timestamp': 111,
        }),
        ApiPointDTO({
          'latitude': '30.0',
          'longitude': '40.0',
          'timestamp': 222,
        }),
      ]
      ..stubSlimPoints   = [
        SlimApiPointDTO({
          'latitude': '1.1',
          'longitude': '2.2',
          'timestamp': 333,
        }),
        SlimApiPointDTO({
          'latitude': '3.3',
          'longitude': '4.4',
          'timestamp': 444,
        }),
      ]
      ..stubLastPoint    = ApiPointDTO({
        'latitude': '55.5',
        'longitude': '66.6',
        'timestamp': 555,
      });

    repo.shouldUploadFail       = false;
    repo.shouldFetchHeadersFail = false;
    repo.shouldFetchPointsFail  = false;
    repo.shouldFetchSlimFail    = false;
    repo.shouldFetchLastFail    = false;
    repo.shouldDeleteFail       = false;
  });

  group('uploadBatch', () {
    final batch = DawarichPointBatchDto(points: []);
    test('success → Ok, callCount+arg tracked', () async {
      repo.shouldUploadFail = false;
      final res = await repo.uploadBatch(batch);
      expect(res.isOk(), isTrue);
      expect(repo.uploadBatchCallCount, 1);
      expect(repo.lastUploadedBatch, same(batch));
    });
    test('failure → Err, callCount tracked', () async {
      repo.shouldUploadFail = true;
      final res = await repo.uploadBatch(batch);
      expect(res.isErr(), isTrue);
      expect(res.unwrapErr(), 'upload failed');
      expect(repo.uploadBatchCallCount, 1);
    });
  });

  group('fetchHeaders', () {
    final start = DateTime(2025,5,1), end = DateTime(2025,5,2);
    const perPage = 42;
    test('success → Some(headers), args tracked', () async {
      repo.shouldFetchHeadersFail = false;
      final opt = await repo.fetchHeaders(start, end, perPage);
      expect(opt.isSome(), isTrue);
      expect(opt.unwrap(), repo.stubHeaders);
      expect(repo.fetchHeadersCallCount, 1);
      expect(repo.lastFetchHeadersStart, start);
      expect(repo.lastFetchHeadersEnd, end);
      expect(repo.lastFetchHeadersPerPage, perPage);
    });
    test('failure → None, callCount tracked', () async {
      repo.shouldFetchHeadersFail = true;
      final opt = await repo.fetchHeaders(start, end, perPage);
      expect(opt.isNone(), isTrue);
      expect(repo.fetchHeadersCallCount, 1);
    });
  });

  group('fetchAllPoints', () {
    final start = DateTime(2025,6,1), end = DateTime(2025,6,2);
    const perPage = 5;
    test('success → Some(list), args tracked', () async {
      repo.shouldFetchPointsFail = false;
      final opt = await repo.fetchAllPoints(start, end, perPage);
      expect(opt.isSome(), isTrue);
      expect(opt.unwrap(), repo.stubPoints);
      expect(repo.fetchAllPointsCallCount, 1);
      expect(repo.lastFetchPointsStart, start);
      expect(repo.lastFetchPointsEnd, end);
      expect(repo.lastFetchPointsPerPage, perPage);
    });
    test('failure → None, callCount tracked', () async {
      repo.shouldFetchPointsFail = true;
      final opt = await repo.fetchAllPoints(start, end, perPage);
      expect(opt.isNone(), isTrue);
      expect(repo.fetchAllPointsCallCount, 1);
    });
  });

  group('fetchAllSlimPoints', () {
    final start = DateTime(2025,7,1), end = DateTime(2025,7,2);
    const perPage = 10;
    test('success → Some(list), args tracked', () async {
      repo.shouldFetchSlimFail = false;
      final opt = await repo.fetchAllSlimPoints(start, end, perPage);
      expect(opt.isSome(), isTrue);
      expect(opt.unwrap(), repo.stubSlimPoints);
      expect(repo.fetchAllSlimCallCount, 1);
      expect(repo.lastFetchSlimStart, start);
      expect(repo.lastFetchSlimEnd, end);
      expect(repo.lastFetchSlimPerPage, perPage);
    });
    test('failure → None, callCount tracked', () async {
      repo.shouldFetchSlimFail = true;
      final opt = await repo.fetchAllSlimPoints(start, end, perPage);
      expect(opt.isNone(), isTrue);
      expect(repo.fetchAllSlimCallCount, 1);
    });
  });

  group('getTotalPages', () {
    final start = DateTime(2025,8,1), end = DateTime(2025,8,2);
    const perPage = 7;
    test('success → parsed int, args tracked', () async {
      repo.shouldFetchHeadersFail = false;
      repo.stubHeaders = {'x-total-pages': '5'};
      final pages = await repo.getTotalPages(start, end, perPage);
      expect(pages, 5);
      expect(repo.getTotalPagesCallCount, 1);
      expect(repo.lastGetTotalPagesStart, start);
      expect(repo.lastGetTotalPagesEnd, end);
      expect(repo.lastGetTotalPagesPerPage, perPage);
    });
    test('failure → 0, callCount tracked', () async {
      repo.shouldFetchHeadersFail = true;
      final pages = await repo.getTotalPages(start, end, perPage);
      expect(pages, 0);
      expect(repo.getTotalPagesCallCount, 1);
    });
  });

  group('fetchLastPoint', () {
    test('success → Some(dto), callCount tracked', () async {
      repo.shouldFetchLastFail = false;
      final opt = await repo.fetchLastPoint();
      expect(opt.isSome(), isTrue);
      expect(opt.unwrap(), repo.stubLastPoint);
      expect(repo.fetchLastPointCallCount, 1);
    });
    test('flag‐failure → None, callCount tracked', () async {
      repo.shouldFetchLastFail = true;
      final opt = await repo.fetchLastPoint();
      expect(opt.isNone(), isTrue);
      expect(repo.fetchLastPointCallCount, 1);
    });
    test('null stub → None, callCount tracked', () async {
      repo.stubLastPoint = null;
      final opt = await repo.fetchLastPoint();
      expect(opt.isNone(), isTrue);
      expect(repo.fetchLastPointCallCount, 1);
    });
  });

  group('deletePoint', () {
    const pointId = 'XYZ';
    test('success → Ok, callCount+arg tracked', () async {
      repo.shouldDeleteFail = false;
      final res = await repo.deletePoint(pointId);
      expect(res.isOk(), isTrue);
      expect(res.unwrap(), equals(()));
      expect(repo.deletePointCallCount, 1);
      expect(repo.lastDeletedPointId, pointId);
    });
    test('failure → Err, callCount+arg tracked', () async {
      repo.shouldDeleteFail = true;
      final res = await repo.deletePoint(pointId);
      expect(res.isErr(), isTrue);
      expect(res.unwrapErr(), 'delete failed');
      expect(repo.deletePointCallCount, 1);
      expect(repo.lastDeletedPointId, pointId);
    });
  });
}