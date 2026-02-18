import 'package:dawarich/features/stats/domain/stats/monthly_stats.dart';

class MonthlyStatsUiModel {
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

  MonthlyStatsUiModel({
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
    required this.december,
    required this.november
  });

  factory MonthlyStatsUiModel.fromDomain(MonthlyStats entity) {
    return MonthlyStatsUiModel(
        january: entity.january,
        february: entity.february,
        march: entity.march,
        april: entity.april,
        may: entity.may,
        june: entity.june,
        july: entity.july,
        august: entity.august,
        september: entity.september,
        october: entity.october,
        november: entity.november,
        december: entity.december
    );
  }
}
