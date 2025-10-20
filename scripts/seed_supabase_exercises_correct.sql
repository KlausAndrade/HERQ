-- Seed script matching YOUR actual Supabase schema
-- Based on error: primary_muscle_group (singular), secondary_muscle_groups (plural), etc.

INSERT INTO exercises (
  id, 
  name, 
  category, 
  type, 
  difficulty, 
  equipment, 
  primary_muscle_group, 
  secondary_muscle_groups, 
  instructions
)
VALUES
  -- Chest Exercises
  ('barbell_bench_press', 'Barbell Bench Press', 'chest', 'compound', 'intermediate', ARRAY['barbell'], 'chest', ARRAY['triceps', 'shoulders'], 'Lie on a flat bench. Lower the barbell to your chest, then press it back up.'),
  ('push_up', 'Push-Up', 'chest', 'compound', 'beginner', ARRAY['bodyweight'], 'chest', ARRAY['triceps', 'shoulders'], 'Start in plank position. Lower your body until chest nearly touches the floor, then push back up.'),
  ('dumbbell_fly', 'Dumbbell Fly', 'chest', 'isolation', 'intermediate', ARRAY['dumbbells'], 'chest', ARRAY['shoulders'], 'Lie on bench with dumbbells extended. Lower weights in arc motion, then return to start.'),
  ('incline_bench_press', 'Incline Bench Press', 'chest', 'compound', 'intermediate', ARRAY['barbell'], 'chest', ARRAY['shoulders', 'triceps'], 'Set bench to 30-45 degrees. Press barbell from upper chest to arms extended.'),
  
  -- Back Exercises
  ('pull_up', 'Pull-Up', 'back', 'compound', 'intermediate', ARRAY['pull-up bar'], 'back', ARRAY['biceps', 'shoulders'], 'Hang from bar with overhand grip. Pull yourself up until chin clears bar.'),
  ('barbell_row', 'Barbell Row', 'back', 'compound', 'intermediate', ARRAY['barbell'], 'back', ARRAY['biceps', 'shoulders'], 'Bent over at hips, pull barbell to lower chest. Keep back straight.'),
  ('deadlift', 'Deadlift', 'back', 'compound', 'advanced', ARRAY['barbell'], 'back', ARRAY['legs', 'glutes'], 'Lift barbell from ground by extending hips and knees. Keep bar close to body.'),
  ('lat_pulldown', 'Lat Pulldown', 'back', 'compound', 'beginner', ARRAY['cable machine'], 'back', ARRAY['biceps'], 'Pull bar down to upper chest. Control the return.'),
  
  -- Leg Exercises
  ('barbell_squat', 'Barbell Squat', 'legs', 'compound', 'intermediate', ARRAY['barbell'], 'legs', ARRAY['glutes', 'core'], 'Bar on upper back, squat down until thighs parallel to ground, then stand.'),
  ('leg_press', 'Leg Press', 'legs', 'compound', 'beginner', ARRAY['machine'], 'legs', ARRAY['glutes'], 'Push platform away by extending legs. Control the descent.'),
  ('lunge', 'Lunge', 'legs', 'compound', 'beginner', ARRAY['bodyweight'], 'legs', ARRAY['glutes', 'core'], 'Step forward and lower hips until both knees bent at 90 degrees.'),
  ('leg_curl', 'Leg Curl', 'legs', 'isolation', 'beginner', ARRAY['machine'], 'legs', ARRAY[]::TEXT[], 'Curl legs up towards glutes while lying face down.'),
  ('calf_raise', 'Calf Raise', 'legs', 'isolation', 'beginner', ARRAY['bodyweight', 'machine'], 'legs', ARRAY[]::TEXT[], 'Raise heels as high as possible, then lower slowly.'),
  
  -- Shoulder Exercises
  ('overhead_press', 'Overhead Press', 'shoulders', 'compound', 'intermediate', ARRAY['barbell'], 'shoulders', ARRAY['triceps', 'core'], 'Press barbell from shoulders to overhead. Keep core tight.'),
  ('lateral_raise', 'Lateral Raise', 'shoulders', 'isolation', 'beginner', ARRAY['dumbbells'], 'shoulders', ARRAY[]::TEXT[], 'Raise dumbbells to sides until arms parallel to ground. Control the descent.'),
  ('front_raise', 'Front Raise', 'shoulders', 'isolation', 'beginner', ARRAY['dumbbells'], 'shoulders', ARRAY[]::TEXT[], 'Raise dumbbells in front to shoulder height.'),
  ('face_pull', 'Face Pull', 'shoulders', 'isolation', 'beginner', ARRAY['cable machine'], 'shoulders', ARRAY[]::TEXT[], 'Pull rope to face, pulling apart at the end.'),
  
  -- Arm Exercises
  ('barbell_curl', 'Barbell Curl', 'arms', 'isolation', 'beginner', ARRAY['barbell'], 'biceps', ARRAY[]::TEXT[], 'Curl barbell up by bending elbows. Keep upper arms stationary.'),
  ('hammer_curl', 'Hammer Curl', 'arms', 'isolation', 'beginner', ARRAY['dumbbells'], 'biceps', ARRAY[]::TEXT[], 'Curl dumbbells with palms facing each other.'),
  ('tricep_dip', 'Tricep Dip', 'arms', 'compound', 'intermediate', ARRAY['bodyweight'], 'triceps', ARRAY['chest', 'shoulders'], 'Lower body by bending elbows until upper arms parallel to ground, then push back up.'),
  ('tricep_extension', 'Tricep Extension', 'arms', 'isolation', 'beginner', ARRAY['dumbbells', 'cable machine'], 'triceps', ARRAY[]::TEXT[], 'Extend arms overhead or from behind head.'),
  ('skull_crusher', 'Skull Crusher', 'arms', 'isolation', 'intermediate', ARRAY['barbell'], 'triceps', ARRAY[]::TEXT[], 'Lying down, lower bar to forehead, then extend arms.'),
  
  -- Core Exercises
  ('plank', 'Plank', 'core', 'isometric', 'beginner', ARRAY['bodyweight'], 'core', ARRAY['shoulders'], 'Hold body in straight line from head to heels, resting on forearms and toes.'),
  ('ab_wheel_rollout', 'Ab Wheel Rollout', 'core', 'compound', 'advanced', ARRAY['ab wheel'], 'core', ARRAY['shoulders'], 'Roll wheel forward extending body, then pull back to start position.'),
  ('crunch', 'Crunch', 'core', 'isolation', 'beginner', ARRAY['bodyweight'], 'core', ARRAY[]::TEXT[], 'Lie on back, lift shoulders off ground by contracting abs.'),
  ('russian_twist', 'Russian Twist', 'core', 'compound', 'intermediate', ARRAY['bodyweight', 'medicine ball'], 'core', ARRAY[]::TEXT[], 'Sit with feet elevated, twist torso side to side.')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  type = EXCLUDED.type,
  difficulty = EXCLUDED.difficulty,
  equipment = EXCLUDED.equipment,
  primary_muscle_group = EXCLUDED.primary_muscle_group,
  secondary_muscle_groups = EXCLUDED.secondary_muscle_groups,
  instructions = EXCLUDED.instructions;

-- Verify the insert
SELECT COUNT(*) as exercise_count FROM exercises;
SELECT name, category, primary_muscle_group, difficulty FROM exercises ORDER BY category, name;
