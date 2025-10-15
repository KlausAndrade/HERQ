# GymAI Professional Components - Quick Start Guide 🚀

## Getting Started in 5 Minutes

This guide will help you quickly start using the new professional components in your screens.

## 1. Import Components

Add these imports at the top of your screen file:

```dart
// Core components
import 'package:herq/src/core/widgets/app_button.dart';
import 'package:herq/src/core/widgets/app_card.dart';
import 'package:herq/src/core/widgets/empty_state.dart';
import 'package:herq/src/core/widgets/skeleton_loader.dart';

// Micro-interactions
import 'package:herq/src/core/widgets/animated_fab.dart';
import 'package:herq/src/core/widgets/animated_switch.dart';
import 'package:herq/src/core/widgets/custom_refresh_indicator.dart';

// Services
import 'package:herq/src/core/services/snackbar_service.dart';
```

## 2. Replace Standard Widgets

### Buttons
```dart
// ❌ Before
ElevatedButton(
  onPressed: () => save(),
  child: Text('Save'),
)

// ✅ After
AppButton(
  onPressed: () => save(),
  variant: AppButtonVariant.primary,
  icon: Icons.save,
  child: Text('Save'),
)
```

### Cards
```dart
// ❌ Before
Card(
  child: ListTile(title: Text('Workout')),
)

// ✅ After (with hero animation!)
AppCard(
  variant: AppCardVariant.elevated,
  heroTag: 'workout-${id}',
  onTap: () => openWorkout(),
  child: ListTile(title: Text('Workout')),
)
```

### Toggles
```dart
// ❌ Before
Switch(
  value: isEnabled,
  onChanged: (v) => setState(() => isEnabled = v),
)

// ✅ After
AnimatedSwitch(
  value: isEnabled,
  onChanged: (v) => setState(() => isEnabled = v),
  thumbIcon: Icons.check, // Optional
)
```

### FAB
```dart
// ❌ Before
FloatingActionButton(
  onPressed: () => create(),
  child: Icon(Icons.add),
)

// ✅ After
AnimatedFAB(
  icon: Icons.add,
  onPressed: () => create(),
)
```

## 3. Add Loading States

### Replace CircularProgressIndicator
```dart
// ❌ Before
loading: () => Center(child: CircularProgressIndicator()),

// ✅ After
loading: () => ListView.builder(
  itemCount: 5,
  itemBuilder: (_, __) => SkeletonWorkoutCard(),
)
```

### Wrap Content
```dart
// ✅ For conditional loading
SkeletonLoader(
  isLoading: isLoading,
  child: YourContent(),
)
```

## 4. Add Empty States

```dart
// ❌ Before
if (items.isEmpty) {
  return Center(child: Text('No items'));
}

// ✅ After
if (items.isEmpty) {
  return EmptyState(
    title: 'No Items',
    subtitle: 'Get started by adding your first item',
    icon: Icons.inbox_outlined,
    actionText: 'Add Item',
    onAction: () => addItem(),
  );
}
```

## 5. Add Pull-to-Refresh

```dart
// Wrap your scrollable widget
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: CustomRefreshIndicator(
      onRefresh: () async {
        await refreshData();
      },
      child: ListView(...),
    ),
  );
}
```

## 6. Show Notifications

```dart
// ❌ Before
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Saved!')),
);

// ✅ After (with haptic feedback!)
SnackbarService.showSuccess(context, 'Saved!');
SnackbarService.showError(context, 'Failed to save');
SnackbarService.showWarning(context, 'Check internet');
SnackbarService.showInfo(context, 'New feature available');
```

## 7. Add Hero Animations

### List Screen
```dart
AppCard(
  heroTag: 'item-${item.id}', // Important: unique tag
  onTap: () => context.go('/item/${item.id}'),
  child: ItemContent(),
)
```

### Detail Screen
```dart
Hero(
  tag: 'item-${item.id}', // Same tag as list
  child: ItemImage(),
)
```

## Common Patterns

### Button with Loading State
```dart
AppButton(
  onPressed: isLoading ? null : () async {
    setState(() => isLoading = true);
    await save();
    setState(() => isLoading = false);
    SnackbarService.showSuccess(context, 'Saved!');
  },
  isLoading: isLoading,
  variant: AppButtonVariant.primary,
  child: Text('Save'),
)
```

