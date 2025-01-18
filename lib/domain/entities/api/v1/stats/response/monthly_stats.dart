import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/stats/response/monthly_stats_dto.dart';

class MonthlyStats {

  int january;
  int february;
  int march;
  int april;
  int may;
  int june;
  int july;
  int august;
  int september;
  int october;
  int november;
  int december;

  MonthlyStats(
    this.january,
    this.february,
    this.march,
    this.april,
    this.may,
    this.june,
    this.july,
    this.august,
    this.september,
    this.october,
    this.december,
    this.november
  );

  factory MonthlyStats.fromDTO(MonthlyStatsDTO dto) {

    return MonthlyStats (
      dto.january,
      dto.february,
      dto.march,
      dto.april,
      dto.may,
      dto.june,
      dto.july,
      dto.august,
      dto.september,
      dto.october,
      dto.november,
      dto.december
    );
  }

}