
import 'package:dawarich/features/stats/domain/monthly_stats.dart';
import 'package:dawarich/features/stats/presentation/models/monthly_stats_viewmodel.dart';

extension MonthlyStatsToViewModelConverter on MonthlyStats {
  MonthlyStatsViewModel toViewModel() {
    return MonthlyStatsViewModel(
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

extension MonthlyStatsToDomainConverter on MonthlyStatsViewModel {
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