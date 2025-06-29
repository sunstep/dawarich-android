
import 'package:dawarich/data_contracts/interfaces/api_point_repository_interfaces.dart';
import 'package:dawarich/domain/entities/api/v1/points/request/dawarich_point_batch.dart';
import 'package:dawarich/features/tracking/application/converters/point/dawarich/dawarich_point_batch_converter.dart';
import 'package:option_result/option_result.dart';

final class PointUploadService {

  final IApiPointRepository _pointInterfaces;
  PointUploadService(this._pointInterfaces);



}