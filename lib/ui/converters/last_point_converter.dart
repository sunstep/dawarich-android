import 'package:dawarich/domain/entities/local/last_point.dart';
import 'package:dawarich/ui/models/local/last_point_viewmodel.dart';

extension LastPointToViewModel on LastPoint {

  LastPointViewModel toViewModel() {
    return LastPointViewModel(
      rawTimestamp: timestamp,
      longitude: longitude,
      latitude: latitude,
    );
  }
}

// extension LastPointViewModelToEntity on LastPointViewModel {
//
//   LastPoint toEntity() => LastPoint(timestamp: timestamp, longitude: longitude, latitude: latitude);
// }