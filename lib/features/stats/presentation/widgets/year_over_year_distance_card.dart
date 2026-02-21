import 'dart:math';

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
    final locale = Localizations.localeOf(context).toString();
    final nf = NumberFormat.decimalPattern(locale);

    final years = _availableYears(stats);
    if (years.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show newest -> oldest (assuming your availableYears already does this)
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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = rows[i];

                final fraction = maxValue <= 0 ? 0.0 : (r.distance / maxValue);
                final isSelected = selectedYear != null && r.year == selectedYear;

                return _YearRow(
                  key: ValueKey('${selectedYear ?? 'all'}-${r.year}'),
                  year: r.year,
                  valueText: r.valueText,
                  fraction: fraction,
                  color: barColor,
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

class _YearRow extends StatelessWidget {
  final int year;
  final String valueText;
  final double fraction; // 0..1
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearRow({
    super.key,
    required this.year,
    required this.valueText,
    required this.fraction,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor =
    Theme.of(context).colorScheme.surface.withValues(alpha: 0.25);

    final fillAlpha = isSelected ? 0.55 : 0.35;
    final fillColor = color.withValues(alpha: fillAlpha);

    final textWeight = isSelected ? FontWeight.w800 : FontWeight.w600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(height: 44, color: trackColor),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: fraction.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutCubic,
                builder: (context, animatedFraction, _) {
                  return FractionallySizedBox(
                    widthFactor: animatedFraction,
                    child: Container(height: 44, color: fillColor),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          year.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: textWeight,
                          ),
                        ),
                      ),
                      Text(valueText),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}