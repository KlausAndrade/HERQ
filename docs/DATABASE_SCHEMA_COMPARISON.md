# Database Schema Comparison: SQLite vs Supabase

## Overview
This document compares the SQLite (Drift) and Supabase database schemas to ensure they're compatible for data migration.

## ✅ EXERCISES TABLE

### SQLite (Drift) Schema
```dart
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get primaryMuscleGroup => text()();
  TextColumn get secondaryMuscleGroups => text().map(const StringListConverter())();
  TextColumn get equipment => text()();
  TextColumn get instructions => text()();
  TextColumn get tags => text().map(const StringListConverter())();
  TextColumn get aliases => text().map(const StringListConverter()).nullable()();
  BoolColumn get isBodyweight => boolean().withDefault(const Constant(false))();
  TextColumn get exerciseType => text().withDefault(const Constant('reps'))();
  TextColumn get category => text().withDefault(const Constant('strength'))();
  TextColumn get parentExerciseId => text().nullable()();
  TextColumn get variantType => text().nullable()();
  TextColumn get difficulty => text().withDefault(const Constant('intermediate'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

### Supabase Schema
```sql
CREATE TABLE exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  type TEXT DEFAULT 'compound',
  difficulty TEXT DEFAULT 'intermediate',
  equipment TEXT[] DEFAULT '{}',
  primary_muscle_group TEXT NOT NULL,
  secondary_muscle_groups TEXT[] DEFAULT '{}',
  instructions TEXT,
  aliases TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  is_bodyweight BOOLEAN DEFAULT false,
  exercise_type TEXT DEFAULT 'weight_reps',
  parent_exercise_id TEXT REFERENCES exercises(id) ON DELETE SET NULL,
  variant_type TEXT,
  variant_detail TEXT,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 🔴 SCHEMA MISMATCHES FOUND:

1. **Column Name Differences:**
   - SQLite: `primaryMuscleGroup` → Supabase: `primary_muscle_group`
   - SQLite: `secondaryMuscleGroups` → Supabase: `secondary_muscle_groups`
   - SQLite: `parentExerciseId` → Supabase: `parent_exercise_id`
   - SQLite: `variantType` → Supabase: `variant_type`
   - SQLite: `exerciseType` → Supabase: `exercise_type`
   - SQLite: `isBodyweight` → Supabase: `is_bodyweight`
   - SQLite: `createdAt` → Supabase: `created_at`
   - SQLite: `updatedAt` → Supabase: `updated_at`

2. **Missing Columns in Supabase:**
   - `variant_detail` (exists in Supabase but not in SQLite)

3. **Data Type Differences:**
   - SQLite: `userId` is `TEXT` → Supabase: `user_id` is `UUID`
   - SQLite: Arrays stored as JSON strings → Supabase: Native PostgreSQL arrays

## ✅ TEMPLATE_FOLDERS TABLE

### SQLite (Drift) Schema
```dart
class TemplateFolders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get color => text().nullable()();
  BoolColumn get isExpanded => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

### Supabase Schema
```sql
CREATE TABLE template_folders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  sort_order INTEGER DEFAULT 0 NOT NULL,
  is_expanded BOOLEAN DEFAULT TRUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

### 🔴 SCHEMA MISMATCHES FOUND:

1. **Column Name Differences:**
   - SQLite: `sortOrder` → Supabase: `sort_order`
   - SQLite: `isExpanded` → Supabase: `is_expanded`
   - SQLite: `createdAt` → Supabase: `created_at`
   - SQLite: `updatedAt` → Supabase: `updated_at`

2. **Missing Columns:**
   - SQLite: No `user_id` → Supabase: Has `user_id UUID NOT NULL`

3. **Data Type Differences:**
   - SQLite: `id` is `TEXT` → Supabase: `id` is `UUID`

## ✅ WORKOUT_TEMPLATES TABLE

### SQLite (Drift) Schema
```dart
class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('Custom'))();
  TextColumn get folderId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get exerciseIds => text().map(const StringListConverter()).withDefault(const Constant(''))();
  TextColumn get tags => text().map(const StringListConverter())();
  IntColumn get estimatedDurationMinutes => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

### Supabase Schema
```sql
CREATE TABLE workout_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT DEFAULT 'Custom' NOT NULL,
  folder_id UUID,
  exercise_ids TEXT[] NOT NULL DEFAULT '{}',
  estimated_duration INTEGER,
  sort_order INTEGER DEFAULT 0 NOT NULL,
  tags TEXT[] DEFAULT '{}',
  is_default BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
