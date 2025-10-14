import 'package:flutter/material.dart';

import '../services/haptic_service.dart';
import '../theme/app_animations.dart';

/// Professional animated switch with smooth transitions and haptic feedback
class AnimatedSwitch extends StatefulWidget {
  const AnimatedSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.thumbIcon,
    this.width = 52,
    this.height = 32,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final IconData? thumbIcon;
  final double width;
  final double height;

  @override
  State<AnimatedSwitch> createState() => _AnimatedSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('value', value));
    properties.add(
        ObjectFlagProperty<ValueChanged<bool>?>.has('onChanged', onChanged));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('inactiveColor', inactiveColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DiagnosticsProperty<IconData?>('thumbIcon', thumbIcon));
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
  }
}

class _AnimatedSwitchState extends State<AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      HapticService.selectionClick();
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        widget.inactiveColor ?? theme.colorScheme.surfaceContainerHighest;
    final thumbColor = widget.thumbColor ?? theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: widget.onChanged != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            color: Color.lerp(inactiveColor, activeColor, _controller.value),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(
                  Colors.black12,
                  activeColor.withAlpha((0.4 * 255).round()),
                  _controller.value,
                )!,
                blurRadius: 8 * _controller.value,
                offset: Offset(0, 2 * _controller.value),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Animated thumb
              AnimatedAlign(
                duration: AppDurations.normal,
                curve: AppCurves.bounceOut,
                alignment:
                    widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    width: widget.height - 8,
                    height: widget.height - 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: thumbColor,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.thumbIcon != null
                        ? Icon(
                            widget.thumbIcon,
                            size: 12,
                            color: widget.value ? activeColor : inactiveColor,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Professional animated checkbox with checkmark animation and haptic feedback
class AnimatedCheckbox extends StatefulWidget {
  const AnimatedCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.activeColor,
    this.checkColor,
    this.size = 24,
    this.borderRadius = 6,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  final double borderRadius;

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('value', value));
    properties.add(
        ObjectFlagProperty<ValueChanged<bool>?>.has('onChanged', onChanged));
    properties.add(ColorProperty('activeColor', activeColor));
    properties.add(ColorProperty('checkColor', checkColor));
    properties.add(DoubleProperty('size', size));
    properties.add(DoubleProperty('borderRadius', borderRadius));
  }
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _checkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppCurves.bounceOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.85),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1),
        weight: 70,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      HapticService.selectionClick();
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final checkColor = widget.checkColor ?? theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: widget.onChanged != null ? _handleTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: Color.lerp(
                theme.colorScheme.surfaceContainerHighest,
                activeColor,
                _controller.value,
              ),
              border: Border.all(
                color: Color.lerp(
                  theme.colorScheme.outline,
                  activeColor,
                  _controller.value,
                )!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withOpacity(0.4 * _controller.value),
                  blurRadius: 8 * _controller.value,
                  offset: Offset(0, 2 * _controller.value),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _CheckmarkPainter(
                color: checkColor,
                progress: _checkAnimation.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({
    required this.color,
    required this.progress,
  });

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    final midX = size.width * 0.42;
    final midY = size.height * 0.68;
    final endX = size.width * 0.75;
    final endY = size.height * 0.32;

    // Draw checkmark in two segments
    if (progress <= 0.5) {
      // First segment (down stroke)
      final segmentProgress = progress * 2;
      path.moveTo(startX, startY);
      path.lineTo(
        startX + (midX - startX) * segmentProgress,
        startY + (midY - startY) * segmentProgress,
      );
    } else {
      // First segment complete
      path.moveTo(startX, startY);
      path.lineTo(midX, midY);

      // Second segment (up stroke)
      final segmentProgress = (progress - 0.5) * 2;
      path.lineTo(
        midX + (endX - midX) * segmentProgress,
        midY + (endY - midY) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
