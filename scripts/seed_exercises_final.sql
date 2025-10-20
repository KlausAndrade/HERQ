-- Seed exercises for the recreated table
-- Run this AFTER recreate_exercises_table.sql

INSERT INTO exercises (
  id, 
  name, 
  category, 
  type, 
  difficulty, 
  equipment, 
  primary_muscle_group, 
  secondary_muscle_groups,
  instructions,
  aliases,
  tags,
  is_bodyweight,
  exercise_type,
  user_id
)
VALUES
  -- Chest Exercises
  ('barbell_bench_press', 'Barbell Bench Press', 'chest', 'compound', 'intermediate', 
   ARRAY['barbell'], 'chest', ARRAY['triceps', 'shoulders'], 
   'Lie on a flat bench. Lower the barbell to your chest, then press it back up.', 
   ARRAY['bench press', 'flat bench'], ARRAY['push', 'pressing'], false, 'weight_reps', NULL),
   
  ('push_up', 'Push-Up', 'chest', 'compound', 'beginner', 
   ARRAY['bodyweight'], 'chest', ARRAY['triceps', 'shoulders'], 
   'Start in plank position. Lower your body until chest nearly touches the floor, then push back up.', 
   ARRAY['pushup'], ARRAY['bodyweight', 'push', 'home'], true, 'weight_reps', NULL),
   
  ('dumbbell_fly', 'Dumbbell Fly', 'chest', 'isolation', 'intermediate', 
   ARRAY['dumbbells'], 'chest', ARRAY['shoulders'], 
   'Lie on bench with dumbbells extended. Lower weights in arc motion, then return to start.', 
   ARRAY['db fly', 'chest fly'], ARRAY['isolation', 'stretch'], false, 'weight_reps', NULL),
   
  ('incline_bench_press', 'Incline Bench Press', 'chest', 'compound', 'intermediate', 
   ARRAY['barbell'], 'chest', ARRAY['shoulders', 'triceps'], 
   'Set bench to 30-45 degrees. Press barbell from upper chest to arms extended.', 
   ARRAY['incline press'], ARRAY['push', 'upper chest'], false, 'weight_reps', NULL),
  
  -- Back Exercises
  ('pull_up', 'Pull-Up', 'back', 'compound', 'intermediate', 
   ARRAY['pull-up bar'], 'back', ARRAY['biceps', 'shoulders'], 
   'Hang from bar with overhand grip. Pull yourself up until chin clears bar.', 
   ARRAY['pullup', 'chin up'], ARRAY['bodyweight', 'pull', 'vertical'], true, 'weight_reps', NULL),
   
  ('barbell_row', 'Barbell Row', 'back', 'compound', 'intermediate', 
   ARRAY['barbell'], 'back', ARRAY['biceps', 'shoulders'], 
   'Bent over at hips, pull barbell to lower chest. Keep back straight.', 
   ARRAY['bent over row'], ARRAY['pull', 'horizontal'], false, 'weight_reps', NULL),
   
  ('deadlift', 'Deadlift', 'back', 'compound', 'advanced', 
   ARRAY['barbell'], 'back', ARRAY['legs', 'glutes', 'core'], 
   'Lift barbell from ground by extending hips and knees. Keep bar close to body.', 
   ARRAY['dl', 'conventional deadlift'], ARRAY['power', 'posterior chain'], false, 'weight_reps', NULL),
   
  ('lat_pulldown', 'Lat Pulldown', 'back', 'compound', 'beginner', 
   ARRAY['cable machine'], 'back', ARRAY['biceps'], 
   'Pull bar down to upper chest. Control the return.', 
   ARRAY['lat pull'], ARRAY['machine', 'vertical pull'], false, 'weight_reps', NULL),
  
  -- Leg Exercises
  ('barbell_squat', 'Barbell Squat', 'legs', 'compound', 'intermediate', 
   ARRAY['barbell'], 'legs', ARRAY['glutes', 'core'], 
   'Bar on upper back, squat down until thighs parallel to ground, then stand.', 
   ARRAY['back squat', 'squat'], ARRAY['power', 'lower body'], false, 'weight_reps', NULL),
   
  ('leg_press', 'Leg Press', 'legs', 'compound', 'beginner', 
   ARRAY['machine'], 'legs', ARRAY['glutes'], 
   'Push platform away by extending legs. Control the descent.', 
   ARRAY[]::TEXT[], ARRAY['machine', 'lower body'], false, 'weight_reps', NULL),
   
  ('lunge', 'Lunge', 'legs', 'compound', 'beginner', 
   ARRAY['bodyweight'], 'legs', ARRAY['glutes', 'core'], 
   'Step forward and lower hips until both knees bent at 90 degrees.', 
   ARRAY['walking lunge', 'forward lunge'], ARRAY['bodyweight', 'balance', 'home'], true, 'weight_reps', NULL),
   
  ('leg_curl', 'Leg Curl', 'legs', 'isolation', 'beginner', 
   ARRAY['machine'], 'legs', ARRAY[]::TEXT[], 
   'Curl legs up towards glutes while lying face down.', 
   ARRAY['hamstring curl'], ARRAY['machine', 'hamstrings'], false, 'weight_reps', NULL),
   
  ('calf_raise', 'Calf Raise', 'legs', 'isolation', 'beginner', 
   ARRAY['bodyweight', 'machine'], 'legs', ARRAY[]::TEXT[], 
   'Raise heels as high as possible, then lower slowly.', 
   ARRAY['calf raises'], ARRAY['calves'], false, 'weight_reps', NULL),
  
  -- Shoulder Exercises
  ('overhead_press', 'Overhead Press', 'shoulders', 'compound', 'intermediate', 
   ARRAY['barbell'], 'shoulders', ARRAY['triceps', 'core'], 
   'Press barbell from shoulders to overhead. Keep core tight.', 
   ARRAY['military press', 'ohp', 'shoulder press'], ARRAY['push', 'power'], false, 'weight_reps', NULL),
   
  ('lateral_raise', 'Lateral Raise', 'shoulders', 'isolation', 'beginner', 
   ARRAY['dumbbells'], 'shoulders', ARRAY[]::TEXT[], 
   'Raise dumbbells to sides until arms parallel to ground. Control the descent.', 
   ARRAY['side raise'], ARRAY['isolation', 'shoulders'], false, 'weight_reps', NULL),
   
  ('front_raise', 'Front Raise', 'shoulders', 'isolation', 'beginner', 
   ARRAY['dumbbells'], 'shoulders', ARRAY[]::TEXT[], 
   'Raise dumbbells in front to shoulder height.', 
   ARRAY[]::TEXT[], ARRAY['isolation', 'shoulders'], false, 'weight_reps', NULL),
   
  ('face_pull', 'Face Pull', 'shoulders', 'isolation', 'beginner', 
   ARRAY['cable machine'], 'shoulders', ARRAY[]::TEXT[], 
   'Pull rope to face, pulling apart at the end.', 
   ARRAY[]::TEXT[], ARRAY['rear delts', 'shoulders'], false, 'weight_reps', NULL),
  
  -- Arm Exercises
  ('barbell_curl', 'Barbell Curl', 'arms', 'isolation', 'beginner', 
   ARRAY['barbell'], 'biceps', ARRAY[]::TEXT[], 
   'Curl barbell up by bending elbows. Keep upper arms stationary.', 
   ARRAY['bicep curl'], ARRAY['isolation', 'arms'], false, 'weight_reps', NULL),
   
  ('hammer_curl', 'Hammer Curl', 'arms', 'isolation', 'beginner', 
   ARRAY['dumbbells'], 'biceps', ARRAY[]::TEXT[], 
   'Curl dumbbells with palms facing each other.', 
   ARRAY[]::TEXT[], ARRAY['isolation', 'biceps'], false, 'weight_reps', NULL),
   
  ('tricep_dip', 'Tricep Dip', 'arms', 'compound', 'intermediate', 
   ARRAY['bodyweight'], 'triceps', ARRAY['chest', 'shoulders'], 
   'Lower body by bending elbows until upper arms parallel to ground, then push back up.', 
   ARRAY['dips', 'chest dip'], ARRAY['bodyweight', 'push'], true, 'weight_reps', NULL),
   
  ('tricep_extension', 'Tricep Extension', 'arms', 'isolation', 'beginner', 
   ARRAY['dumbbells', 'cable machine'], 'triceps', ARRAY[]::TEXT[], 
   'Extend arms overhead or from behind head.', 
   ARRAY['overhead extension'], ARRAY['isolation', 'triceps'], false, 'weight_reps', NULL),
   
  ('skull_crusher', 'Skull Crusher', 'arms', 'isolation', 'intermediate', 
   ARRAY['barbell'], 'triceps', ARRAY[]::TEXT[], 
   'Lying down, lower bar to forehead, then extend arms.', 
   ARRAY['lying tricep extension'], ARRAY['isolation', 'triceps'], false, 'weight_reps', NULL),
  
  -- Core Exercises
  ('plank', 'Plank', 'core', 'isometric', 'beginner', 
   ARRAY['bodyweight'], 'core', ARRAY['shoulders'], 
   'Hold body in straight line from head to heels, resting on forearms and toes.', 
   ARRAY['front plank'], ARRAY['static', 'core', 'bodyweight', 'home'], true, 'time', NULL),
   
  ('ab_wheel_rollout', 'Ab Wheel Rollout', 'core', 'compound', 'advanced', 
   ARRAY['ab wheel'], 'core', ARRAY['shoulders'], 
   'Roll wheel forward extending body, then pull back to start position.', 
   ARRAY['ab wheel'], ARRAY['advanced', 'core'], false, 'weight_reps', NULL),
   
  ('crunch', 'Crunch', 'core', 'isolation', 'beginner', 
   ARRAY['bodyweight'], 'core', ARRAY[]::TEXT[], 
   'Lie on back, lift shoulders off ground by contracting abs.', 
   ARRAY['ab crunch'], ARRAY['bodyweight', 'core', 'home'], true, 'weight_reps', NULL),
   
  ('russian_twist', 'Russian Twist', 'core', 'compound', 'intermediate', 
   ARRAY['bodyweight', 'medicine ball'], 'core', ARRAY[]::TEXT[], 
   'Sit with feet elevated, twist torso side to side.', 
   ARRAY[]::TEXT[], ARRAY['core', 'obliques'], false, 'weight_reps', NULL);

-- Verify the insert
SELECT COUNT(*) as total_exercises FROM exercises;
SELECT category, COUNT(*) as count FROM exercises GROUP BY category ORDER BY category;
SELECT name, category, primary_muscle_group, difficulty, is_bodyweight FROM exercises ORDER BY category, name;
