import 'package:dawarich/features/stats/domain/monthly_stats.dart';

class MonthlyStatsViewModel {
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

  MonthlyStatsViewModel(
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
      this.november);

  factory MonthlyStatsViewModel.fromEntity(MonthlyStats entity) {
    return MonthlyStatsViewModel(
        entity.january,
        entity.february,
        entity.march,
        entity.april,
        entity.may,
        entity.june,
        entity.july,
        entity.august,
        entity.september,
        entity.october,
        entity.november,
        entity.december);
  }
}
