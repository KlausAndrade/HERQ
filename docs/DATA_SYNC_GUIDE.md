# Data Sync Guide: SQLite to Supabase

## Overview
This guide explains how to sync your local SQLite data (exercises, templates, folders) to Supabase so it's available on web and other devices.

## Quick Start

### 1. Open Admin Dashboard
Navigate to `/admin/sync` in your app

### 2. Sync Your Data
Click **"Sync All"** to sync everything in the correct order:
1. **Exercises** (~500+ exercises)
2. **Folders** (with UUID mapping)
3. **Templates** (linked to folders)

### 3. Verify on Web
Run `npm run web` and check that exercises and templates appear.

## What Gets Synced

### ✅ Exercises (Fully Supported)
- All 500+ exercises from your local database
- Includes variants, progressions, regressions
- Categories: strength, calisthenics, yoga, cardio
- **Result**: Global exercises visible to all users on web

### ✅ Folders (With UUID Mapping)
- All workout template folders
- **ID Conversion**: SQLite string IDs → Supabase UUIDs
- Automatic mapping maintained during sync
- **Result**: Your folder structure preserved on web

### ✅ Templates (With Folder Links)
- All workout templates
- Folder references automatically mapped to correct UUIDs
- Exercise lists preserved
- **Result**: Complete workout templates available on web

## Technical Details

### Schema Alignment
SQLite and Supabase schemas are now aligned using:
- **Column Names**: snake_case (e.g., `primary_muscle_group`)
- **Data Types**: Compatible conversions applied
- **User Isolation**: `user_id` properly set

### Data Conversions

#### Equipment Field
- **SQLite**: Single string (e.g., `"barbell"`)
- **Supabase**: Array (e.g., `["barbell"]`)
- **Conversion**: Automatic during sync

#### Exercise Type Mapping
| SQLite Value | Supabase Value |
|--------------|----------------|
| `body_weight_reps` | `bodyweight` |
| `bodyweight_reps` | `bodyweight` |
| `duration` | `time` |
| `yoga` | `time` |
| `reps` | `weight_reps` |

#### Variant Type Mapping  
| SQLite Value | Supabase Value |
|--------------|----------------|
| `base` | `null` |
| `stance` | `null` |
| `weight` | `null` |
| `unilateral` | `equipment` |

### UUID Mapping

**Folders:**
```
SQLite: "fold_strength" → Supabase: "uuid-generated-123"
SQLite: "fold_ppl" → Supabase: "uuid-generated-456"
```

**Templates:**
```
Template folder_id: "fold_strength" → Mapped to → "uuid-generated-123"
```

## Troubleshooting

### Issue: "No exercises found in local database"
**Solution**: Make sure you've loaded the app and exercises have been seeded.

### Issue: "Folder sync failed"
**Solution**: Reinstall the app to apply all migrations (current: v24).

### Issue: "Template has folder_id but no mapping found"
**Solution**: Folders must sync before templates. Use "Sync All" not individual syncs.

### Issue: "Duplicate key value violates unique constraint"
**Solution**: Data already synced. Clear Supabase tables if you want to re-sync:
```sql
DELETE FROM workout_templates WHERE user_id = 'your-user-id';
DELETE FROM template_folders WHERE user_id = 'your-user-id';
DELETE FROM exercises WHERE user_id IS NULL; -- Global exercises
```

## Success Criteria

After successful sync, you should see:
```
✅ Successfully synced: 505 exercises
✅ Successfully synced: N folders
✅ Successfully synced: 25 templates
```

## Files Reference

- **Sync Service**: `lib/src/core/services/exercise_sync_service.dart`
- **Sync Screen**: `lib/src/features/admin/presentation/screens/data_sync_screen.dart`
- **Database Schema**: `lib/src/core/database/database.dart` (v24)

## Next Steps

After syncing:
1. ✅ Test web exercise library
2. ✅ Test web workout templates
3. ✅ Verify folder organization on web
4. ✅ Test creating workouts on web

---

**Last Updated**: October 20, 2025  
**Schema Version**: SQLite v24
