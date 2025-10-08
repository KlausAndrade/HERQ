# Drag & Drop Template Organization

## Overview
Implemented intuitive drag-and-drop functionality for moving workout templates into folders, providing a natural and effortless organization experience.

## Implementation Details

### Component Structure

#### 1. **DragTarget (Folder)**
```dart
DragTarget<String>(
  onAcceptWithDetails: (details) {
    _moveTemplate(details.data, folder.id);
  },
  builder: (context, candidateData, rejectedData) {
    final isDraggingOver = candidateData.isNotEmpty;
    // Visual feedback when dragging over
  }
)
```

**Features:**
- Accepts template ID as dragged data
- Provides visual feedback when template hovers over folder
- Highlights folder with colored background
- Elevated shadow effect during hover
- Border outline in folder's color

#### 2. **LongPressDraggable (Template)**
```dart
LongPressDraggable<String>(
  data: template.id,
  feedback: Material(...), // Dragging appearance
  childWhenDragging: Opacity(...), // Semi-transparent original
  child: _buildTemplateCardContent(...)
)
```

**Features:**
- Long-press to initiate drag
- Passes template ID as data
- Custom feedback widget (floating card)
- Semi-transparent original position (30% opacity)
- Smooth drag animation

### Visual Feedback

#### Dragging State:
1. **Template Being Dragged:**
   - Elevated Material widget with shadow
   - Primary container background color
   - Fixed width (300px) for consistency
   - Shows icon and truncated name

2. **Original Position:**
   - 30% opacity (semi-transparent)
   - Remains visible to show source location

3. **Target Folder:**
   - Background tint in folder color (20% opacity)
   - Increased elevation (1 → 8)
   - Colored border (2px width)
   - Smooth transition animation

### User Experience Flow

**Step-by-Step:**
1. User long-presses on any template card
2. Template lifts up with elevation shadow
3. Original position becomes semi-transparent
4. User drags template toward a folder
5. Folder highlights when template enters its bounds
6. User releases finger to drop
7. Template moves to folder immediately
8. Visual feedback (folder updates, template appears in folder)

**Edge Cases Handled:**
- Template already in target folder (no action)
- Dragging over empty space (no drop)
- Dragging over same folder (ignored)
- Quick tap vs long-press (tap still works for navigation)

## Technical Implementation

### Files Modified:
- `workout_templates_with_folders_screen.dart`
  - Added `LongPressDraggable` wrapper to template cards
  - Added `DragTarget` wrapper to folder sections
  - Created `_buildTemplateCardContent()` method for reusability
  - Enhanced folder visual feedback during drag

### Key Methods:

**_buildTemplateCard():**
```dart
Widget _buildTemplateCard(WorkoutTemplate template, String? folderId) {
  return LongPressDraggable<String>(
    data: template.id,
    feedback: // Floating card appearance
    childWhenDragging: // Semi-transparent original
    child: // Normal card content
  );
}
```

**_buildTemplateCardContent():**
```dart
Widget _buildTemplateCardContent(WorkoutTemplate template, String? folderId) {
  // Reusable card content for both normal and dragging states
  return Card(...);
}
```

**_buildFolderSection():**
```dart
Widget _buildFolderSection(TemplateFolder folder) {
  return DragTarget<String>(
    onAcceptWithDetails: (details) => _moveTemplate(details.data, folder.id),
    builder: (context, candidateData, rejectedData) {
      final isDraggingOver = candidateData.isNotEmpty;
      // Apply visual feedback based on drag state
    }
  );
}
```

## Visual Design

### Color System:
- **Folder Highlight:** Folder color at 20% opacity
- **Border Color:** Folder color at 100%
- **Feedback Widget:** Primary container color
- **Original Position:** 30% opacity

### Elevation:
- **Normal Folder:** elevation = 1
- **Dragging Over:** elevation = 8
- **Feedback Widget:** elevation = 8

### Animations:
- Smooth opacity transitions
- Elevation changes (implicit animations)
- Color tint transitions
- Border appearance

## Advantages Over Menu-Based

### Drag & Drop:
✅ More intuitive (natural gesture)
✅ Visual feedback throughout
✅ Faster for multiple templates
✅ See destination before dropping
✅ Works without edit mode

### Menu-Based:
✅ More precise for many folders
✅ Shows all folder names in list
✅ Works for accessibility

**Both methods are available** - users can choose their preferred workflow!

## Platform Considerations

### iOS/Android:
- Long-press gesture (standard mobile pattern)
- Touch-optimized drag areas
- Visual feedback during drag
- Haptic feedback (system-provided)

### Accessibility:
- Menu-based alternative still available
- Long-press detection customizable
- High contrast visual feedback
- Screen reader support via menu method

## Performance

### Optimizations:
- `LongPressDraggable` only creates feedback on demand
- `DragTarget` updates only on hover state change
- Minimal rebuilds (isolated state changes)
- Efficient template movement (single database update)

### Memory:
- Feedback widget created temporarily
- Released after drop/cancel
- No persistent drag state
- Lightweight Material widgets

## User Feedback

### Visual Cues:
1. **Initiation:** Template lifts with shadow
2. **Progress:** Semi-transparent original position
3. **Target:** Folder highlights in its color
4. **Success:** Template appears in folder
5. **Cancel:** Returns to original position

### Haptic Feedback:
- Long-press vibration (system)
- Drop confirmation (implicit)
- Smooth visual transitions

## Code Quality

### Maintainability:
- Clear separation of concerns
- Reusable `_buildTemplateCardContent()`
- Consistent naming conventions
- Well-commented drag logic

### Testability:
- Isolated drag handlers
- Pure functions for visual state
- Mockable database operations
- Widget test friendly

## Usage Examples

### Basic Drag & Drop:
```dart
// User action:
1. Long-press "Push Day" template
2. Drag over "3 Day Full Body" folder
3. Folder highlights in blue (folder color)
4. Release to drop
5. Template now in folder
```

### Multiple Templates:
```dart
// Organize routine:
1. Drag "Push Day" → "3 Day Full Body"
2. Drag "Pull Day" → "3 Day Full Body"
3. Drag "Legs Day" → "3 Day Full Body"
4. Folder shows count: 3
```

### Visual Flow:
```
Initial State:
📁 3 Day Full Body (0)
📄 Push Day [long-press here]
📄 Pull Day
📄 Legs Day

During Drag:
📁 3 Day Full Body (0) [HIGHLIGHTED IN BLUE]
📄 Push Day [30% OPACITY]  <-- Original position
   📄 Push Day [FLOATING]  <-- Dragging feedback

After Drop:
📁 3 Day Full Body (1) ▼
  └─ 📄 Push Day
📄 Pull Day
📄 Legs Day
```

## Testing Checklist

- [x] Long-press activates drag
- [x] Feedback widget appears
- [x] Original becomes semi-transparent
- [x] Folder highlights on hover
- [x] Drop moves template correctly
- [x] Template appears in folder
- [x] Count updates immediately
- [x] Cancel returns to original position
- [x] Works with all folder colors
- [x] Smooth animations throughout
- [x] No performance issues
- [x] Menu method still works

## Conclusion

The drag-and-drop implementation provides:
- **Intuitive UX**: Natural mobile gesture
- **Visual Feedback**: Clear drag state at all times
- **Efficient Organization**: Quick template movement
- **Dual Methods**: Drag or menu-based
- **Production Ready**: Tested and optimized

Users can now effortlessly organize their workout templates by simply dragging them into folders! 🎯
