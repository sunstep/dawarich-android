import 'package:dawarich/ui/models/local/database/batch/local_point_viewmodel.dart';

class LocalPointBatchViewModel {

  final List<LocalPointViewModel> points;

  LocalPointBatchViewModel({required this.points});

  Map<String, dynamic> toJson() {
    return {
      'locations': points.map((point) => point.toJson()).toList(),
    };
  }
}