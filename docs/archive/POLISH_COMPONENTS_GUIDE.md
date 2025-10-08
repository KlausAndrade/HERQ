# Professional Polish Components - Quick Reference

## 🎨 Phase 3 Components (NEW)

### AnimatedFAB
Professional floating action button with smooth animations.

```dart
// Basic FAB
AnimatedFAB(
  icon: Icons.add,
  onPressed: () {},
)

// Extended FAB
AnimatedFAB(
  icon: Icons.play_arrow,
  label: 'Start Workout',
  extended: true,
  onPressed: () {},
)

// Expandable FAB with children
ExpandableFAB(
  icon: Icons.add,
  distance: 70,
  children: [
    FABChild(
      icon: Icons.fitness_center,
      label: 'Add Exercise',
      onPressed: () {},
    ),
    FABChild(
      icon: Icons.timer,
      label: 'Start Timer',
      onPressed: () {},
    ),
  ],
)
```

**Features:**
- Scale + rotation animations on press
- Automatic pulse animation for attention
- Haptic feedback
- Gradient support
- ExpandableFAB with smooth child expansion

---

### AnimatedSwitch
Professional toggle switch with smooth animations.

```dart
AnimatedSwitch(
  value: isEnabled,
  onChanged: (value) {
    setState(() => isEnabled = value);
  },
  thumbIcon: Icons.notifications, // Optional
  activeColor: Colors.green,      // Optional
)
```

**Features:**
- Smooth thumb slide with bounce effect
- Scale animation on toggle
- Color transitions
- Shadow animations
- Optional thumb icon
- Haptic feedback

---

### AnimatedCheckbox
Professional checkbox with animated checkmark.

```dart
AnimatedCheckbox(
  value: isChecked,
  onChanged: (value) {
    setState(() => isChecked = value);
  },
  size: 24,          // Optional
  borderRadius: 6,   // Optional
)
```

**Features:**
- Two-stage checkmark animation (down → up stroke)
- Scale feedback on toggle
- Glow effect when checked
- Custom border radius
- Haptic feedback

---

### CustomRefreshIndicator
Professional pull-to-refresh indicators.

```dart
// Simple refresh indicator
CustomRefreshIndicator(
  onRefresh: () async {
    await loadData();
  },
  child: ListView(...),
)

// Adaptive refresh indicator
AnimatedRefreshIndicator(
  onRefresh: () async {
    await loadData();
  },
  child: ListView(...),
)

// Workout-themed refresh
WorkoutRefreshIndicator(
  onRefresh: () async {
    await loadData();
  },
  child: ListView(...),
)
```

**Features:**
- Customizable colors and styling
- Adaptive platform behavior
- Workout-themed animations
- Smooth refresh animations

---

## 🎯 Phase 2 Components

### AppButton
Professional button component with 5 variants.

```dart
// Primary button
AppButton(
  onPressed: () {},
  variant: AppButtonVariant.primary,
  icon: Icons.play_arrow,
  child: Text('Start'),
)

// With loading state
AppButton(
  onPressed: () {},
  isLoading: true,
  child: Text('Loading...'),
)

// With gradient
AppButton(
  onPressed: () {},
  gradient: AppTheme.primaryGradient,
  child: Text('Gradient Button'),
)
```

**Variants:** `primary`, `secondary`, `outline`, `text`, `danger`  
**Sizes:** `small`, `medium`, `large`  
**Features:** Loading states, haptic feedback, press animations, gradients

---

### AppCard
Versatile card component with 4 variants.

```dart
// Elevated card
AppCard(
  variant: AppCardVariant.elevated,
  onTap: () {},
  child: YourContent(),
)

// Card with gradient
AppCard(
  gradient: AppTheme.primaryGradient,
  child: YourContent(),
)

// Hero-enabled card
AppCard(
  heroTag: 'workout-123',
  child: YourContent(),
)
```

**Variants:** `elevated`, `flat`, `outlined`, `glass`  
**Features:** Hero animations, touch feedback, gradients, elevation animations

---

### SkeletonLoader
Professional loading states with shimmer.

```dart
// Custom skeleton
SkeletonLoader(
  isLoading: isLoading,
  child: YourContent(),
)

// Pre-built skeletons
SkeletonWorkoutCard()
SkeletonListTile()
SkeletonAvatar()
SkeletonText(width: 100)
```