```

### 🔴 SCHEMA MISMATCHES FOUND:

1. **Column Name Differences:**
   - SQLite: `userId` → Supabase: `user_id`
   - SQLite: `folderId` → Supabase: `folder_id`
   - SQLite: `sortOrder` → Supabase: `sort_order`
   - SQLite: `exerciseIds` → Supabase: `exercise_ids`
   - SQLite: `estimatedDurationMinutes` → Supabase: `estimated_duration`
   - SQLite: `isDefault` → Supabase: `is_default`
   - SQLite: `createdAt` → Supabase: `created_at`
   - SQLite: `updatedAt` → Supabase: `updated_at`

2. **Data Type Differences:**
   - SQLite: `userId` is `TEXT` → Supabase: `user_id` is `UUID`
   - SQLite: `id` is `TEXT` → Supabase: `id` is `UUID`
   - SQLite: `folderId` is `TEXT` → Supabase: `folder_id` is `UUID`

## 🚨 CRITICAL ISSUES TO FIX

### 1. Exercise Sync Service Needs Column Mapping
The current sync service will fail because of column name mismatches.

### 2. Template Folders Missing user_id
SQLite doesn't have `user_id` but Supabase requires it.

### 3. ID Type Mismatches
SQLite uses TEXT IDs, Supabase uses UUIDs.

## 🔧 REQUIRED FIXES

### Fix 1: Update Exercise Sync Service
```dart
// Map SQLite column names to Supabase column names
await supabase.from('exercises').upsert({
  'id': exercise.id,
  'name': exercise.name,
  'primary_muscle_group': exercise.primaryMuscleGroup,  // ✅ Mapped
  'secondary_muscle_groups': exercise.secondaryMuscleGroups,
  'equipment': exercise.equipment,
  'instructions': exercise.instructions,
  'tags': exercise.tags,
  'aliases': exercise.aliases,
  'is_bodyweight': exercise.isBodyweight,  // ✅ Mapped
  'exercise_type': exercise.exerciseType,  // ✅ Mapped
  'category': exercise.category,
  'difficulty': exercise.difficulty,
  'parent_exercise_id': exercise.parentExerciseId,  // ✅ Mapped
  'variant_type': exercise.variantType,  // ✅ Mapped
  'user_id': user.id,  // ✅ Use authenticated user ID
  'created_at': exercise.createdAt.toIso8601String(),
  'updated_at': exercise.updatedAt.toIso8601String(),
});
```

### Fix 2: Update Template Folders Sync
```dart
await supabase.from('template_folders').upsert({
  'id': folder.id,
  'user_id': user.id,  // ✅ Add user_id
  'name': folder.name,
  'description': folder.description,
  'color': folder.color,
  'is_expanded': folder.isExpanded,  // ✅ Mapped
  'sort_order': folder.sortOrder,  // ✅ Mapped
  'created_at': folder.createdAt.toIso8601String(),
  'updated_at': folder.updatedAt.toIso8601String(),
});
```

### Fix 3: Update Workout Templates Sync
```dart
await supabase.from('workout_templates').upsert({
  'id': template.id,
  'user_id': user.id,  // ✅ Use authenticated user ID
  'name': template.name,
  'description': template.description,
  'category': template.category,
  'folder_id': template.folderId,  // ✅ Mapped
  'exercise_ids': template.exerciseIds,
  'estimated_duration': template.estimatedDurationMinutes,  // ✅ Mapped
  'sort_order': template.sortOrder,  // ✅ Mapped
  'tags': template.tags,
  'is_default': template.isDefault,  // ✅ Mapped
  'created_at': template.createdAt.toIso8601String(),
  'updated_at': template.updatedAt.toIso8601String(),
});
```

## ✅ CONCLUSION

**The schemas are NOT ready for migration** due to:
1. Column name mismatches (camelCase vs snake_case)
2. Missing user_id in template folders
3. ID type differences (TEXT vs UUID)

**Next Steps:**
1. Update the sync service with proper column mapping
2. Test the sync process
3. Verify data integrity after migration