### Async Screen with Skeleton Loading
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);
    
    return Scaffold(
      body: dataAsync.when(
        // Show skeletons while loading
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => SkeletonListTile(),
        ),
        // Show empty state if no data
        data: (data) => data.isEmpty
          ? EmptyState(
              title: 'No Data',
              subtitle: 'Add your first item',
              icon: Icons.inbox,
              actionText: 'Add',
              onAction: () => add(),
            )
          // Show actual content
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) => AppCard(
                heroTag: 'item-${data[i].id}',
                child: ItemTile(data[i]),
              ),
            ),
        // Show error state
        error: (e, _) => EmptyState(
          title: 'Error',
          subtitle: e.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
```

### Expandable FAB
```dart
ExpandableFAB(
  icon: Icons.add,
  children: [
    FABChild(
      icon: Icons.fitness_center,
      label: 'Add Exercise',
      onPressed: () => addExercise(),
    ),
    FABChild(
      icon: Icons.timer,
      label: 'Start Timer',
      onPressed: () => startTimer(),
    ),
  ],
)
```

## Component Cheat Sheet

| Old Widget | New Component | Benefits |
|------------|---------------|----------|
| `ElevatedButton` | `AppButton` | Variants, loading, haptics |
| `Card` | `AppCard` | Hero, animations, variants |
| `CircularProgressIndicator` | `SkeletonLoader` | Better UX, shows structure |
| `Text('No items')` | `EmptyState` | Actionable, animated |
| `FloatingActionButton` | `AnimatedFAB` | Animations, expandable |
| `Switch` | `AnimatedSwitch` | Smooth, haptic, icons |
| `Checkbox` | `AnimatedCheckbox` | Animated, haptic |
| `RefreshIndicator` | `CustomRefreshIndicator` | Customizable, themed |
| `SnackBar` | `SnackbarService` | Haptic, types, consistent |

## Testing Your Changes

### 1. Run the app
```bash
flutter run
```

### 2. Check animations
- All animations should be smooth (60fps)
- Haptic feedback on button presses
- Hero transitions between screens
- Skeleton loaders show before content

### 3. Test loading states
```dart
// Temporarily add delay to test skeletons
loading: () async {
  await Future.delayed(Duration(seconds: 2));
  return SkeletonWorkoutCard();
}
```

### 4. Verify hero animations
- Navigate between list and detail
- Should see smooth shared element transition
- No flashing or jumping

## Troubleshooting

### Hero tag conflicts
**Error**: "There are multiple heroes that share the same tag"
**Solution**: Ensure unique hero tags using IDs
```dart
heroTag: 'workout-${workout.id}' // ✅ Unique
heroTag: 'workout'                 // ❌ Not unique
```

### Animation jank
**Issue**: Animations are choppy
**Solutions**:
1. Wrap expensive widgets in `RepaintBoundary`
2. Use `const` constructors where possible
3. Check for expensive build methods in hot paths

### Imports not found
**Error**: "Target of URI doesn't exist"
**Solution**: Ensure correct relative path
```dart
import '../../../../core/widgets/app_button.dart'; // Adjust ../.. count
```

## Best Practices

1. ✅ **Always use hero tags** for items that navigate to details
2. ✅ **Show skeletons** instead of spinners for loading
3. ✅ **Use EmptyState** instead of plain text for empty screens
4. ✅ **Add haptic feedback** via components (automatic)
5. ✅ **Consistent button variants** - primary for main actions
6. ✅ **Pull-to-refresh** on all list screens
7. ✅ **AnimatedSwitch** for all toggles
8. ✅ **SnackbarService** for all notifications

## Next Steps

1. ✅ Update one screen at a time
2. ✅ Test hero animations work
3. ✅ Verify loading states look good
4. ✅ Check haptic feedback works
5. ✅ Review with team/users

## Need Help?

- **Examples**: See `lib/src/examples/polish_components_example.dart`
- **Full Guide**: Read `POLISH_COMPONENTS_GUIDE.md`
- **Implementation**: Check `PHASE3_COMPLETE.md`

---

**Happy Coding!** 🚀

Your app is now using world-class professional components!
