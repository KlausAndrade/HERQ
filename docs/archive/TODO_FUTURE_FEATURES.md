# 📋 Future Features TODO List

## Priority Features to Implement

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

- [ ] **Workout start behavior**
  - Auto-start timer on first set
  - Ask to start timer
  - Never auto-start

##### 12.3 Privacy Controls
- [ ] **Who can see workouts**
  - Public (everyone)
  - Friends only
  - Private (only me)
  - Per-workout privacy override

- [ ] **Activity visibility**
  - Show on feed (public/friends)
  - Hide PRs from feed
  - Hide workout details
  - Anonymous mode

- [ ] **Profile visibility**
  - Public profile
  - Friends only
  - Private (searchable vs hidden)

##### 12.4 Notification Preferences
- [ ] **Push notification types**
  - Workout reminders ✓/✗
  - Social interactions (likes, comments) ✓/✗
  - Friend requests ✓/✗
  - Achievement unlocks ✓/✗
  - Streak reminders ✓/✗

- [ ] **Quiet hours**
  - Don't send notifications between X-Y time
  - Weekend notification preferences
  - Custom schedule

- [ ] **Email notifications**
  - Weekly summary emails
  - PR notifications
  - Friend activity digest
  - Unsubscribe options

##### 12.5 Data & Backup
- [ ] **Automatic backups**
  - Daily cloud backup to Supabase
  - Local backup to device
  - Backup schedule customization

- [ ] **Manual backup/restore**
  - Export all data as JSON
  - Import from backup file
  - Selective restore (workouts only, etc.)

- [ ] **Data sync settings**
  - WiFi only sync
  - Mobile data allowed
  - Sync frequency (real-time, hourly, manual)

##### 12.6 Account Management
- [ ] **Account deletion (GDPR compliant)**
  - Request deletion with confirmation
  - 30-day grace period
  - Complete data wipeout
  - Email confirmation required

- [ ] **Data download (GDPR)**
  - Request all personal data
  - Download as JSON/CSV
  - Includes workouts, posts, messages
  - Email delivery

- [ ] **Connected accounts**
  - View linked OAuth providers
  - Unlink accounts
  - Add new login methods

##### 12.7 Appearance
- [ ] **Theme customization**
  - Light mode
  - Dark mode
  - Auto (system)
  - Custom accent colors

- [ ] **Font size**
  - Small
  - Medium (default)
  - Large
  - Extra Large (accessibility)

- [ ] **Compact mode**
  - Dense UI for power users
  - Show more data per screen

#### Technical Implementation:

**Settings Model:**
```dart
class UserSettings {
  // Units
  final WeightUnit weightUnit;
  final LengthUnit lengthUnit;
  
  // Workout
  final int defaultRestSeconds;
  final bool autoStartTimer;
  final double weightIncrement;
  
  // Privacy
  final PrivacyLevel workoutPrivacy;
  final bool showPRsOnFeed;
  final bool allowSearch;
  
  // Notifications
  final bool enablePushNotifications;
  final NotificationPreferences notificationPrefs;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  
  // Data
  final bool autoBackup;
  final bool wifiOnlySync;
  final SyncFrequency syncFrequency;
  
  // Appearance
  final ThemeMode themeMode;
  final Color accentColor;
  final double fontScale;
}

enum PrivacyLevel { public, friendsOnly, private }
enum SyncFrequency { realtime, hourly, daily, manual }
```

**Database Schema:**
```sql
-- Add to profiles table
ALTER TABLE profiles ADD COLUMN settings JSONB DEFAULT '{
  "weightUnit": "kg",
  "defaultRestSeconds": 90,
  "workoutPrivacy": "friendsOnly",
  "enablePushNotifications": true,
  "themeMode": "system"
}'::jsonb;
```

**Settings Screen Structure:**
```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        _buildSection('Units & Measurements'),
        _buildSection('Workout Preferences'),
        _buildSection('Privacy & Security'),
        _buildSection('Notifications'),
        _buildSection('Data & Backup'),
        _buildSection('Account'),
        _buildSection('Appearance'),
        _buildSection('About'),
      ],
    );
  }
}
```

