
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';

final class GetTotalPagesUseCase {

  final IApiPointRepository _pointInterfaces;
  GetTotalPagesUseCase(this._pointInterfaces);

  Future<int> call(
      DateTime startDate, DateTime endDate, int perPage) async {
    return await _pointInterfaces.getTotalPages(startDate: startDate, endDate:  endDate, perPage:  perPage);
  }

}