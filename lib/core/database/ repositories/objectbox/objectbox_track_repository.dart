
import 'package:dawarich/core/database/objectbox/entities/track/track_entity.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';
import 'package:dawarich/data_contracts/interfaces/track_repository.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';

final class ObjectBoxTrackRepository implements ITrackRepository {

  final Store _database;
  ObjectBoxTrackRepository(this._database);

  @override
  Future<int> storeTrack(TrackDto track) async {

    try {
      Box<TrackEntity> trackBox = Box<TrackEntity>(_database);

      TrackEntity trackEntity = TrackEntity(trackId: track.trackId, startTimestamp: track.startTime);
      trackEntity.user.targetId = track.userId;

      return trackBox.put(trackEntity);
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to store track: $e');
      }

      rethrow;
    }



  }

  @override
  Future<Option<TrackDto>> getActiveTrack(int userId) async {

    try {

      Box<TrackEntity> trackBox = Box<TrackEntity>(_database);

      if (trackBox.isEmpty()) {
        return const None();
      }

      final query = trackBox.query(
          TrackEntity_.user.equals(userId)
              .and(TrackEntity_.active.equals(true))
      ).build()
      ..limit = 1;

      final entity = query.findFirst();

      if (entity == null) {
        return const None();
      }

      TrackDto track = TrackDto(
          id: entity.id,
          trackId: entity.trackId,
          startTime: entity.startTimestamp,
          endTime: entity.endTimestamp,
          active: entity.active,
          userId: userId
      );

      return Some(track);
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to get active track: $e');
      }

      rethrow;
    }
  }

  @override
  Future<void> stopTrack(TrackDto track) async {

    try {

      Box<TrackEntity> trackBox = Box<TrackEntity>(_database);

      final query = trackBox.query(
          TrackEntity_.user.equals(track.userId)
              .and(TrackEntity_.active.equals(true))
      ).build()
        ..limit = 1;

      final entity = query.findFirst();

      if (entity != null) {
        entity.active = false;
        entity.endTimestamp = track.endTime;
        trackBox.put(entity);
      }


    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to stop active track: $e');
      }

      rethrow;
    }
  }


}