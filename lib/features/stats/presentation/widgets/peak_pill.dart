import 'package:flutter/material.dart';

class PeakPill extends StatelessWidget {
  const PeakPill({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: cs.onSurface.withValues(alpha: 0.14),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: cs.onSurface.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 4),
          Text(
            'Peak',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: cs.onSurface.withValues(alpha: 0.90),
            ),
          ),
        ],
      ),
    );
  }
}