**Account Deletion Flow:**
```dart
Future<void> deleteAccount() async {
  // 1. Show warning dialog
  final confirmed = await showDialog<bool>(...);
  if (!confirmed) return;
  
  // 2. Send email confirmation
  await authService.sendDeletionEmail();
  
  // 3. Mark account for deletion (30-day grace period)
  await supabase
    .from('profiles')
    .update({'deletion_requested_at': DateTime.now()})
    .eq('id', userId);
  
  // 4. Schedule deletion job (backend)
  // After 30 days:
  // - Delete all workout_sessions
  // - Delete all posts, comments, likes
  // - Delete profile
  // - Delete auth user
}
```

#### Acceptance Criteria:
- [ ] All settings persist across app restarts
- [ ] Settings sync to cloud (Supabase)
- [ ] Unit conversion works everywhere
- [ ] Account deletion is GDPR compliant
- [ ] Data export includes all user data
- [ ] Privacy settings enforced in RLS policies
- [ ] Settings UI is organized and searchable
- [ ] Changes take effect immediately

---

---

### 13. 📊 **Excel Import/Export** (High Priority)

**Status:** ⏳ Not Started  
**Estimated Effort:** 1 week  
**Dependencies:** Basic data export (already exists)

#### Features to Add:

##### 13.1 Excel Export
- [ ] **Full workout history export**
  - Export all workouts to Excel (.xlsx)
  - Multiple sheets (Workouts, Sets, Exercises, PRs)
  - Formatted tables with headers
  - Auto-column sizing

- [ ] **Template export**
  - Export workout templates
  - Exercise library export
  - Custom templates with notes

- [ ] **Progress report export**
  - Volume trends by week/month
  - PR history
  - Body stats (if tracked)
  - Charts embedded in Excel

- [ ] **Customizable exports**
  - Date range selection
  - Filter by exercise/muscle group
  - Choose columns to export
  - Custom file naming

##### 13.2 Excel Import
- [ ] **Bulk workout import**
  - Import workouts from Excel
  - Support Hevy format
  - Support Strong app format
  - Support custom CSV/Excel templates

- [ ] **Template import**
  - Import workout templates
  - Batch create templates from spreadsheet
  - Exercise mapping/matching

- [ ] **Data migration**
  - Import from other apps (Hevy, Strong, FitNotes)
  - Auto-detect format
  - Data validation before import
  - Duplicate detection

- [ ] **Error handling**
  - Show import preview
  - Highlight errors/warnings
  - Skip invalid rows option
  - Detailed error messages

#### Technical Implementation:

**Packages Required:**
```yaml
# pubspec.yaml
dependencies:
  excel: ^4.0.3              # Create/read Excel files
  file_picker: ^8.0.0        # Pick files from device
  share_plus: ^10.0.0        # Share exported files
  path_provider: ^2.1.4      # Get app directory
```

**Excel Export Service:**
```dart
class ExcelExportService {
  Future<String> exportWorkoutsToExcel({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? exerciseIds,
  }) async {
    final excel = Excel.createExcel();
    
    // Sheet 1: Workouts Summary
    final workoutsSheet = excel['Workouts'];
    workoutsSheet.appendRow([
      'Date', 'Workout Name', 'Duration', 'Total Volume', 
      'Total Sets', 'Total Reps', 'Notes'
    ]);
    
    // Fetch workouts
    final workouts = await _getWorkouts(startDate, endDate);
    for (final workout in workouts) {
      workoutsSheet.appendRow([
        workout.completedAt.toString(),
        workout.name,
        _formatDuration(workout.totalDurationSeconds),
        workout.totalVolume,
        workout.totalSets,
        workout.totalReps,
        workout.notes ?? '',
      ]);
    }
    
    // Sheet 2: Sets Detail
    final setsSheet = excel['Sets'];
    setsSheet.appendRow([
      'Date', 'Workout', 'Exercise', 'Set #', 
      'Weight', 'Reps', 'RPE', 'Rest (sec)'
    ]);
    
    // ... populate sets data
    
    // Sheet 3: Personal Records
    final prsSheet = excel['Personal Records'];
    // ... populate PRs
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/GymAI_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    
    final fileBytes = excel.save();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);
    
    return filePath;
  }
}
```

