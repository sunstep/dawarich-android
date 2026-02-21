import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyDistanceCard extends StatelessWidget {
  final int? year;
  final MonthlyStatsUiModel monthly;

  const MonthlyDistanceCard({
    super.key,
    required this.monthly,
    this.year,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final nf = NumberFormat.decimalPattern(locale);

    final rows = _rows(context, monthly, nf);

    final title = year == null
        ? 'Monthly distance • All time'
        : 'Monthly distance • $year';

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = rows[i];
                return _MonthRow(
                  label: r.label,
                  valueText: r.valueText,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_MonthRowModel> _rows(
      BuildContext context,
      MonthlyStatsUiModel m,
      NumberFormat nf,
      ) {
    return [
      _MonthRowModel(_monthLabel(context, 1), '${nf.format(m.january)} km'),
      _MonthRowModel(_monthLabel(context, 2), '${nf.format(m.february)} km'),
      _MonthRowModel(_monthLabel(context, 3), '${nf.format(m.march)} km'),
      _MonthRowModel(_monthLabel(context, 4), '${nf.format(m.april)} km'),
      _MonthRowModel(_monthLabel(context, 5), '${nf.format(m.may)} km'),
      _MonthRowModel(_monthLabel(context, 6), '${nf.format(m.june)} km'),
      _MonthRowModel(_monthLabel(context, 7), '${nf.format(m.july)} km'),
      _MonthRowModel(_monthLabel(context, 8), '${nf.format(m.august)} km'),
      _MonthRowModel(_monthLabel(context, 9), '${nf.format(m.september)} km'),
      _MonthRowModel(_monthLabel(context, 10), '${nf.format(m.october)} km'),
      _MonthRowModel(_monthLabel(context, 11), '${nf.format(m.november)} km'),
      _MonthRowModel(_monthLabel(context, 12), '${nf.format(m.december)} km'),
    ];
  }

  String _monthLabel(BuildContext context, int month) {
    final locale = Localizations.localeOf(context).toString();
    final dt = DateTime(2000, month, 1);
    return DateFormat.MMM(locale).format(dt); // Jan, Feb, ...
  }
}

final class _MonthRowModel {
  final String label;
  final String valueText;

  const _MonthRowModel(this.label, this.valueText);
}

class _MonthRow extends StatelessWidget {
  final String label;
  final String valueText;

  const _MonthRow({
    required this.label,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            valueText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}