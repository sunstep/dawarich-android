import 'dart:math';

import 'package:dawarich/features/stats/presentation/models/stats/monthly_stats_uimodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyDistanceCard extends StatefulWidget {
  final int? selectedYear;
  final List<int> availableYears;
  final ValueChanged<int?> onYearChanged;
  final MonthlyStatsUiModel monthly;

  const MonthlyDistanceCard({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.onYearChanged,
    required this.monthly,
  });

  @override
  State<MonthlyDistanceCard> createState() => _MonthlyDistanceCardState();
}

class _MonthlyDistanceCardState extends State<MonthlyDistanceCard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MonthlyDistanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedYear != widget.selectedYear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final nf = NumberFormat.decimalPattern(locale);

    final rows = _rows(context, widget.monthly, nf);
    final int maxValue = _maxValue(rows);

    final title = widget.selectedYear == null
        ? 'Monthly distance • All time'
        : 'Monthly distance • ${widget.selectedYear}';

    final barColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title row and picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: widget.selectedYear,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All time'),
                      ),
                      for (final y in widget.availableYears)
                        DropdownMenuItem<int?>(
                          value: y,
                          child: Text(y.toString()),
                        ),
                    ],
                    onChanged: widget.onYearChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Scrollable months list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.separated(
                  controller: _scrollController,
                  primary: false,
                  shrinkWrap: true,
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = rows[i];
                    final double fraction =
                    maxValue <= 0 ? 0.0 : (r.value / maxValue);

                    final isPeak = maxValue > 0 && r.value == maxValue;

                    return _MonthRow(
                      label: r.label,
                      valueText: r.valueText,
                      fraction: fraction,
                      color: barColor,
                      isPeak: isPeak,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _maxValue(List<_MonthRowModel> rows) {
    var maxValue = 0;
    for (final r in rows) {
      maxValue = max(maxValue, r.value);
    }
    return maxValue;
  }

  List<_MonthRowModel> _rows(
      BuildContext context,
      MonthlyStatsUiModel m,
      NumberFormat nf,
      ) {
    return [
      _MonthRowModel(_monthLabel(context, 1), m.january, '${nf.format(m.january)} km'),
      _MonthRowModel(_monthLabel(context, 2), m.february, '${nf.format(m.february)} km'),
      _MonthRowModel(_monthLabel(context, 3), m.march, '${nf.format(m.march)} km'),
      _MonthRowModel(_monthLabel(context, 4), m.april, '${nf.format(m.april)} km'),
      _MonthRowModel(_monthLabel(context, 5), m.may, '${nf.format(m.may)} km'),
      _MonthRowModel(_monthLabel(context, 6), m.june, '${nf.format(m.june)} km'),
      _MonthRowModel(_monthLabel(context, 7), m.july, '${nf.format(m.july)} km'),
      _MonthRowModel(_monthLabel(context, 8), m.august, '${nf.format(m.august)} km'),
      _MonthRowModel(_monthLabel(context, 9), m.september, '${nf.format(m.september)} km'),
      _MonthRowModel(_monthLabel(context, 10), m.october, '${nf.format(m.october)} km'),
      _MonthRowModel(_monthLabel(context, 11), m.november, '${nf.format(m.november)} km'),
      _MonthRowModel(_monthLabel(context, 12), m.december, '${nf.format(m.december)} km'),
    ];
  }

  String _monthLabel(BuildContext context, int month) {
    final locale = Localizations.localeOf(context).toString();
    final dt = DateTime(2000, month, 1);
    return DateFormat.MMM(locale).format(dt);
  }
}

final class _MonthRowModel {
  final String label;
  final int value;
  final String valueText;

  const _MonthRowModel(this.label, this.value, this.valueText);
}

class _MonthRow extends StatelessWidget {
  final String label;
  final String valueText;
  final double fraction; // 0..1
  final Color color;
  final bool isPeak;

  const _MonthRow({
    required this.label,
    required this.valueText,
    required this.fraction,
    required this.color,
    required this.isPeak,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor =
    Theme.of(context).colorScheme.surface.withValues(alpha: 0.25);

    final fillAlpha = isPeak ? 0.55 : 0.35;
    final fillColor = color.withValues(alpha: fillAlpha);

    final textWeight = isPeak ? FontWeight.w800 : FontWeight.w600;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(height: 44, color: trackColor),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(height: 44, color: fillColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
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
    );
  }
}