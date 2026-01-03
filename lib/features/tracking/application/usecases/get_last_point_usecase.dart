
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/converters/point/last_point_converter.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';

final class GetLastPointUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox _userSession;

  GetLastPointUseCase(this._localPointRepository, this._userSession);

  Future<Option<LastPoint>> call() async {
    final int userId = await _requireUserId();

    Option<LastPoint> pointResult =
    await _localPointRepository.getLastPoint(userId);

    if (pointResult case Some(value: final LastPointDto lastPointDto)) {
      final LastPoint lastPoint = lastPointDto.toDomain();
      return Some(lastPoint);
    }

    return const None();
  }

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[TrackService] No user session found.');
    }
    return userId;
  }
}