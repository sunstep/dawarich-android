// import 'package:dawarich/application/converters/batch/api_batch_point_converter.dart';
// import 'package:dawarich/application/converters/batch/overland/overland_point_converter.dart';
// import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_dto.dart';
// import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/overland/batches/request/overland_point_batch_dto.dart';
// import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/points/request/dawarich_point_batch_dto.dart';
// import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point.dart';
// import 'package:dawarich/domain/entities/api/v1/overland/batches/request/overland_point_batch.dart';
//
// extension BatchConverter on ApiPointBatch {
//
//   ApiPointBatchDto toDto() {
//     List<OverlandPointDto> points = this.points
//         .map((point) => point.toDto())
//         .toList();
//     return ApiPointBatchDto(points: points);
//   }
// }
//
// extension BatchDtoConverter on ApiPointBatchDto {
//
//   ApiPointBatch toEntity() {
//     List<ApiBatchPoint> points = this.points
//         .map((pointDto) => pointDto.toEntity())
//         .toList();
//     return ApiPointBatch(points: points);
//   }
// }