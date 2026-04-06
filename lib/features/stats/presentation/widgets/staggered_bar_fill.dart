import 'dart:async';

import 'package:flutter/material.dart';

class StaggeredBarFill extends StatefulWidget {
  final double fraction;
  final Duration duration;
  final Curve curve;
  final Duration delay;
  final double height;
  final Color color;
  final BorderRadius borderRadius;

  final bool glow;
  final double glowBlur;
  final double glowSpread;
  final double glowAlpha;

  const StaggeredBarFill({
    super.key,
    required this.fraction,
    required this.color,
    required this.height,
    required this.borderRadius,
    this.duration = const Duration(milliseconds: 550),
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
    this.glow = false,
    this.glowBlur = 20,
    this.glowSpread = 0,
    this.glowAlpha = 0.40,
  });

  @override
  State<StaggeredBarFill> createState() => _StaggeredBarFillState();
}

class _StaggeredBarFillState extends State<StaggeredBarFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;

  int _runId = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _controller, curve: widget.curve);

    _restart();
  }

  @override
  void didUpdateWidget(covariant StaggeredBarFill oldWidget) {
    super.didUpdateWidget(oldWidget);

    final fractionChanged = oldWidget.fraction != widget.fraction;
    final delayChanged = oldWidget.delay != widget.delay;
    final durationChanged = oldWidget.duration != widget.duration;
    final curveChanged = oldWidget.curve != widget.curve;

    // Glow props should trigger rebuild, but not necessarily restart animation
    final glowChanged = oldWidget.glow != widget.glow ||
        oldWidget.glowAlpha != widget.glowAlpha ||
        oldWidget.glowBlur != widget.glowBlur ||
        oldWidget.glowSpread != widget.glowSpread ||
        oldWidget.color != widget.color;

    if (durationChanged) {
      _controller.duration = widget.duration;
    }
    if (curveChanged) {
      _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    }

    if (fractionChanged || delayChanged || durationChanged || curveChanged) {
      _restart();
      return;
    }

    if (glowChanged) {
      setState(() {}); // just redraw, don’t restart
    }
  }

  void _restart() {
    _timer?.cancel();

    _runId += 1;
    final currentRun = _runId;

    _controller.stop();
    _controller.value = 0.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.delay == Duration.zero) {
        _controller.forward();
        return;
      }

      _timer = Timer(widget.delay, () {
        if (!mounted) {
          return;
        }
        if (_runId != currentRun) {
          return; // cancelled/restarted
        }
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.fraction.clamp(0.0, 1.0);

    final glowShadows = widget.glow
        ? <BoxShadow>[
      BoxShadow(
        color: widget.color.withValues(alpha: widget.glowAlpha),
        blurRadius: widget.glowBlur,
        spreadRadius: widget.glowSpread,
      ),
    ]
        : const <BoxShadow>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _anim.value;
            final w = constraints.maxWidth * (target * t);

            // Tiny hack: avoid a "true" 0 width shadow edge-case
            final safeW = w <= 0.0 ? 0.0001 : w;

            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: safeW,
                height: widget.height,
                child: Stack(
                  clipBehavior: Clip.none, // ✅ allow glow to spill
                  children: [
                    // Glow layer (NOT clipped)
                    if (widget.glow)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: widget.borderRadius,
                            boxShadow: glowShadows,
                          ),
                        ),
                      ),

                    // Fill layer (clipped to radius)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: widget.borderRadius,
                        child: ColoredBox(color: widget.color),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}