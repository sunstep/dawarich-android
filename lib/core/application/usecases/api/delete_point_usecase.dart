import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:option_result/result.dart';

final class DeletePointUseCase {

  final IApiPointRepository _pointInterfaces;
  DeletePointUseCase(this._pointInterfaces);

  Future<bool> call(String point) async {

    Result<(), String> result = await _pointInterfaces.deletePoint(point);

    if (result case Ok(value: ())) {
      return true;
    } else if (result case Err(value: final String error)) {
      debugPrint("[ApiPointService] Error deleting point: $error");
    }

    return false;
  }


}