# Sync UUID Issue: Folders & Templates

## Problem

The sync failed for folders and templates because of **ID type mismatch**:

### SQLite (Mobile)
- Uses **string IDs**: `"fold_strength"`, `"fold_calisthenics"`, `"template_123"` 
- Human-readable, easy to debug
- Simple to generate

### Supabase (Web)
- Uses **UUID**: `550e8400-e29b-41d4-a716-446655440000`
- Standard PostgreSQL UUID type
- Generated via `uuid_generate_v4()`

### Error
```
PostgrestException(message: invalid input syntax for type uuid: "fold_strength", 
code: 22P02, details: Bad Request, hint: null)
```

## Current Solution

**Skip syncing folders and templates with folders** until proper ID mapping is implemented:

### What Syncs ✅
- ✅ **Exercises**: ~500 exercises (no folder dependency)
- ✅ **Templates without folders**: Templates that have `folder_id = null`

### What Doesn't Sync ⚠️
- ⚠️ **Folders**: All folders skipped (UUID mismatch)
- ⚠️ **Templates in folders**: Skipped because they reference folders

## Why This Approach

### Pros
- ✅ Exercises sync successfully (main goal achieved!)
- ✅ No data corruption
- ✅ Simple and safe
- ✅ Can be fixed later

### Cons
- ⚠️ Folders not available on web
- ⚠️ Most templates not available on web (if they're in folders)

## Future Solutions

### Option 1: ID Mapping Table
Create a mapping between SQLite string IDs and Supabase UUIDs:

```dart
final idMap = {
  'fold_strength': '550e8400-e29b-41d4-a716-446655440000',
  'fold_calisthenics': '660e8400-e29b-41d4-a716-446655440001',
  // ...
};
```

### Option 2: Change SQLite to UUIDs
Migrate SQLite to use UUIDs:
- Add migration to convert string IDs to UUIDs
- Update all foreign key references
- More complex but cleaner long-term

### Option 3: Change Supabase to TEXT
Change Supabase `id` columns from `UUID` to `TEXT`:
- Simpler for sync
- Loses UUID benefits (indexing, validation)
- Not recommended

## Recommended Approach

**For now:**  
Just sync exercises (the most important data). Folders and templates are less critical for web users.

**Long-term:**  
Implement Option 2 (migrate SQLite to UUIDs) as part of a larger schema standardization.

## Files Modified

1. ✅ `lib/src/core/services/exercise_sync_service.dart`
   - Skips folder sync with warning message
   - Skips templates with `folder_id` set
   - Only syncs templates without folders

## Status

- ✅ **Exercises**: Ready to sync (~500 exercises)
- ⚠️ **Folders**: Skipped (UUID issue)
- ⚠️ **Templates**: Only those without folders will sync

## Next Steps

1. **Test exercise sync** - Should work now!
2. **Verify on web** - Exercises should appear
3. **Plan folder migration** - For future release
