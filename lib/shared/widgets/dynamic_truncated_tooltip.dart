import 'package:flutter/material.dart';

class DynamicTruncatedTooltip extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DynamicTruncatedTooltip({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(builder: (context, constraints) {
      // Use a TextPainter to measure the text width
      final fullSpan = TextSpan(text: text, style: effectiveStyle);
      final fullPainter = TextPainter(
        text: fullSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      fullPainter.layout(maxWidth: constraints.maxWidth);

      // If the full text fits, just display it.
      if (!fullPainter.didExceedMaxLines) {
        return Tooltip(
          message: text,
          child: Text(text, style: effectiveStyle, maxLines: 1),
        );
      }

      // Otherwise, we need to figure out the maximum number of characters that fit.
      int low = 0;
      int high = text.length;

      while (low < high) {
        int mid = (low + high + 1) ~/ 2;
        final truncated = "${text.substring(0, mid)}...";
        final span = TextSpan(text: truncated, style: effectiveStyle);
        final painter = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          maxLines: 1,
        );
        painter.layout(maxWidth: constraints.maxWidth);
        if (painter.didExceedMaxLines) {
          high = mid - 1;
        } else {
          low = mid;
        }
      }

      final resultText =
          (low < text.length) ? "${text.substring(0, low)}..." : text;
      return Tooltip(
        message: text,
        child: Text(resultText,
            style: effectiveStyle, maxLines: 1, overflow: TextOverflow.clip),
      );
    });
  }
}
