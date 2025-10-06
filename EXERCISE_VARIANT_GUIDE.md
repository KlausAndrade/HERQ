# Exercise Variant System Guide

## What Are Exercise Variants?

Exercise variants are different versions of the same basic exercise. For example:
- **Bench Press** (parent) has variants:
  - Incline Bench Press (angle variant)
  - Decline Bench Press (angle variant)
  - Close-Grip Bench Press (equipment variant)
  - Dumbbell Bench Press (equipment variant)

The variant system helps you:
- ✅ Organize related exercises together
- ✅ Track progressions (easier → harder variations)
- ✅ Find regressions (harder → easier variations)
- ✅ Discover equipment alternatives

## How to Create an Exercise Variant

### Step 1: Create or Navigate to Exercise
1. Go to **Exercise Library**
2. Tap the **+ button** (FloatingActionButton)
3. Fill in basic exercise details (name, muscle group, equipment, etc.)

### Step 2: Enable Variant Option
Scroll down to the **"Exercise Variant"** card and:
1. Toggle **"This is a variant"** switch to ON
2. Two new fields appear:
   - Parent Exercise dropdown
   - Variant Type dropdown

### Step 3: Select Parent Exercise
1. Tap the **"Parent Exercise"** dropdown
2. Select the main exercise this is a variant of
3. Example: For "Incline Bench Press", select "Bench Press"

### Step 4: Choose Variant Type
Select how this variant differs from the parent:

| Variant Type | Color | Description | Examples |
|--------------|-------|-------------|----------|
| **Progression** | 🟢 Green | Harder version | One-arm push-up, Pistol squat |
| **Regression** | 🟡 Amber | Easier version | Knee push-up, Box squat |
| **Assisted** | 🔵 Blue | With assistance | Assisted pull-up, Band-assisted dip |
| **Weighted** | 🟣 Purple | Add weight to bodyweight | Weighted pull-up, Weighted dip |
| **Equipment** | 🟦 Teal | Different equipment | Dumbbell vs Barbell press |
| **Strict** | 🔷 Indigo | Stricter form | Strict pull-up, Pause squat |
| **Angle** | 🟠 Orange | Different angle | Incline/Decline variations |
| **Tempo** | 🌸 Pink | Different speed | Slow eccentric, Explosive concentric |

### Step 5: Save
1. Tap **"Save"** in the AppBar
2. The variant is created and linked to its parent

## Viewing Variants

### In Exercise Library

**Default View (Variants Hidden)**:
- Only parent exercises are shown
- Keeps the list clean and organized

**Show Variants Toggle**:
1. In Exercise Library, find the **"Show Variants"** toggle
2. Turn it ON to see all variants
3. Variants display with colored badges:
   ```
   Exercise Name
   [PROGRESSION] 🟢  or  [EQUIPMENT] 🟦
   ```

### In Exercise Detail

When viewing a parent exercise or variant:
- You can see the full progression chain
- All related variants are listed together
- Sorted by difficulty level

## Practical Examples

### Example 1: Push-up Progression

**Parent**: Push-up
```
Create Exercise: "Knee Push-up"
- Parent: Push-up
- Variant Type: regression
- Difficulty: beginner
```

```
Create Exercise: "Archer Push-up"  
- Parent: Push-up
- Variant Type: progression
- Difficulty: advanced
```

```
Create Exercise: "One-Arm Push-up"
- Parent: Push-up
- Variant Type: progression
- Difficulty: expert
```

### Example 2: Pull-up Variations

**Parent**: Pull-up
```
Create Exercise: "Assisted Pull-up"
- Parent: Pull-up
- Variant Type: assisted
- Difficulty: beginner
```

```
Create Exercise: "Weighted Pull-up"
- Parent: Pull-up
- Variant Type: weighted
- Difficulty: advanced
```

```
Create Exercise: "Chin-up"
- Parent: Pull-up  
- Variant Type: equipment
- Difficulty: intermediate
```

### Example 3: Bench Press Angles

**Parent**: Bench Press
```
Create Exercise: "Incline Bench Press"
- Parent: Bench Press
- Variant Type: angle
- Difficulty: intermediate
```

```
Create Exercise: "Decline Bench Press"
- Parent: Bench Press
- Variant Type: angle
- Difficulty: intermediate
```

## Variant System Features

### 1. Progression Chains
View all variations of an exercise sorted by difficulty:
```
Beginner    → Intermediate → Advanced     → Expert
Knee Pushup → Push-up      → Archer Pushup → One-Arm Pushup
```

### 2. Smart Filtering
- Filter by variant type
- Hide variants to simplify library
- Show variants to see all options

