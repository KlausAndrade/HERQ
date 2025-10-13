-- Auto-assign exercise types to existing exercises based on their names
-- Run this in Supabase SQL Editor after the migration

BEGIN;

-- Duration-based exercises (holds, planks, isometric)
UPDATE exercises 
SET exercise_type = 'duration' 
WHERE exercise_type = 'weight_reps' 
  AND (
    LOWER(name) LIKE '%plank%' OR
    LOWER(name) LIKE '%hold%' OR
    LOWER(name) LIKE '%wall sit%' OR
    LOWER(name) LIKE '%dead hang%' OR
    LOWER(name) LIKE '%handstand%' OR
    LOWER(name) LIKE '%l-sit%' OR
    LOWER(name) LIKE '%l sit%' OR
    LOWER(name) LIKE '%hollow body%' OR
    LOWER(name) LIKE '%arch hold%' OR
    LOWER(name) LIKE '%support hold%' OR
    LOWER(name) LIKE '%static hold%' OR
    LOWER(name) LIKE '%isometric%' OR
    LOWER(name) LIKE '%bridge hold%' OR
    LOWER(name) LIKE '%horse stance%'
  );

-- Distance & Duration (cardio exercises)
UPDATE exercises 
SET exercise_type = 'distance_duration' 
WHERE exercise_type = 'weight_reps' 
  AND (
    LOWER(name) LIKE '%run%' OR
    LOWER(name) LIKE '%jog%' OR
    LOWER(name) LIKE '%sprint%' OR
    LOWER(name) LIKE '%row%' OR
    LOWER(name) LIKE '%swim%' OR
    LOWER(name) LIKE '%cycle%' OR
    LOWER(name) LIKE '%cycling%' OR
    LOWER(name) LIKE '%bike%' OR
    LOWER(name) LIKE '%biking%' OR
    LOWER(name) LIKE '%elliptical%' OR
    LOWER(name) LIKE '%treadmill%' OR
    LOWER(name) LIKE '%ski erg%' OR
    LOWER(name) LIKE '%assault bike%' OR
    LOWER(name) LIKE '%air bike%' OR
    category = 'cardio' OR
    category = 'conditioning'
  );

-- Duration & Weight (timed carries)
UPDATE exercises 
SET exercise_type = 'duration_weight' 
WHERE exercise_type = 'weight_reps' 
  AND (
    LOWER(name) LIKE '%farmer walk%' OR
    LOWER(name) LIKE '%farmers walk%' OR
    LOWER(name) LIKE '%sled push%' OR
    LOWER(name) LIKE '%sled pull%' OR
    LOWER(name) LIKE '%prowler push%'
  );

-- Weight & Distance (distance carries)
UPDATE exercises 
SET exercise_type = 'weight_distance' 
WHERE exercise_type = 'weight_reps' 
  AND (
    LOWER(name) LIKE '%farmer carry%' OR
    LOWER(name) LIKE '%farmers carry%' OR
    LOWER(name) LIKE '%waiter carry%' OR
    LOWER(name) LIKE '%waiters carry%' OR
    LOWER(name) LIKE '%overhead carry%' OR
    LOWER(name) LIKE '%suitcase carry%' OR
    LOWER(name) LIKE '%goblet carry%' OR
    LOWER(name) LIKE '%yoke walk%' OR
    LOWER(name) LIKE '%yoke carry%'
  );

-- Weighted Bodyweight
UPDATE exercises 
SET exercise_type = 'weighted_bodyweight' 
WHERE exercise_type = 'weight_reps' 
  AND (
    LOWER(name) LIKE '%weighted pull%' OR
    LOWER(name) LIKE '%weighted chin%' OR
    LOWER(name) LIKE '%weighted dip%' OR
    LOWER(name) LIKE '%weighted push%' OR
    LOWER(name) LIKE '%weighted muscle%' OR
    LOWER(name) LIKE '%weighted pistol%' OR
    LOWER(name) LIKE '%+weight%' OR
    LOWER(name) LIKE '%+ weight%'
  );

