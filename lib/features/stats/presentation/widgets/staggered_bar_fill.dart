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

  const StaggeredBarFill({
    super.key,
    required this.fraction,
    required this.color,
    required this.height,
    required this.borderRadius,
    this.duration = const Duration(milliseconds: 550),
    this.curve = Curves.easeOutCubic,
    this.delay = Duration.zero,
  });

  @override
  State<StaggeredBarFill> createState() => _StaggeredBarFillState();
}

class _StaggeredBarFillState extends State<StaggeredBarFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _anim;

  int _runId = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _anim = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _restart();
  }

  @override
  void didUpdateWidget(covariant StaggeredBarFill oldWidget) {
    super.didUpdateWidget(oldWidget);

    final fractionChanged = oldWidget.fraction != widget.fraction;
    final delayChanged = oldWidget.delay != widget.delay;
    final durationChanged = oldWidget.duration != widget.duration;
    final curveChanged = oldWidget.curve != widget.curve;

    if (durationChanged) {
      _controller.duration = widget.duration;
    }

    if (curveChanged) {
      _anim = CurvedAnimation(parent: _controller, curve: widget.curve);
    }

    if (fractionChanged || delayChanged || durationChanged || curveChanged) {
      _restart();
    }
  }

  void _restart() {
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

      Timer(widget.delay, () {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.fraction.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _anim.value;
            final w = constraints.maxWidth * (target * t);

            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: w,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: widget.borderRadius,
                ),
              ),
            );
          },
        );
      },
    );
  }
}