
import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/timeline/application/converters/slim_point_converter.dart';
import 'package:option_result/option.dart';

final class GetLastPointOfDateUseCase {

  final IApiPointRepository _apiPointRepository;
  GetLastPointOfDateUseCase(this._apiPointRepository);

  Future<Option<SlimApiPoint>> call(DateTime selectedDate) async {
    final opt = await _apiPointRepository.fetchLastSlimPointForDay(selectedDate);
    if (opt case Some(value: final dto)) {
      return Some(dto.toDomain());
    }
    return const None();
  }
}
