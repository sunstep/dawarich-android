
import 'package:objectbox/objectbox.dart';

final class TrackEntity {

  @Id()
  int id;

  String trackId;
  DateTime startTimestamp;
  DateTime? endTimestamp;
  bool active;
  int userId;

  TrackEntity({
    this.id = 0,
    required this.trackId,
    required this.startTimestamp,
    this.endTimestamp,
    this.active = true,
    required this.userId,
  });

}