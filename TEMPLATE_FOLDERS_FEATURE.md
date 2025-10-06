# Workout Template Folders Feature

## Overview
Implemented a collapsible folder system for organizing workout templates, allo### U3. **Template Management**
   - **Drag & Drop**: Long-press and drag templates into folders (primary method)
   - **Move to Folder**: Bottom sheet with folder list (alternative method)
   - **Remove from Folder**: Move to "Uncategorized"
   - Visual feedback during drag (semi-transparent template, highlighted folder)Flow Example:

**Creating a "3 Day Full Body" Folder:**
1. Navigate to Workout Templates
2. Tap FAB "New Folder"
3. Enter name: "3 Day Full Body"
4. Add description: "Split workout routine"
5. Select color (e.g., Blue)
6. Tap "Create"

**Adding Templates to Folder (Drag & Drop):**
1. Long-press on any template card
2. Drag the template over a folder
3. Folder highlights when you hover over it
4. Release to drop the template into the folder

**Alternative: Menu-Based Organization:**
1. Enable Edit mode (edit icon)
2. Tap "•••" on a template
3. Select folder from the list
4. Template moves to folderreate custom folders and group their templates hierarchically.

## Files Created/Modified

### New Files Created:
1. **`lib/src/core/models/template_folder.dart`**
   - New Drift table for storing template folders
   - Fields: id, name, description, sortOrder, color, isExpanded, createdAt, updatedAt

2. **`lib/src/providers/template_folder_provider.dart`**
   - `templateFoldersProvider` - Stream all folders
   - `templateFolderNotifierProvider` - Manage folder CRUD operations
   - `templatesInFolderProvider` - Get templates in a specific folder (or unfolderd)
   - Operations: createFolder, updateFolder, deleteFolder, moveTemplateToFolder, reorderFolders

3. **`lib/src/features/workouts/widgets/create_folder_dialog.dart`**
   - Dialog for creating and editing folders
   - Features:
     - Name validation (min 2 characters)
     - Optional description
     - Color picker (8 color options)
     - Visual feedback for selected color

4. **`lib/src/features/workout/presentation/screens/workout_templates_with_folders_screen.dart`**
   - New templates screen with folder support
   - Features:
     - Collapsible folder sections (ExpansionTile-like behavior)
     - Create, rename, delete folders
     - Move templates between folders
     - "Uncategorized" section for templates without folders
     - Edit mode for management
     - Color-coded folders
     - Template count badges

### Modified Files:
1. **`lib/src/core/models/workout_template.dart`**
   - Added `folderId` field (nullable) to reference TemplateFolders

2. **`lib/src/core/database/database.dart`**
   - Added TemplateFolders table import
   - Added table to @DriftDatabase annotation
   - Bumped schema version from 9 to 10
   - Added migration for version 10:
     - Creates templateFolders table
     - Adds folderId column to workoutTemplates

3. **`lib/src/core/routing/app_router.dart`**
   - Updated workout-templates route to use WorkoutTemplatesWithFoldersScreen

## Database Schema

### TemplateFolders Table:
```dart
class TemplateFolders extends Table {
  TextColumn get id => text()();                           // UUID
  TextColumn get name => text()();                         // Folder name
  TextColumn get description => text().nullable()();       // Optional description
  IntColumn get sortOrder => integer().withDefault(...)(); // Display order
  TextColumn get color => text().nullable()();             // Hex color (e.g., '0xFF2196F3')
  BoolColumn get isExpanded => boolean().withDefault(true)(); // UI state
  DateTimeColumn get createdAt => dateTime()...();
  DateTimeColumn get updatedAt => dateTime()...();
}
```

### WorkoutTemplates Table (Updated):
- Added: `TextColumn get folderId => text().nullable()();`
- Links template to a folder (null = uncategorized)

## Migration Strategy

### Schema Version 10:
```dart
if (to == 10) {
  // Create new table
  await migrator.createTable(templateFolders);
  
  // Add column to existing table
  await migrator.addColumn(workoutTemplates, workoutTemplates.folderId);
}
```

**Backward Compatibility:**
- Existing templates have `folderId = null` (appear in "Uncategorized")
- No data loss during migration
- Users can organize templates into folders at their convenience

## User Interface

### Main Screen Features:

1. **Folder Creation**
   - FAB: "New Folder" button
   - Edit mode: "Create Folder" button at top
   - Dialog with name, description, color picker

2. **Folder Display**
   - Color-coded folder icon
   - Folder name and description
   - Template count badge
   - Expand/collapse indicator
   - Actions menu (edit mode)

3. **Folder Management**
   - **Rename**: Edit name, description, color
   - **Delete**: Removes folder, moves templates to "Uncategorized"
   - **Expand/Collapse**: Show/hide templates in folder

4. **Template Management**
   - **Move to Folder**: Bottom sheet with folder list
   - **Remove from Folder**: Move to "Uncategorized"
   - Visual indicator of current folder

5. **Color Options** (8 choices):
   - Blue: `0xFF2196F3`
   - Green: `0xFF4CAF50`
   - Orange: `0xFFFF9800`
   - Pink: `0xFFE91E63`
   - Purple: `0xFF9C27B0`
   - Red: `0xFFF44336`
   - Cyan: `0xFF00BCD4`
   - Yellow: `0xFFFFEB3B`

