import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dawarich/core/domain/models/point/dawarich/dawarich_point_batch.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_batch_converter.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/point/upload/dawarich_point_batch_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:option_result/result.dart';

final class UploadBatchUseCase {

  final IApiPointRepository _pointInterfaces;
  UploadBatchUseCase(this._pointInterfaces);

  Future<Result<(), String>> call(DawarichPointBatch batch) async {

    if (batch.points.isEmpty) {
      debugPrint('[Upload] No points to upload.');
      return Err("There are no points to upload.");
    }

    DawarichPointBatchDto uploadBatchDto = batch.toDto();


    final result = await _pointInterfaces.uploadBatch(uploadBatchDto);

    if (result case Err(value: final String error)) {
      return Err(error);
    }

    return Ok(());
  }

  Future<bool> _isOnline() async {

    List<ConnectivityResult> connectivity = await Connectivity()
        .checkConnectivity();

    return !connectivity.contains(ConnectivityResult.none);
  }
}