**Features:** 1.5s shimmer animation, adaptive colors, pre-built components

---

### EmptyState
Engaging empty state screens.

```dart
EmptyState(
  title: 'No Workouts',
  subtitle: 'Start your first workout',
  icon: Icons.fitness_center,
  actionText: 'Create Workout',
  onAction: () => goToCreate(),
)
```

**Features:** Staggered entrance animation, pulsing CTA, custom icons

---

### SnackbarService
Professional notifications with haptic feedback.

```dart
// Quick methods
SnackbarService.showSuccess(context, 'Saved!');
SnackbarService.showError(context, 'Failed');
SnackbarService.showWarning(context, 'Warning');
SnackbarService.showInfo(context, 'Info');

// With action
SnackbarService.show(
  context,
  message: 'Workout saved',
  type: SnackbarType.success,
  actionLabel: 'View',
  onAction: () {},
);
```

**Types:** `success`, `error`, `warning`, `info`  
**Features:** Haptic patterns, action buttons, auto-dismiss

---

## 🎬 Navigation & Transitions

### Page Transitions
Professional navigation animations in go_router.

```dart
// In app_router.dart
GoRoute(
  path: '/workout',
  pageBuilder: (context, state) => AppPageTransitions.slideRight(
    context, 
    state, 
    WorkoutScreen(),
  ),
)
```

**Available Transitions:**
- `slideRight` - Default forward navigation
- `slideUp` - Bottom sheets, modals
- `fade` - Subtle transitions, tab changes
- `scale` - Dialogs, popups
- `sharedAxis` - Material Design 3 style

---

## 📋 Best Practices

### 1. Haptic Feedback
All interactive components automatically include haptic feedback:
- `lightImpact` - Buttons, cards, switches
- `mediumImpact` - FAB expansion, important actions
- `selectionClick` - Toggles, checkboxes

### 2. Loading States
Always provide loading feedback:
```dart
// Use skeleton loaders
SkeletonLoader(
  isLoading: isLoading,
  child: content,
)

// Use button loading states
AppButton(
  isLoading: isProcessing,
  onPressed: handleAction,
  child: Text('Save'),
)
```

### 3. Empty States
Replace generic messages with EmptyState:
```dart
if (items.isEmpty) {
  return EmptyState(
    title: 'No Items',
    subtitle: 'Get started by adding your first item',
    actionText: 'Add Item',
    onAction: () => addItem(),
  );
}
```

### 4. Consistent Animations
Use AppDurations and AppCurves:
```dart
AnimationController(
  duration: AppDurations.normal,
  curve: AppCurves.smooth,
)
```

---

## 🚀 Quick Start

### 1. Import Components
```dart
import 'package:gym_ai/src/core/widgets/app_button.dart';
import 'package:gym_ai/src/core/widgets/app_card.dart';
import 'package:gym_ai/src/core/widgets/animated_fab.dart';
import 'package:gym_ai/src/core/services/snackbar_service.dart';
```

### 2. Replace Standard Widgets
```dart
// Before
ElevatedButton(...)

// After
AppButton(...)
```

### 3. Add Loading States
```dart
// Before
if (isLoading) CircularProgressIndicator()

// After
SkeletonLoader(isLoading: isLoading, child: content)
```

### 4. Enhance Feedback
```dart
// Before
ScaffoldMessenger.of(context).showSnackBar(...)

// After
SnackbarService.showSuccess(context, 'Done!')
```

---

## 📚 Examples

See complete usage examples in:
- `lib/src/examples/polish_components_example.dart`

Run the example:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => PolishComponentsExample()),
);
```

---

## ✅ Component Checklist

When building a screen, use this checklist:

- [ ] Replace buttons with `AppButton`
- [ ] Use `AppCard` for containers
- [ ] Add `SkeletonLoader` for async content
- [ ] Show `EmptyState` when data is empty
- [ ] Use `SnackbarService` for notifications
- [ ] Add `AnimatedFAB` for primary actions
- [ ] Wrap lists in `CustomRefreshIndicator`
- [ ] Use `AnimatedSwitch`/`AnimatedCheckbox` for toggles
- [ ] Apply custom page transitions in router

---

**Last Updated:** Phase 3 Implementation  
**Components:** 11 professional components  
**Status:** Ready for production use