### User Flow Example:

**Creating a "3 Day Full Body" Folder:**
1. Navigate to Workout Templates
2. Tap FAB "New Folder"
3. Enter name: "3 Day Full Body"
4. Add description: "Split workout routine"
5. Select color (e.g., Blue)
6. Tap "Create"

**Adding Templates to Folder:**
1. Enable Edit mode (edit icon)
2. Tap "•••" on a template
3. Select folder from list
4. Template moves to folder

**Organizing Templates:**
```
📁 3 Day Full Body (3 templates)
  ├─ Push Day Template
  ├─ Pull Day Template
  └─ Legs Day Template

📁 Cardio Programs (2 templates)
  ├─ HIIT Routine
  └─ Endurance Builder

Uncategorized (1 template)
  └─ Old Custom Workout
```

## Provider Architecture

### templateFoldersProvider
```dart
StreamProvider<List<TemplateFolder>>
```
- Watches all folders
- Auto-sorted by sortOrder
- Reactive updates

### templateFolderNotifierProvider
```dart
StateNotifierProvider<TemplateFolderNotifier, AsyncValue<void>>
```
- CRUD operations for folders
- State management for async operations
- Error handling

### templatesInFolderProvider
```dart
StreamProvider.family<List<WorkoutTemplate>, String?>
```
- Takes folderId parameter
- `null` = unfolderd templates
- Reactive to folder changes

## Key Features

✅ **Hierarchical Organization**
- Group related templates together
- Visual folder structure

✅ **Drag & Drop Interface** (NEW!)
- Long-press any template to start dragging
- Visual feedback during drag (semi-transparent)
- Folder highlights when template hovers over it
- Drop to add template to folder
- Smooth, intuitive interaction

✅ **Customization**
- Rename folders anytime
- Add descriptions
- Color-code for quick identification

✅ **Flexibility**
- Templates can be in folders or uncategorized
- Easy to move between folders
- Delete folders without losing templates

✅ **User Experience**
- Collapsible sections save space
- Edit mode prevents accidental changes
- Visual feedback (colors, icons, badges)
- Intuitive bottom sheet menus

✅ **Data Integrity**
- Deleting folders moves templates to "Uncategorized"
- No orphaned templates
- Proper migration handling

## Testing Checklist

- [x] Create new folder with name, description, color
- [x] Rename existing folder
- [x] Delete folder (templates move to uncategorized)
- [x] **Drag & drop template into folder** (NEW!)
- [x] Move template to folder via menu (alternative method)
- [x] Remove template from folder
- [x] Visual drag feedback (semi-transparent template)
- [x] Folder highlight on drag over
- [x] Expand/collapse folder sections
- [x] Display template count per folder
- [x] Show unfolderd templates
- [x] Edit mode toggle
- [x] Color picker visual feedback
- [x] Validation (min 2 char folder name)
- [x] Database migration (v9 → v10)
- [x] Navigation (back button, routes)

## Future Enhancements

### Potential Features:
1. **Nested Folders**
   - Subfolders within folders
   - Breadcrumb navigation

2. **~~Drag & Drop~~** ✅ **IMPLEMENTED!**
   - ~~Reorder templates within folder~~
   - ~~Drag templates between folders~~

3. **Folder Templates**
   - Share entire folder structure
   - Import/export folders

4. **Smart Folders**
   - Auto-organize by category
   - Filter by tags or difficulty

5. **Folder Statistics**
   - Total duration estimate
   - Completion tracking
   - Usage analytics

6. **Search & Filter**
   - Search across folders
   - Filter by folder color
   - Quick jump to folder

## Technical Notes

### Migration Safety:
- Uses `migrator.addColumn()` for non-breaking changes
- Default `folderId = null` for existing records
- No data loss during upgrade

### Performance:
- Efficient StreamProvider queries
- Separate providers for folders and templates
- Only load expanded folder contents

### State Management:
- Riverpod for reactive updates
- Family provider for folder-specific queries
- StateNotifier for CRUD operations

### Error Handling:
- AsyncValue for loading/error states
- SnackBar feedback for all operations
- Graceful degradation on errors

## Usage Example

```dart
// Create a folder
final folderNotifier = ref.read(templateFolderNotifierProvider.notifier);
await folderNotifier.createFolder(
  name: "3 Day Full Body",
  description: "Complete split routine",
  color: "0xFF2196F3",
);

// Move template to folder
await folderNotifier.moveTemplateToFolder(
  templateId: "push_day_template",
  folderId: "3_day_folder_id",
);

// Watch templates in folder
final templates = ref.watch(templatesInFolderProvider(folderId));
templates.when(
  data: (list) => /* Display templates */,
  loading: () => /* Loading state */,
  error: (e, st) => /* Error state */,
);
```

## Conclusion

The folder system provides a complete organizational solution for workout templates:
- **User-requested feature**: "I want a folder that I can rename and add templates"
- **Example satisfied**: "3 Day Full Body" folder with "Push", "Pull", "Legs" templates
- **Fully functional**: Create, rename, delete, organize
- **Production-ready**: Migrations, error handling, validation
- **Extensible**: Easy to add future enhancements
