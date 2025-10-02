class TrackDto {
  int id;
  String trackId;
  DateTime startTime;
  DateTime? endTime;
  bool active;
  int userId;

  TrackDto(
      {required this.id,
      required this.trackId,
      required this.startTime,
      required this.endTime,
      required this.active,
      required this.userId});

  void setEndTime(DateTime endTime) {
    this.endTime = endTime;
  }
}
