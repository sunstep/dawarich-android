class HealthDto {
  String? status;

  HealthDto(Map<String, dynamic> response) {
    status = response["status"];
  }
}
