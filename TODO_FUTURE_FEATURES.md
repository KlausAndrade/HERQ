# 📋 Future Features TODO List

## Priority Features to Implement

### 🔧 Immediate UX & Exercise/Search Fixes (High Priority)

These are small, high-impact changes that improve search relevance and the UX for body-weight / time-based exercises.

- [ ] Body-weight / skill exercises: support exercises that are not weight+reps (e.g., handstand, free handstand)
  - [ ] Add exercise type/flag that signals "time-based" or "skill" so UI shows a timer input instead of KG & reps by default
  - [ ] Ensure handstand / free handstand (and similar balance/skill moves) are seeded with the correct type
  - [ ] Allow optional fields for intensity (RPE) and notes for these exercises

- [ ] Time-based exercise quick-entry UI
  - [ ] Add a compact timer input next to set entry for exercises of type "timer" (presets: 10s/20s/30s/45s/60s)
  - [ ] Support keyboard shortcuts on web for quick time presets
  - [ ] Persist last-used timer presets per exercise as a quick-recall

- [ ] Search improvements (synonyms & muscle-group aware)
  - [ ] Use the new `aliases` column in `exercises` for synonym matching (supports hspu → handstand push up)
  - [ ] Implement a tokenizer that matches aliases, exercise title, and tags (case-insensitive, partial matches)
  - [ ] Muscle-group search: when user searches for "bicep" or "biceps" return exercises whose primary/secondary muscle group includes biceps (e.g., dumbbell curl)
  - [ ] Add unit tests for search behavior (alias match, muscle-group match, partial match)

- [ ] Preacher exercise & seeds
  - [ ] Add `preacher_curl` (and common variants: barbell_preacher_curl, db_preacher_curl, machine_preacher_curl) to seed packs
  - [ ] Include aliases (e.g., "preacher", "preacher curl") and muscle group tag `biceps`
  - [ ] Ensure search returns preacher variants for queries like "preacher" and "bicep"

- [ ] In-app notification redesign (revamp)
  - [ ] Design: create a sleek, professional notification style (mockups + Figma link placeholder)
  - [ ] Implement a new notification UI component with better typography, spacing and optional action buttons
  - [ ] Add accessibility labels and large-text support for notifications
  - [ ] Add unit tests / widget tests for the redesigned notification component


## ✅ Recent small wins (done)

- [x] Exercise aliases column + seeding (schema bumped to v13, aliases populated for selected seeds)
- [x] Test helpers & DB test fixes (in-memory DB helper, updated database tests)
- [x] Safe notification initialization for tests (notification service guarded)
- [x] Groq service resilient mock mode (falls back to deterministic mock when API key missing)

Notes: These were implemented as low-risk, backwards-compatible changes to support development and tests. See `lib/src/core/database/database.dart`, `lib/src/core/services/notification_service.dart`, and `lib/src/core/services/groq_service.dart`.


### 8. 📊 **Advanced Analytics** (Medium Priority)

**Status:** ⏳ Not Started  
**Estimated Effort:** 2-3 weeks  
**Dependencies:** Existing workout data, charts library

#### Features to Add:
- [ ] Volume load trends over time
  - Line chart showing total volume per week/month
  - Volume breakdown by muscle group
  - Comparison with previous periods

- [ ] Muscle group balance analysis
  - Pie chart of training volume distribution
  - Identify imbalances (e.g., too much push, not enough pull)
  - Recommendations for balanced training

- [ ] Frequency analysis
  - Workouts per week trend
  - Training consistency metrics
  - Rest day patterns

- [ ] Exercise variation tracking
  - How often you change exercises
  - Exercise rotation recommendations
  - Staleness detection

- [ ] Plateau detection
  - Identify when progress stalls
  - Automatic deload suggestions
  - Progressive overload tracking

- [ ] Injury risk indicators
  - Overtraining detection
  - Volume spikes warning
  - Recovery time insufficient alerts

- [ ] Recovery time analysis
  - Time between muscle group workouts
  - Optimal recovery period suggestions
  - Fatigue accumulation tracking

- [ ] Strength standards comparison
  - Compare lifts to population standards (Beginner/Intermediate/Advanced)
  - Symmetry analysis (left vs right imbalances)
  - Relative strength ratios

#### Technical Implementation:

**New Screens:**
```dart
// lib/src/features/analytics/presentation/screens/
- advanced_analytics_screen.dart      // Main analytics hub
- volume_trends_screen.dart           // Volume analysis
- muscle_balance_screen.dart          // Balance analysis  
- plateau_detection_screen.dart       // Progress analysis
- strength_standards_screen.dart      // Comparison screen
```

**New Services:**
```dart
// lib/src/features/analytics/data/services/
- analytics_service.dart              // Core analytics calculations
- plateau_detector.dart               // Plateau detection algorithm
- strength_standards.dart             // Standards comparison data
```

**Database Queries:**
```sql
-- Get volume trends by muscle group
SELECT 
  DATE_TRUNC('week', completed_at) as week,
  muscle_group,
  SUM(weight * reps) as total_volume
FROM workout_sessions ws
JOIN set_entries se ON ws.id = se.workout_session_id
JOIN exercises e ON se.exercise_id = e.id
GROUP BY week, muscle_group
ORDER BY week DESC;

-- Detect plateaus (no PR in 4+ weeks)
SELECT exercise_id, MAX(achieved_at) as last_pr
FROM personal_records
GROUP BY exercise_id
HAVING MAX(achieved_at) < NOW() - INTERVAL '4 weeks';
```