-- Assisted Bodyweight
UPDATE exercises 
SET exercise_type = 'assisted_bodyweight' 
WHERE exercise_type = 'weight_reps' 
  AND (
    LOWER(name) LIKE '%assisted pull%' OR
    LOWER(name) LIKE '%assisted chin%' OR
    LOWER(name) LIKE '%assisted dip%' OR
    LOWER(name) LIKE '%assisted muscle%' OR
    LOWER(name) LIKE '%band pull%' OR
    LOWER(name) LIKE '%band chin%' OR
    LOWER(name) LIKE '%band dip%' OR
    LOWER(name) LIKE '%machine pull%' OR
    LOWER(name) LIKE '%machine chin%' OR
    LOWER(name) LIKE '%machine dip%'
  );

-- Bodyweight Reps
UPDATE exercises 
SET exercise_type = 'bodyweight_reps' 
WHERE exercise_type = 'weight_reps' 
  AND (
    equipment_type IN ('bodyweight', 'none', 'Bodyweight', 'None') OR
    category IN ('calisthenics', 'bodyweight', 'Calisthenics', 'Bodyweight') OR
    LOWER(name) LIKE '%push-up%' OR
    LOWER(name) LIKE '%pushup%' OR
    LOWER(name) LIKE '%push up%' OR
    LOWER(name) LIKE '%pull-up%' OR
    LOWER(name) LIKE '%pullup%' OR
    LOWER(name) LIKE '%pull up%' OR
    LOWER(name) LIKE '%chin-up%' OR
    LOWER(name) LIKE '%chinup%' OR
    LOWER(name) LIKE '%chin up%' OR
    LOWER(name) LIKE '%dip%' OR
    LOWER(name) LIKE '%muscle-up%' OR
    LOWER(name) LIKE '%muscle up%' OR
    LOWER(name) LIKE '%burpee%' OR
    LOWER(name) LIKE '%air squat%' OR
    LOWER(name) LIKE '%box jump%' OR
    LOWER(name) LIKE '%pistol squat%' OR
    LOWER(name) LIKE '%nordic curl%' OR
    LOWER(name) LIKE '%inverted row%' OR
    LOWER(name) LIKE '%bodyweight%'
  )
  -- Exclude if already assigned to weighted or assisted
  AND exercise_type NOT IN ('weighted_bodyweight', 'assisted_bodyweight', 'duration');

-- Update description message
DO $$
DECLARE
  duration_count INT;
  distance_duration_count INT;
  duration_weight_count INT;
  weight_distance_count INT;
  weighted_bodyweight_count INT;
  assisted_bodyweight_count INT;
  bodyweight_reps_count INT;
  weight_reps_count INT;
BEGIN
  SELECT COUNT(*) INTO duration_count FROM exercises WHERE exercise_type = 'duration';
  SELECT COUNT(*) INTO distance_duration_count FROM exercises WHERE exercise_type = 'distance_duration';
  SELECT COUNT(*) INTO duration_weight_count FROM exercises WHERE exercise_type = 'duration_weight';
  SELECT COUNT(*) INTO weight_distance_count FROM exercises WHERE exercise_type = 'weight_distance';
  SELECT COUNT(*) INTO weighted_bodyweight_count FROM exercises WHERE exercise_type = 'weighted_bodyweight';
  SELECT COUNT(*) INTO assisted_bodyweight_count FROM exercises WHERE exercise_type = 'assisted_bodyweight';
  SELECT COUNT(*) INTO bodyweight_reps_count FROM exercises WHERE exercise_type = 'bodyweight_reps';
  SELECT COUNT(*) INTO weight_reps_count FROM exercises WHERE exercise_type = 'weight_reps';
  
  RAISE NOTICE 'Exercise types updated successfully!';
  RAISE NOTICE 'Duration: % exercises', duration_count;
  RAISE NOTICE 'Distance & Duration: % exercises', distance_duration_count;
  RAISE NOTICE 'Duration & Weight: % exercises', duration_weight_count;
  RAISE NOTICE 'Weight & Distance: % exercises', weight_distance_count;
  RAISE NOTICE 'Weighted Bodyweight: % exercises', weighted_bodyweight_count;
  RAISE NOTICE 'Assisted Bodyweight: % exercises', assisted_bodyweight_count;
  RAISE NOTICE 'Bodyweight Reps: % exercises', bodyweight_reps_count;
  RAISE NOTICE 'Weight & Reps: % exercises', weight_reps_count;
END $$;

COMMIT;

