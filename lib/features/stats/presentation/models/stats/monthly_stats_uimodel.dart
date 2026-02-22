import 'package:dawarich/features/stats/domain/stats/monthly_stats.dart';

class MonthlyStatsUiModel {
  final int january;
  final int february;
  final int march;
  final int april;
  final int may;
  final int june;
  final int july;
  final int august;
  final int september;
  final int october;
  final int november;
  final int december;

  const MonthlyStatsUiModel({
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

  static const MonthlyStatsUiModel zero = MonthlyStatsUiModel(
    january: 0,
    february: 0,
    march: 0,
    april: 0,
    may: 0,
    june: 0,
    july: 0,
    august: 0,
    september: 0,
    october: 0,
    november: 0,
    december: 0,
  );

  MonthlyStatsUiModel operator +(MonthlyStatsUiModel other) {
    return MonthlyStatsUiModel(
      january: january + other.january,
      february: february + other.february,
      march: march + other.march,
      april: april + other.april,
      may: may + other.may,
      june: june + other.june,
      july: july + other.july,
      august: august + other.august,
      september: september + other.september,
      october: october + other.october,
      november: november + other.november,
      december: december + other.december,
    );
  }

  static MonthlyStatsUiModel sum(Iterable<MonthlyStatsUiModel> items) {
    var total = zero;
    for (final m in items) {
      total = total + m;
    }
    return total;
  }
}
