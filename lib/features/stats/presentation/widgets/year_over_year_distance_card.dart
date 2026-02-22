import 'dart:math';

import 'package:dawarich/features/stats/presentation/models/stats/stats_uimodel.dart';
import 'package:dawarich/features/stats/presentation/widgets/stats_bar_row.dart';
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
    final locale = Localizations.localeOf(context).toString();
    final nf = NumberFormat.decimalPattern(locale);

    final years = _availableYears(stats);
    if (years.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = _rows(stats, years, nf);

    final maxValue = _maxDistance(rows);
    final barColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Year over year',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: selectedYear,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All time'),
                      ),
                      for (final y in years)
                        DropdownMenuItem<int?>(
                          value: y,
                          child: Text(y.toString()),
                        ),
                    ],
                    onChanged: onYearSelected,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (_, i) {
                final r = rows[i];

                final fraction = maxValue <= 0 ? 0.0 : (r.distance / maxValue);
                final isSelected = selectedYear != null && r.year == selectedYear;

                final isPeak = maxValue > 0 && r.distance == maxValue;

                return StatsBarRow(
                  key: ValueKey('${selectedYear ?? 'all'}-${r.year}'),
                  label: Text(r.year.toString()),
                  value: Text(r.valueText),
                  fraction: fraction,
                  delay: Duration(milliseconds: 45 * i),
                  baseColor: barColor,
                  isPeak: isPeak,
                  isSelected: isSelected,
                  onTap: () => onYearSelected(r.year),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<int> _availableYears(StatsUiModel stats) {
    final years = <int>[];
    for (final y in stats.yearlyStats) {
      if (y.year > 0 && years.contains(y.year) == false) {
        years.add(y.year);
      }
    }
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<_YearRowModel> _rows(
      StatsUiModel stats,
      List<int> years,
      NumberFormat nf,
      ) {
    // Map year -> distance quickly
    final map = <int, int>{};
    for (final y in stats.yearlyStats) {
      map[y.year] = y.totalDistance;
    }

    final out = <_YearRowModel>[];
    for (final year in years) {
      final distance = map[year] ?? 0;
      out.add(_YearRowModel(year, distance, '${nf.format(distance)} km'));
    }
    return out;
  }

  int _maxDistance(List<_YearRowModel> rows) {
    var maxValue = 0;
    for (final r in rows) {
      maxValue = max(maxValue, r.distance);
    }
    return maxValue;
  }
}

final class _YearRowModel {
  final int year;
  final int distance;
  final String valueText;

  const _YearRowModel(this.year, this.distance, this.valueText);
}