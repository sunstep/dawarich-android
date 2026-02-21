import 'package:dawarich/features/stats/presentation/widgets/peak_pill.dart';
import 'package:dawarich/features/stats/presentation/widgets/staggered_bar_fill.dart';
import 'package:flutter/material.dart';

class StatsBarRow extends StatelessWidget {
  final Widget label;
  final Widget value;

  final double fraction; // 0..1
  final Duration delay;

  /// Accent used for the peak border. Example: const Color(0xFFFFB300)
  final Color baseColor;

  final bool isPeak;
  final bool isSelected;
  final VoidCallback? onTap;
  final double height;

  final double peakBorderWidth;

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
    this.peakBorderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final radius = BorderRadius.circular(12);

    final trackColor = isLight
        ? Colors.black.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.08);

    final fillBase = cs.onSurface;
    final normalFill = fillBase.withValues(alpha: isLight ? 0.10 : 0.18);
    final selectedFill = fillBase.withValues(alpha: isLight ? 0.14 : 0.26);
    final fillColor = isSelected ? selectedFill : normalFill;

    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurface.withValues(alpha: isLight ? 0.92 : 0.84),
      fontWeight: (isSelected || isPeak) ? FontWeight.w800 : FontWeight.w600,
    );

    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurface.withValues(alpha: isLight ? 0.92 : 0.78),
      fontWeight: isPeak ? FontWeight.w800 : null,
    );

    final peakBorder = Border.all(
      color: baseColor.withValues(alpha: isLight ? 0.95 : 0.90),
      width: peakBorderWidth,
    );

    final row = ClipRRect(
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
              borderRadius: BorderRadius.circular(0), // already clipped
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: labelStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(child: _ellipsizeIfText(label)),
                          if (isPeak) ...[
                            const SizedBox(width: 8),
                            const PeakPill(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  DefaultTextStyle.merge(
                    style: valueStyle,
                    child: value,
                  ),
                ],
              ),
            ),
          ),

          if (isPeak)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: peakBorder,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

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

  Widget _ellipsizeIfText(Widget w) {
    if (w is Text) {
      return Text(
        w.data ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return w;
  }
}