-- ============================================================================
-- EXERCISE CLEANUP SCRIPT
-- ============================================================================
-- 
-- Purpose: Delete exercise variants containing numbers, grip types, or equipment
-- 
-- ⚠️  IMPORTANT SECURITY NOTES:
-- 1. Always run Step 1 (preview) before Step 3 (deletion)
-- 2. Consider backing up the exercises table before deletion
-- 3. This operation is IRREVERSIBLE - deleted data cannot be recovered
-- 4. Recommended: Test in a development environment first
--
-- Examples:
-- - bench-press ✓ (keep)
-- - bench-press-2 ✗ (delete - has number)
-- - close-grip-bench-press ✗ (delete - has grip type)
-- - chest-supported-dumbbell-pullover ✗ (delete - has equipment)
-- - supported-pullover ✓ (keep)
-- ============================================================================

-- Step 1: Preview exercises that will be deleted
-- (Run this first to see what will be deleted)
SELECT 
    id, 
    name,
    CASE 
        WHEN name ~ '-\d+' THEN 'contains number'
        WHEN name ~* '(close-grip|wide-grip|narrow-grip|neutral-grip|overhand-grip|underhand-grip|pronated-grip|supinated-grip|mixed-grip|hook-grip|false-grip|suicide-grip|thumbless-grip)' 
            THEN 'contains grip type'
        WHEN name ~* '(dumbbell|barbell|cable|kettlebell|machine|band|resistance-band|smith-machine|ez-bar|trap-bar|hex-bar|safety-bar|cambered-bar|swiss-bar|football-bar|axle-bar|log-bar)' 
            THEN 'contains equipment'
        ELSE 'unknown'
    END as reason
FROM exercises
WHERE 
    name ~ '-\d+' -- matches patterns like "-1", "-2", "-3" etc
    OR name ~* '(close-grip|wide-grip|narrow-grip|neutral-grip|overhand-grip|underhand-grip|pronated-grip|supinated-grip|mixed-grip|hook-grip|false-grip|suicide-grip|thumbless-grip)'
    OR name ~* '(dumbbell|barbell|cable|kettlebell|machine|band|resistance-band|smith-machine|ez-bar|trap-bar|hex-bar|safety-bar|cambered-bar|swiss-bar|football-bar|axle-bar|log-bar)'
ORDER BY name;

-- Step 2: Get count of exercises to delete
SELECT COUNT(*) as total_to_delete
FROM exercises
WHERE 
    name ~ '-\d+' 
    OR name ~* '(close-grip|wide-grip|narrow-grip|neutral-grip|overhand-grip|underhand-grip|pronated-grip|supinated-grip|mixed-grip|hook-grip|false-grip|suicide-grip|thumbless-grip)'
    OR name ~* '(dumbbell|barbell|cable|kettlebell|machine|band|resistance-band|smith-machine|ez-bar|trap-bar|hex-bar|safety-bar|cambered-bar|swiss-bar|football-bar|axle-bar|log-bar)';

-- Step 3: [OPTIONAL] Backup exercises before deletion
-- Uncomment to create a backup table
/*
CREATE TABLE exercises_backup_$(date +%Y%m%d) AS 
SELECT * FROM exercises;
*/

-- Step 4: Actually delete the exercises
-- ⚠️  WARNING: This is IRREVERSIBLE! Only run after reviewing Step 1!
-- Uncomment the DELETE statement below to execute:
/*
BEGIN;  -- Start transaction for safety

DELETE FROM exercises
WHERE 
    name ~ '-\d+' 
    OR name ~* '(close-grip|wide-grip|narrow-grip|neutral-grip|overhand-grip|underhand-grip|pronated-grip|supinated-grip|mixed-grip|hook-grip|false-grip|suicide-grip|thumbless-grip)'
    OR name ~* '(dumbbell|barbell|cable|kettlebell|machine|band|resistance-band|smith-machine|ez-bar|trap-bar|hex-bar|safety-bar|cambered-bar|swiss-bar|football-bar|axle-bar|log-bar)';

-- Verify the count looks correct before committing
SELECT COUNT(*) as deleted_count FROM exercises;

-- If count looks wrong, run: ROLLBACK;
-- If count looks correct, run: COMMIT;

COMMIT;  -- Finalize the deletion
*/

-- Step 5: Verify the deletion (run after Step 4)
/*
SELECT COUNT(*) as remaining_exercises FROM exercises;
SELECT name FROM exercises ORDER BY name LIMIT 20;  -- Show some remaining exercises
*/

