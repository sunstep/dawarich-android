import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearOverYearDistanceCard extends StatelessWidget {
  final StatsUiModel stats;
  final int? selectedYear;
  final ValueChanged<int?> onYearSelected;

  const YearOverYearDistanceCard({
    super.key,
    required this.stats,
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final years = stats.yearlyStats.where((y) => y.year > 0).toList()
      ..sort((a, b) => b.year.compareTo(a.year));

    if (years.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxKm = years
        .map((y) => y.totalDistance)
        .fold<int>(0, (a, b) => a > b ? a : b);

    final locale = Localizations.localeOf(context).toString();
    final nf = NumberFormat.decimalPattern(locale);

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Year over year',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: years.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final y = years[i];
                final fraction =
                maxKm <= 0 ? 0.0 : (y.totalDistance / maxKm).clamp(0.0, 1.0);

                final isSelected = selectedYear == y.year;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onYearSelected(isSelected ? null : y.year),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: isSelected ? 0.35 : 0.25),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            y.year.toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Stack(
                              children: [
                                Container(
                                  height: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.10),
                                ),
                                FractionallySizedBox(
                                  widthFactor: fraction,
                                  child: Container(
                                    height: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${nf.format(y.totalDistance)} km'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}