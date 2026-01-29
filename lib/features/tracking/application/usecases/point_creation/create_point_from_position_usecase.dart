import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/point/local/additional_point_data.dart';
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_geometry.dart';
import 'package:dawarich/core/domain/models/point/local/local_point_properties.dart';
import 'package:dawarich/features/batch/application/usecases/point_validator.dart';
import 'package:dawarich/features/tracking/application/converters/track_converter.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/repositories/i_track_repository.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/track_dto.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:dawarich/features/tracking/domain/models/track.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

final class CreatePointFromPositionUseCase {

  final IHardwareRepository _hardwareRepository;
  final IPointLocalRepository _localPointRepository;
  final ITrackRepository _trackRepository;
  final PointValidator _pointValidator;

  CreatePointFromPositionUseCase(this._hardwareRepository, this._localPointRepository, this._trackRepository, this._pointValidator);

  /// Creates a full point using a position object.
  Future<Result<LocalPoint, String>> call(
      Position position, DateTime timestamp, int userId) async {

    final AdditionalPointData additionalData =
    await _getAdditionalPointData(userId);

    LocalPoint point = _constructPoint(
      position,
      additionalData,
      userId,
      timestamp,
    );

    final Option<LastPoint> lastPoint = await _localPointRepository.getLastPoint(userId);
    Result<(), String> validationResult = await _pointValidator.validatePoint(point, lastPoint, userId);

    if (validationResult case Err(value: String validationError)) {
      return Err("Point validation did not pass: $validationError");
    }

    return Ok(point);
  }

  LocalPoint _constructPoint(
      Position position, AdditionalPointData additionalData, int userId, DateTime recordTimestamp) {
    final geometry = LocalPointGeometry(
        type: "Point",
        longitude: position.longitude,
        latitude: position.latitude
    );

    final properties = LocalPointProperties(
      batteryState: additionalData.batteryState,
      batteryLevel: additionalData.batteryLevel,
      wifi: additionalData.wifi,
      recordTimestamp: recordTimestamp,
      providerTimestamp: position.timestamp,
      horizontalAccuracy: position.accuracy,
      verticalAccuracy: position.altitudeAccuracy,
      altitude: position.altitude,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
      course: position.heading,
      courseAccuracy: position.headingAccuracy,
      trackId: additionalData.trackId,
      deviceId: additionalData.deviceId,
    );

    return LocalPoint(
        id: 0,
        type: "Feature",
        geometry: geometry,
        properties: properties,
        userId: userId,
        isUploaded: false);
  }

  Future<AdditionalPointData> _getAdditionalPointData(int userId) async {

    final Future<String> wifiF = _hardwareRepository.getWiFiStatus();
    final Future<String> batteryStateF = _hardwareRepository.getBatteryState();
    final Future<double> batteryLevelF = _hardwareRepository.getBatteryLevel();
    final Future<String> deviceIdF = _hardwareRepository.getDeviceModel();
    final Future<Option<TrackDto>> trackerIdResultF =
    _trackRepository.getActiveTrack(userId);

    final futureResults = await Future.wait([
      wifiF,
      batteryStateF,
      batteryLevelF,
      deviceIdF,
      trackerIdResultF,
    ]);

    final String wifi = futureResults[0] as String;
    final String batteryState = futureResults[1] as String;
    final double batteryLevel = futureResults[2] as double;
    final String deviceId = futureResults[3] as String;
    final Option<TrackDto> trackerIdResult = futureResults[4] as Option<TrackDto>;

    String? trackId;

    if (trackerIdResult case Some(value: TrackDto trackDto)) {
      Track track = trackDto.toEntity();
      trackId = track.trackId;
    }

    return AdditionalPointData(
        deviceId: deviceId,
        trackId: trackId,
        wifi: wifi,
        batteryState: batteryState,
        batteryLevel: batteryLevel);
  }


}