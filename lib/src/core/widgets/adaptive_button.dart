import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A button that gracefully handles multi-line text
///
/// This button automatically adjusts its layout when the label is long,
/// ensuring the icon and text remain properly aligned.
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon,
    this.style,
    this.type = ButtonType.outlined,
  });
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;
  final ButtonStyle? style;
  final ButtonType type;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ?? _defaultStyle();

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 2)],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );

    switch (type) {
      case ButtonType.filled:
        return FilledButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: content,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: content,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: content,
        );
    }
  }

  ButtonStyle _defaultStyle() => ButtonStyle(
    minimumSize: WidgetStateProperty.all(const Size(0, 48)),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onPressed', onPressed),
    );
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<ButtonStyle?>('style', style));
    properties.add(EnumProperty<ButtonType>('type', type));
  }
}

enum ButtonType { filled, outlined, text }
