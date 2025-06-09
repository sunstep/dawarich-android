import 'package:dawarich/ui/models/api/v1/points/request/dawarich_point_viewmodel.dart';

class DawarichPointBatchViewModel {
  final List<DawarichPointViewModel> points;

  DawarichPointBatchViewModel({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}