**Excel Import Service:**
```dart
class ExcelImportService {
  Future<ImportResult> importFromExcel(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    
    final result = ImportResult();
    
    // Detect format (Hevy, Strong, GymAI, Custom)
    final format = _detectFormat(excel);
    
    switch (format) {
      case ImportFormat.hevy:
        await _importHevy(excel, result);
        break;
      case ImportFormat.strong:
        await _importStrong(excel, result);
        break;
      case ImportFormat.gymAI:
        await _importGymAI(excel, result);
        break;
      default:
        throw UnsupportedFormatException();
    }
    
    return result;
  }
  
  Future<void> _importHevy(Excel excel, ImportResult result) async {
    // Hevy format: Date, Exercise, Set, Weight, Reps, RPE, etc.
    final sheet = excel.tables['Workouts'];
    if (sheet == null) return;
    
    for (var row in sheet.rows.skip(1)) { // Skip header
      try {
        final workout = _parseHevyRow(row);
        await _saveWorkout(workout);
        result.successCount++;
      } catch (e) {
        result.errors.add('Row ${row.rowIndex}: $e');
        result.failureCount++;
      }
    }
  }
}

class ImportResult {
  int successCount = 0;
  int failureCount = 0;
  List<String> errors = [];
  List<String> warnings = [];
}
```

**UI Implementation:**
```dart
// Export button
ElevatedButton.icon(
  icon: Icon(Icons.download),
  label: Text('Export to Excel'),
  onPressed: () async {
    final service = ref.read(excelExportServiceProvider);
    final filePath = await service.exportWorkoutsToExcel();
    
    // Share file
    await Share.shareXFiles([XFile(filePath)]);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to Excel successfully!')),
    );
  },
)

// Import button
ElevatedButton.icon(
  icon: Icon(Icons.upload),
  label: Text('Import from Excel'),
  onPressed: () async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    
    if (result != null) {
      final service = ref.read(excelImportServiceProvider);
      final importResult = await service.importFromExcel(result.files.single.path!);
      
      _showImportResultDialog(importResult);
    }
  },
)
```

**Hevy Format Support:**
```dart
// Hevy CSV/Excel format columns:
// Date | Start Time | End Time | Workout Name | Exercise Name | 
// Set Order | Weight | Reps | Distance | Duration | Notes | RPE
class HevyWorkoutParser {
  WorkoutSession parseHevyRow(List<dynamic> row) {
    return WorkoutSession(
      id: Uuid().v4(),
      name: row[3].toString(), // Workout Name
      startedAt: DateTime.parse('${row[0]} ${row[1]}'),
      completedAt: DateTime.parse('${row[0]} ${row[2]}'),
      // ... parse other fields
    );
  }
}
```

#### Supported Formats:

**1. Hevy Format:**
- Date, Start Time, End Time, Workout Name, Exercise Name
- Set Order, Weight, Reps, Distance, Duration, Notes, RPE

**2. Strong App Format:**
- Date, Workout Name, Exercise Name, Set Order
- Weight, Reps, Distance, Seconds, Notes, Workout Notes

**3. FitNotes Format:**
- Date, Exercise, Category, Weight, Reps
- Distance, Time, Comment

**4. GymAI Native Format:**
- Custom optimized format for full-fidelity import/export

#### Acceptance Criteria:
- [ ] Export generates valid .xlsx files
- [ ] Import supports Hevy, Strong, FitNotes formats
- [ ] Data validation before import
- [ ] Preview import data before saving
- [ ] Handle missing/invalid data gracefully
- [ ] Export includes all workout metadata
- [ ] File size optimized for large datasets
- [ ] Progress indicator for large imports/exports

---

### 14. ⌚ **Apple Watch & Wearables Sync** (High Priority)

**Status:** ⏳ Not Started  
**Estimated Effort:** 3-4 weeks  
**Dependencies:** iOS app, WatchOS app development

#### Features to Add:

##### 14.1 Apple Watch App
- [ ] **Standalone WatchOS app**
  - Start workouts from watch
  - Log sets directly on watch
  - View exercise list
  - Rest timer with haptic feedback

- [ ] **Quick workout actions**
  - Quick start last workout
  - Voice commands (Siri shortcuts)
  - Complications showing stats
  - Today's workout widget

- [ ] **Real-time sync with iPhone**
  - Instant sync of logged sets
  - Live updates across devices
  - Conflict resolution
  - Offline support with queue