**Charts Needed:**
- Line charts (volume trends)
- Pie charts (muscle group distribution)
- Bar charts (frequency analysis)
- Radar charts (strength standards)
- Heatmaps (training frequency calendar)

#### Acceptance Criteria:
- [ ] Volume trends show last 12 weeks minimum
- [ ] Muscle group balance identifies imbalances > 20%
- [ ] Plateau detection runs weekly automatically
- [ ] Strength standards based on bodyweight and gender
- [ ] All charts responsive and interactive
- [ ] Export analytics as PDF report

---

### 11. 🌍 **Internationalization (i18n)** (Low Priority)

**Status:** ⏳ Not Started  
**Estimated Effort:** 1-2 weeks  
**Dependencies:** None

#### Features to Add:
- [ ] Multi-language support
  - English (default) ✅
  - Spanish
  - Portuguese (Brazilian)
  - French
  - German
  - Japanese
  - Chinese (Simplified)

- [ ] Translation system
  - ARB files for each language
  - Translation keys
  - Pluralization support
  - Gender-based translations

- [ ] RTL (Right-to-Left) support
  - Arabic support
  - Hebrew support
  - Mirror UI layouts
  - Text direction handling

- [ ] Locale-based units
  - kg vs lbs preference
  - cm vs inches (height)
  - Automatic detection based on locale
  - Manual override in settings

- [ ] Date/Time localization
  - Date format (MM/DD vs DD/MM)
  - Time format (12h vs 24h)
  - First day of week (Sunday vs Monday)
  - Relative dates ("Today", "Yesterday")

- [ ] Number formatting
  - Decimal separators (. vs ,)
  - Thousand separators
  - Currency formatting (if monetization added)

#### Technical Implementation:

**Setup Flutter Localization:**
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

**Create l10n.yaml:**
```yaml
arb-dir: lib/src/generated/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

**Translation Files:**
```
lib/src/generated/l10n/
├── app_en.arb          # English (base)
├── app_es.arb          # Spanish
├── app_pt.arb          # Portuguese
├── app_fr.arb          # French
├── app_de.arb          # German
├── app_ja.arb          # Japanese
├── app_zh.arb          # Chinese
└── app_ar.arb          # Arabic (RTL)
```

**Example ARB File (app_en.arb):**
```json
{
  "@@locale": "en",
  "appTitle": "GymAI",
  "workouts": "Workouts",
  "exercises": "Exercises",
  "progress": "Progress",
  "settings": "Settings",
  "startWorkout": "Start Workout",
  "logSet": "Log Set",
  "weight": "Weight",
  "reps": "Reps",
  "restTimer": "Rest Timer",
  "personalRecords": "Personal Records",
  "totalVolume": "Total Volume",
  "workoutCompleted": "Workout Completed!",
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Greeting message with user name",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Unit Preference Model:**
```dart
enum WeightUnit {
  kg,
  lbs;
  
  double convert(double value, WeightUnit to) {
    if (this == to) return value;
    if (this == WeightUnit.kg && to == WeightUnit.lbs) {
      return value * 2.20462;
    }
    return value / 2.20462;
  }
}

enum LengthUnit {
  cm,
  inches;
  
  double convert(double value, LengthUnit to) {
    if (this == to) return value;
    if (this == LengthUnit.cm && to == LengthUnit.inches) {
      return value / 2.54;
    }
    return value * 2.54;
  }
}
```

**Settings UI:**
```dart
// Add to settings screen
ListTile(
  title: Text('Language'),
  subtitle: Text(currentLocale.languageCode.toUpperCase()),
  trailing: Icon(Icons.language),
  onTap: () => _showLanguagePicker(),
),
ListTile(
  title: Text('Weight Unit'),
  subtitle: Text(weightUnit.name.toUpperCase()),
  trailing: Icon(Icons.fitness_center),
  onTap: () => _toggleWeightUnit(),
),
```

#### Acceptance Criteria:
- [ ] All user-facing text translatable
- [ ] Language switcher in settings
- [ ] RTL layouts work correctly
- [ ] Units convert automatically
- [ ] Dates format based on locale
- [ ] No hardcoded strings in UI
- [ ] Translation coverage > 95%

---

### 12. ⚙️ **Advanced Settings** (High Priority)

**Status:** ⏳ Not Started  
**Estimated Effort:** 1 week  
**Dependencies:** i18n (for units), notifications

#### Features to Add:

##### 12.1 Unit Preferences
- [ ] **Metric vs Imperial toggle**
  - Weight: kg ↔ lbs
  - Height: cm ↔ inches
  - Distance: km ↔ miles
  - Apply globally across app

- [ ] **Auto-detection**
  - Detect from device locale
  - Smart defaults (US = imperial, rest = metric)
  - Manual override option

##### 12.2 Workout Preferences
- [ ] **Default rest timer customization**
  - Set default per exercise type
  - Compound lifts: 3-5 min
  - Isolation: 1-2 min
  - Cardio: 30-60 sec

- [ ] **Auto-increment weight suggestions**
  - Enable/disable feature
  - Increment amount (2.5kg, 5lbs, etc.)
  - Progressive overload automation

*** End of file