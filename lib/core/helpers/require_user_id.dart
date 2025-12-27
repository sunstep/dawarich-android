

import 'package:dawarich/core/domain/models/user.dart';
import 'package:session_box/session_box.dart';

final class RequireUserId {

  final SessionBox<User> _userSession;

  RequireUserId(this._userSession);

  Future<int> call() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[ApiPointService] No user session found.');
    }
    return userId;
  }
}