##### 14.2 HealthKit Integration
- [ ] **Read health data**
  - Heart rate during workouts
  - Active calories burned
  - Steps count
  - Sleep data (for recovery analysis)
  - Body measurements (weight, BMI)

- [ ] **Write workout data to HealthKit**
  - Log workouts to Apple Health
  - Exercise types (strength, cardio)
  - Energy burned calculations
  - Duration and intensity

- [ ] **Sync with Apple Fitness+**
  - Workout rings integration
  - Activity sharing
  - Achievements sync

##### 14.3 Other Wearables Support
- [ ] **Wear OS (Android Watch)**
  - Android Wear app
  - Google Fit integration
  - Tile shortcuts

- [ ] **Fitbit Integration**
  - Read activity data
  - Heart rate zones
  - Sleep tracking

- [ ] **Garmin Connect**
  - Import activities
  - Export workouts
  - Sync body stats

- [ ] **Whoop Integration**
  - Recovery score
  - Strain tracking
  - Sleep performance

##### 14.4 Heart Rate Training
- [ ] **HR Zone tracking**
  - Real-time heart rate display
  - Zone-based training
  - Target HR alerts
  - Cardio efficiency metrics

- [ ] **Recovery monitoring**
  - Resting heart rate trends
  - HRV (Heart Rate Variability)
  - Recovery recommendations
  - Overtraining detection

- [ ] **Workout intensity**
  - Calories burned per exercise
  - Intensity score
  - EPOC estimation
  - Fatigue index

#### Technical Implementation:

**WatchOS App Setup:**
```swift
// Watch App Target: GymAI Watch App
// WatchKit Extension

import WatchKit
import HealthKit

class WorkoutController: WKInterfaceController {
    @IBOutlet weak var exerciseLabel: WKInterfaceLabel!
    @IBOutlet weak var setButton: WKInterfaceButton!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    
    var healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Request HealthKit permissions
        requestHealthKitPermissions()
        
        // Setup Watch Connectivity
        setupWatchConnectivity()
    }
    
    @IBAction func logSetTapped() {
        // Send to iPhone app
        sendSetDataToiPhone()
        
        // Start rest timer
        startRestTimer()
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.success)
    }
}
```

**Watch Connectivity (iOS Side):**
```dart
// lib/src/features/wearables/watch_connectivity_service.dart

import 'package:watch_connectivity/watch_connectivity.dart';

class WatchConnectivityService {
  final WatchConnectivity _watch = WatchConnectivity();
  
  Future<void> initialize() async {
    // Check if watch is paired
    final isPaired = await _watch.isPaired;
    if (!isPaired) return;
    
    // Listen for messages from watch
    _watch.messageStream.listen((message) {
      _handleWatchMessage(message);
    });
    
    // Send active workout to watch
    await _sendActiveWorkoutToWatch();
  }
  
  Future<void> _handleWatchMessage(Map<String, dynamic> message) async {
    final type = message['type'];
    
    switch (type) {
      case 'log_set':
        await _logSetFromWatch(message);
        break;
      case 'start_workout':
        await _startWorkoutFromWatch(message);
        break;
      case 'complete_workout':
        await _completeWorkoutFromWatch();
        break;
    }
  }
  
  Future<void> sendWorkoutToWatch(WorkoutSession workout) async {
    await _watch.sendMessage({
      'type': 'active_workout',
      'workout': workout.toJson(),
      'exercises': workout.exercises.map((e) => e.toJson()).toList(),
    });
  }
}
```

**HealthKit Integration:**
```dart
// pubspec.yaml
dependencies:
  health: ^10.2.0

// lib/src/features/health/health_service.dart
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();
  
  Future<void> requestPermissions() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WORKOUT,
      HealthDataType.WEIGHT,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.RESTING_HEART_RATE,
      HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    ];
    
    await _health.requestAuthorization(types);
  }
  
  Future<void> writeWorkoutToHealth(WorkoutSession workout) async {
    final startDate = workout.startedAt;
    final endDate = workout.completedAt ?? DateTime.now();
    
    await _health.writeWorkoutData(
      activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
      start: startDate,
      end: endDate,
      totalEnergyBurned: _calculateCalories(workout),
      totalDistance: 0,
    );
  }
  
  Future<List<HealthDataPoint>> getHeartRateDuringWorkout(
    DateTime start,
    DateTime end,
  ) async {
    return await _health.getHealthDataFromTypes(
      start,
      end,
      [HealthDataType.HEART_RATE],
    );
  }
  
  Future<double?> getRestingHeartRate() async {
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 1));
    
    final data = await _health.getHealthDataFromTypes(
      yesterday,
      now,
      [HealthDataType.RESTING_HEART_RATE],
    );
    
    if (data.isEmpty) return null;
    return (data.last.value as NumericHealthValue).numericValue.toDouble();
  }
}
```

