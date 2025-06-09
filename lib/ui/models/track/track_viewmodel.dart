class TrackViewModel {
  int id;
  String trackId;
  DateTime startTime;
  DateTime? endTime;
  bool active;
  int userId;

  TrackViewModel(
      {required this.id,
      required this.trackId,
      required this.startTime,
      this.endTime,
      required this.active,
      required this.userId});
}
