import 'package:dawarich/features/stats/data/data_transfer_objects/stats/monthly_stats_dto.dart';

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

  MonthlyStats({
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december
  });

  factory MonthlyStats.fromDTO(MonthlyStatsDTO dto) {
    return MonthlyStats(
        january: dto.january,
        february: dto.february,
        march: dto.march,
        april: dto.april,
        may: dto.may,
        june: dto.june,
        july: dto.july,
        august: dto.august,
        september: dto.september,
        october: dto.october,
        november: dto.november,
        december: dto.december
    );
  }
}
