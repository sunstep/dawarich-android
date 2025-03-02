import 'package:dawarich/ui/models/api/v1/overland/batches/request/overland_point_viewmodel.dart';

class OverlandPointBatchViewModel {
  final List<OverlandPointViewModel> points;

  OverlandPointBatchViewModel({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }

}
