import 'package:flutter/material.dart';

/// A button that gracefully handles multi-line text
///
/// This button automatically adjusts its layout when the label is long,
/// ensuring the icon and text remain properly aligned.
class AdaptiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;
  final ButtonStyle? style;
  final ButtonType type;

  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.style,
    this.type = ButtonType.outlined,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = style ?? _defaultStyle();

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 2),
        ],
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

  ButtonStyle _defaultStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(0, 48)),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

enum ButtonType {
  filled,
  outlined,
  text,
}
