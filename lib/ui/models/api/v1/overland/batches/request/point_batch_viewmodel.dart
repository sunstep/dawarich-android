import 'package:dawarich/ui/models/api/v1/overland/batches/request/point_viewmodel.dart';

class PointBatchViewModel {
  final List<PointViewModel> points;

  PointBatchViewModel({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }

}
