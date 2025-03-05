
import 'package:intl/intl.dart';

class LastPointViewModel {
  final String rawTimestamp;
  String get formattedTimestamp {
    return DateFormat('dd MMM yyyy HH:mm:ss')
        .format(DateTime.parse(rawTimestamp)
        .toLocal()
    );
  }
  final double longitude;
  final double latitude;


  LastPointViewModel({
    required this.rawTimestamp,
    required this.longitude,
    required this.latitude,
  });
}
