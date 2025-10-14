# Multi-Line Button Design Guide

## Problem
When button labels have two lines of text (common in localized apps), the icon and text can look misaligned, and buttons with different text lengths appear inconsistent in height.

## Solutions

### ✅ Option 1: Custom Row Layout (Recommended for Most Cases)

Replace `.icon()` constructors with custom `Row` layout:

```dart
// ❌ BAD: Misaligned with long text
OutlinedButton.icon(
  onPressed: onTap,
  icon: const Icon(Icons.add),
  label: const Text('Very Long Button Text That Wraps'),
)

// ✅ GOOD: Properly aligned
OutlinedButton(
  onPressed: onTap,
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(0, 48), // Consistent minimum height
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.add, size: 20),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          'Very Long Button Text That Wraps',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  ),
)
```

### ✅ Option 2: Use AdaptiveButton Widget

For consistency across the app, use the pre-built `AdaptiveButton`:

```dart
import 'package:gym_ai/src/core/widgets/adaptive_button.dart';

AdaptiveButton(
  onPressed: onTap,
  icon: Icons.add,
  label: 'Very Long Button Text That Wraps',
  type: ButtonType.outlined, // or .filled, .text
)
```

### ✅ Option 3: IntrinsicHeight for Button Rows

When buttons are in a row and need equal heights:

```dart
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () {},
          child: Text('Short', textAlign: TextAlign.center),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton(
          onPressed: () {},
          child: Text('Very Long\nTwo Lines', textAlign: TextAlign.center, maxLines: 2),
        ),
      ),
    ],
  ),
)
```

## Key Principles

### 1. **Always Use `Flexible` or `Expanded` for Multi-line Text**
Prevents overflow and allows text to wrap properly.

### 2. **Set `textAlign: TextAlign.center`**
Ensures text is centered, especially when wrapping to multiple lines.

### 3. **Use `maxLines: 2` and `overflow: TextOverflow.ellipsis`**
Prevents excessive wrapping and handles very long text gracefully.

### 4. **Set Consistent Button Heights**
Use `minimumSize` or fixed `height` to ensure buttons align properly.

```dart
// For single buttons
style: ButtonStyle(
  minimumSize: MaterialStateProperty.all(const Size(0, 48)),
)

// For buttons in rows (use IntrinsicHeight instead)
```

### 5. **Adjust Icon and Text Sizes**
For compact buttons (like "Add Set"), use smaller icons and text:

```dart
Icon(Icons.add, size: 18), // Instead of default 24
Text('Add Set', style: TextStyle(fontSize: 13)), // Instead of default 14
```

## Common Use Cases

### Dialog Action Buttons
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    TextButton(
      onPressed: onCancel,
      child: Text(S.of(context)!.cancel, textAlign: TextAlign.center),
    ),
    const SizedBox(width: 8),
    FilledButton(
      onPressed: onConfirm,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
      ),
      child: Text(S.of(context)!.confirm, textAlign: TextAlign.center, maxLines: 2),
    ),
  ],
)
```

### Bottom Sheet Actions
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: actions.map((action) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: OutlinedButton(
          onPressed: action.onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (action.icon != null) ...[
                Icon(action.icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  ),
)
```

### Quick Action Cards (Home Screen)
Already implemented with `IntrinsicHeight` + `ConstrainedBox`:

```dart
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: _QuickActionCard(...), // Has minHeight: 120 constraint
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _QuickActionCard(...),
      ),
    ],
  ),
)
```

## Testing Checklist

When implementing multi-line button fixes:

- [ ] Test with English (usually shorter text)
- [ ] Test with Portuguese (often longer text)
- [ ] Test with Spanish (medium length)
- [ ] Test on small screens (360px width)
- [ ] Test on large screens (tablet)
- [ ] Test in both light and dark themes
- [ ] Verify buttons in the same row have equal heights
- [ ] Verify text doesn't overflow or get cut off
- [ ] Verify icon and text are properly aligned

## Migration Guide

To update existing buttons:

1. Find all `.icon()` button constructors
2. Replace with custom `Row` layout or `AdaptiveButton`
3. Test with longest translation (usually Portuguese)
4. Adjust icon/text sizes if needed for compact layouts

```bash
# Find all icon buttons
grep -r "Button\.icon" lib/src/features

# Common patterns to replace:
# - OutlinedButton.icon → OutlinedButton with Row
# - FilledButton.icon → FilledButton with Row  
# - TextButton.icon → TextButton with Row
```

## Examples from GymAI

### ✅ Fixed: Add Set Button
```dart
// Before: Could misalign with long translations
OutlinedButton.icon(
  onPressed: onAddSet,
  icon: const Icon(Icons.add),
  label: const Text('Add Set'),
)

// After: Handles multi-line gracefully
OutlinedButton(
  onPressed: onAddSet,
  style: OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.add, size: 18),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          'Add Set',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    ],
  ),
)
```

### ✅ Fixed: Resume Workout Dialog
```dart
// All buttons use minimumSize and textAlign
FilledButton.icon(
  onPressed: onFinish,
  icon: Icon(isComplete ? Icons.celebration : Icons.check),
  label: Text(
    isComplete ? S.of(context)!.finalize : S.of(context)!.finish,
    textAlign: TextAlign.center,
  ),
  style: FilledButton.styleFrom(
    minimumSize: const Size(0, 48),
  ),
)
```

### ✅ Fixed: Home Screen Quick Actions
```dart
// All cards have consistent minimum height
ConstrainedBox(
  constraints: const BoxConstraints(minHeight: 120),
  child: Column(
    children: [
      Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  ),
)
```

## Resources

- Flutter Button Documentation: https://api.flutter.dev/flutter/material/ElevatedButton-class.html
- Material Design Button Guidelines: https://m3.material.io/components/buttons
- `AdaptiveButton` widget: `lib/src/core/widgets/adaptive_button.dart`

