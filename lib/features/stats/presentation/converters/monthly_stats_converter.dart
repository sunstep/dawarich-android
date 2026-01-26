
import 'package:dawarich/features/stats/domain/monthly_stats.dart';
import 'package:dawarich/features/stats/presentation/models/monthly_stats_uimodel.dart';

extension MonthlyStatsToViewModelConverter on MonthlyStats {
  MonthlyStatsUiModel toUiModel() {
    return MonthlyStatsUiModel(
      january: january,
      february: february,
      march: march,
      april: april,
      may: may,
      june: june,
      july: july,
      august: august,
      september: september,
      october: october,
      november: november,
      december: december
    );
  }
}

extension MonthlyStatsToDomainConverter on MonthlyStatsUiModel {
  MonthlyStats toDomain() {
    return MonthlyStats(
      january: january,
      february: february,
      march: march,
      april: april,
      may: may,
      june: june,
      july: july,
      august: august,
      september: september,
      october: october,
      november: november,
      december: december
    );
  }
}