### 3. Visual Indicators
Each variant type has a unique color:
- Easy to spot in lists
- Quick visual reference
- Helps with progression planning

### 4. Exercise Relationships
- Variants automatically linked to parent
- Can have multiple variants per parent
- Variants inherit muscle groups from parent (but can be customized)

## Use Cases

### For Beginners
Create **regression variants** to build up strength:
```
Goal: Do a pull-up
1. Start: Assisted Pull-up (assisted)
2. Progress: Negative Pull-up (regression)
3. Achieve: Pull-up (parent)
```

### For Advanced Athletes
Create **progression variants** for continued challenge:
```
Goal: Harder push-up variations
1. Master: Push-up (parent)
2. Try: Archer Push-up (progression)
3. Goal: One-Arm Push-up (progression)
```

### For Equipment Alternatives
Create **equipment variants** when equipment isn't available:
```
No barbell?
- Barbell Bench Press → Dumbbell Bench Press (equipment)
- Barbell Squat → Dumbbell Goblet Squat (equipment)
```

### For Form Variations
Create **strict variants** for better technique:
```
Improve pull-up form:
- Kipping Pull-up → Strict Pull-up (strict)
- Touch-and-go Deadlift → Pause Deadlift (strict)
```

## Form Validation

When creating a variant, the form ensures:
- ✅ Parent Exercise is selected (required)
- ✅ Variant Type is selected (required)
- ✅ Parent Exercise exists in database
- ✅ Prevents circular references

## Database Structure

### Exercise Table Fields
```dart
parentExerciseId: 'bench_press'  // ID of parent (null if not a variant)
variantType: 'angle'              // Type of variation (null if not a variant)
```

### Example Records
```dart
// Parent Exercise
{
  id: 'bench_press',
  name: 'Bench Press',
  parentExerciseId: null,      // No parent - this IS the parent
  variantType: null,            // Not a variant
}

// Variant Exercise  
{
  id: 'custom_uuid-1234',
  name: 'Incline Bench Press',
  parentExerciseId: 'bench_press',  // Links to parent
  variantType: 'angle',              // Type of variant
}
```

## Tips & Best Practices

### Naming Conventions
✅ **Good**: "Incline Bench Press", "Assisted Pull-up", "Weighted Dip"  
❌ **Avoid**: "Bench Press 2", "Pull-up (Easy)", "Dip - Harder"

### Variant Types
- Use **progression** for harder versions requiring more strength
- Use **regression** for easier versions for beginners
- Use **assisted** for variations with external help (bands, machines)
- Use **equipment** when only the equipment changes
- Use **angle** for incline/decline/angle variations
- Use **strict** for form-focused variations
- Use **tempo** for speed/timing variations

### Organization
- Create the **parent exercise first**
- Then create variants referencing it
- Keep variant names descriptive
- Use difficulty levels appropriately

### Progressive Overload
Build progression ladders:
```
1. Regression (beginner)
2. Parent (intermediate)  
3. Progression (advanced)
4. Advanced Progression (expert)
```

## Troubleshooting

### "Can't find parent exercise"
- Make sure parent exercise exists first
- Check that toggle "Show Variants" is ON if looking for it
- Parent might be filtered out by muscle group or equipment

### "Variant not showing"
- Turn ON "Show Variants" toggle in Exercise Library
- Check that parent exercise is visible
- Variants inherit filtering from parents

### "Want to change variant type"
- Currently: Delete and recreate (editing coming soon)
- Future: Edit exercise feature will allow changing variant type

## Future Enhancements

Planned improvements:
- [ ] Edit variant settings for existing exercises
- [ ] Automatically suggest variants based on equipment
- [ ] Visual progression tree view
- [ ] Sort variants by difficulty automatically
- [ ] Recommend next progression based on performance
- [ ] Import variant chains from exercise databases

## Quick Reference Card

### Creating a Variant
1. ➕ Tap + button in Exercise Library
2. 📝 Fill exercise name and details
3. 🔄 Toggle "This is a variant" ON
4. 👆 Select parent exercise
5. 🎨 Choose variant type (see colors above)
6. 💾 Tap Save

### Viewing Variants
1. 📚 Go to Exercise Library
2. 🔘 Toggle "Show Variants" ON
3. 👀 See variants with colored badges
4. 🔍 Tap exercise to see full variant chain

### Variant Type Colors
- 🟢 Progression (harder)
- 🟡 Regression (easier)
- 🔵 Assisted (with help)
- 🟣 Weighted (add weight)
- 🟦 Equipment (different tool)
- 🔷 Strict (better form)
- 🟠 Angle (different angle)
- 🌸 Tempo (different speed)

---

**The variant system helps you organize exercises logically and build progressive training programs!** 💪
