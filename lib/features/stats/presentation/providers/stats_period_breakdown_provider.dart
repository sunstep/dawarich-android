import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_period_breakdown_provider.g.dart';

@riverpod
class StatsBreakdownYear extends _$StatsBreakdownYear {
  @override
  int? build() => null;

  void setYear(int? year) {
    state = year;
  }

  void syncToPage(int? pageYear) {
    state = pageYear;
  }

  void clear() {
    state = null;
  }
}