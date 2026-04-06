import 'package:flutter/material.dart';

class StatsYearPickerRow extends StatelessWidget {
  final List<int> availableYears;
  final int? selectedYear;
  final ValueChanged<int?> onChanged;

  const StatsYearPickerRow({
    super.key,
    required this.availableYears,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Period',
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
                  for (final y in availableYears)
                    DropdownMenuItem<int?>(
                      value: y,
                      child: Text(y.toString()),
                    ),
                ],
                onChanged: (v) {
                  onChanged(v);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}