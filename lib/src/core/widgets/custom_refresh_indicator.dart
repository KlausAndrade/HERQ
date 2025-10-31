import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import '../theme/app_animations.dart';

/// Professional pull-to-refresh indicator with smooth animations
class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.strokeWidth = 2.5,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: indicatorColor,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: strokeWidth,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<RefreshCallback>.has('onRefresh', onRefresh),
    );
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DoubleProperty('displacement', displacement));
    properties.add(DoubleProperty('edgeOffset', edgeOffset));
    properties.add(DoubleProperty('strokeWidth', strokeWidth));
  }
}

/// Advanced pull-to-refresh with custom animated indicator
class AnimatedRefreshIndicator extends StatefulWidget {
  const AnimatedRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
    this.color,
    this.backgroundColor,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final Color? color;
  final Color? backgroundColor;

  @override
  State<AnimatedRefreshIndicator> createState() =>
      _AnimatedRefreshIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<RefreshCallback>.has('onRefresh', onRefresh),
    );
    properties.add(ColorProperty('color', color));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
  }
}

class _AnimatedRefreshIndicatorState extends State<AnimatedRefreshIndicator> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = widget.color ?? theme.colorScheme.primary;
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surface;

    return RefreshIndicator.adaptive(
      onRefresh: widget.onRefresh,
      color: indicatorColor,
      backgroundColor: bgColor,
      child: widget.child,
    );
  }
}

/// Custom refresh indicator with workout-themed animation
class WorkoutRefreshIndicator extends StatefulWidget {
  const WorkoutRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
    this.color,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final Color? color;

  @override
  State<WorkoutRefreshIndicator> createState() =>
      _WorkoutRefreshIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<RefreshCallback>.has('onRefresh', onRefresh),
    );
    properties.add(ColorProperty('color', color));
  }
}

class _WorkoutRefreshIndicatorState extends State<WorkoutRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppDurations.slow, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _controller.repeat();
    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = widget.color ?? theme.colorScheme.primary;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: indicatorColor,
      backgroundColor: theme.colorScheme.surface,
      strokeWidth: 3,
      child: widget.child,
    );
  }
}

/// Dumbbell animated refresh indicator painter
class DumbbellRefreshPainter extends CustomPainter {
  const DumbbellRefreshPainter({
    required this.color,
    required this.progress,
    required this.rotation,
  });

  final Color color;
  final double progress;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final angle = rotation * 2 * math.pi;

    // Save canvas state
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    // Draw dumbbell bar
    final barStart = Offset(center.dx - 20, center.dy);
    final barEnd = Offset(center.dx + 20, center.dy);
    canvas.drawLine(barStart, barEnd, paint);

    // Draw left weight
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx - 25, center.dy),
        width: 10,
        height: 20,
      ),
      paint,
    );

    // Draw right weight
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + 25, center.dy),
        width: 10,
        height: 20,
      ),
      paint,
    );

    // Restore canvas
    canvas.restore();
  }

  @override
  bool shouldRepaint(DumbbellRefreshPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.rotation != rotation ||
      oldDelegate.color != color;
}
