
import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/converters/point/last_point_converter.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';

final class StreamLastPointUseCase {

  final IPointLocalRepository _localPointRepository;
  final SessionBox<User> _userSession;

  StreamLastPointUseCase(this._localPointRepository, this._userSession);

  Future<Stream<Option<LastPoint>>> call() async {
    final int userId = await _requireUserId();

    return _localPointRepository
        .watchLastPoint(userId)
        .map((option) => option.map(
            (dto) => dto.toDomain())
    );
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