**Watch Complications:**
```swift
// WatchKit Extension: ComplicationController.swift

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        // Fetch today's workout stats from shared data
        let stats = WorkoutStats.today()
        
        let template: CLKComplicationTemplate
        
        switch complication.family {
        case .modularSmall:
            template = CLKComplicationTemplateModularSmallStackText()
            (template as! CLKComplicationTemplateModularSmallStackText).line1TextProvider = CLKSimpleTextProvider(text: stats.workoutCount.description)
            (template as! CLKComplicationTemplateModularSmallStackText).line2TextProvider = CLKSimpleTextProvider(text: "Workouts")
            
        case .circularSmall:
            template = CLKComplicationTemplateCircularSmallRingText()
            // ... configure template
            
        default:
            handler(nil)
            return
        }
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
}
```

**Android Wear (Wear OS):**
```dart
// For Wear OS support, use:
dependencies:
  wear: ^2.0.0

// Create separate Wear OS module with Material for Wear widgets
import 'package:wear/wear.dart';

class WearWorkoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              body: mode == WearMode.active
                  ? ActiveWorkoutView()
                  : AmbientWorkoutView(),
            );
          },
        );
      },
    );
  }
}
```

#### Platform Requirements:

**iOS & WatchOS:**
- Xcode 15+
- WatchOS 9.0+
- iOS 16.0+
- HealthKit capabilities enabled
- Watch Connectivity framework

**Android & Wear OS:**
- Android Studio
- Wear OS 3.0+
- Health Connect API
- Wear OS module

#### Acceptance Criteria:
- [ ] WatchOS app can start/log workouts independently
- [ ] Real-time sync between watch and phone (< 2 sec)
- [ ] HealthKit data syncs bidirectionally
- [ ] Heart rate displays during workouts
- [ ] Watch complications show today's stats
- [ ] Offline mode with sync queue
- [ ] Haptic feedback for set completion
- [ ] Voice feedback for rest timer
- [ ] Battery optimized (< 5% per hour)
- [ ] Works with iPhone locked/backgrounded

---

## 🎯 Implementation Order Recommendation

**Phase 1 (Week 1-2):**
1. ⚙️ **Advanced Settings** (#12) - Foundation for everything else
   - Unit preferences (critical for global users)
   - Privacy controls (data protection)
   - Basic notification preferences

**Phase 2 (Week 3):**
2. 📊 **Excel Import/Export** (#13) - High demand feature
   - Export to Excel
   - Import from Hevy/Strong
   - Data migration tools

**Phase 3 (Week 4-5):**
3. 📊 **Advanced Analytics** (#8) - High value for power users
   - Volume trends
   - Muscle balance
   - Plateau detection

**Phase 4 (Week 6-9):**
4. ⌚ **Apple Watch & Wearables** (#14) - Platform expansion
   - WatchOS app development
   - HealthKit integration
   - Wear OS support

**Phase 5 (Week 10-11):**
5. 🌍 **Internationalization** (#11) - Scale globally
   - Setup i18n framework
   - Add Spanish + Portuguese
   - RTL support for Arabic

---

## 📝 Notes

- All features should follow existing architecture patterns
- Use Riverpod for state management
- Follow Material Design 3 guidelines
- Write tests for critical business logic
- Update documentation as features are added
- Prioritize features based on user feedback and analytics

---

## 🎯 Feature Priorities Summary

**Must Have (P0):**
- ⚙️ Advanced Settings (#12)
- 📊 Excel Import/Export (#13)
- ⌚ Apple Watch Sync (#14)

**Should Have (P1):**
- 📊 Advanced Analytics (#8)

**Nice to Have (P2):**
- 🌍 Internationalization (#11)

---

**Last Updated:** October 6, 2025  
**Status:** Ready for implementation
