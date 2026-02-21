import 'package:dawarich/features/stats/presentation/widgets/peak_pill.dart';
import 'package:dawarich/features/stats/presentation/widgets/staggered_bar_fill.dart';
import 'package:flutter/material.dart';

class StatsBarRow extends StatelessWidget {
  final Widget label;
  final Widget value;

  final double fraction; // 0..1
  final Duration delay;

  /// Base color (typically theme primary) used for non-peak fills + glow accents.
  final Color baseColor;

  /// When true: applies the "peak" chrome + PeakPill.
  final bool isPeak;

  /// Optional: when true, slightly stronger fill for selected rows (yearly).
  final bool isSelected;

  /// Optional tap support (yearly). Null => non-tappable.
  final VoidCallback? onTap;

  /// Height of the row.
  final double height;

  const StatsBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.delay,
    required this.baseColor,
    required this.isPeak,
    this.isSelected = false,
    this.onTap,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12);

    final trackColor = cs.surface.withValues(alpha: 0.22);

    final fillAlpha = isPeak
        ? 0.58
        : (isSelected ? 0.46 : 0.34);

    final fillColor = baseColor.withValues(alpha: fillAlpha);

    final labelColor = isPeak
        ? cs.onSurface.withValues(alpha: 0.95)
        : cs.onSurface.withValues(alpha: 0.78);

    final valueColor = isPeak
        ? cs.onSurface.withValues(alpha: 0.95)
        : cs.onSurface.withValues(alpha: 0.78);

    final textWeight = isPeak
        ? FontWeight.w900
        : (isSelected ? FontWeight.w800 : FontWeight.w600);

    final content = ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          Container(height: height, color: trackColor),

          Positioned.fill(
            child: StaggeredBarFill(
              fraction: fraction,
              delay: delay,
              height: height,
              color: fillColor,
              borderRadius: radius,
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: textWeight,
                        color: labelColor,
                      ),
                      child: Row(
                        children: [
                          label,
                          if (isPeak) ...[
                            const SizedBox(width: 8),
                            const PeakPill(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isPeak ? FontWeight.w800 : null,
                      color: valueColor,
                    ),
                    child: value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final row = isPeak
        ? _peakChrome(
      borderRadius: radius,
      glowColor: baseColor,
      child: content,
    )
        : content;

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: row,
      ),
    );
  }

  Widget _peakChrome({
    required BorderRadius borderRadius,
    required Color glowColor,
    required Widget child,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.24),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.12),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),

        child,

        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}