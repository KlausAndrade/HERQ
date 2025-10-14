import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('es')
  ];

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'GymAI'**
  String get appTitle;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Exercises navigation label
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// Progress navigation label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Welcome message on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Ready for your next workout?'**
  String get readyForWorkout;

  /// Section title for quick action buttons
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Start workout button text
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// View progress button text
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// Exercise library button text
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

  /// History button text
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// This week stats section title
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Workouts label
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// Total volume label
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// Personal records set label
  ///
  /// In en, this message translates to:
  /// **'PRs Set'**
  String get prsSet;

  /// Recent workouts section title
  ///
  /// In en, this message translates to:
  /// **'Recent Workouts'**
  String get recentWorkouts;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;

  /// No description provided for @startFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start your first workout to see your progress here'**
  String get startFirstWorkout;

  /// No description provided for @errorLoadingWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Error loading workouts'**
  String get errorLoadingWorkouts;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @loggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged In'**
  String get loggedIn;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateDisplayNameBio.
  ///
  /// In en, this message translates to:
  /// **'Update your display name and bio'**
  String get updateDisplayNameBio;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get signedOut;

  /// No description provided for @signedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// No description provided for @signInSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Sign Up'**
  String get signInSignUp;

  /// No description provided for @syncDataAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across devices'**
  String get syncDataAcrossDevices;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @workoutSettings.
  ///
  /// In en, this message translates to:
  /// **'Workout Settings'**
  String get workoutSettings;

  /// No description provided for @defaultRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Timer'**
  String get defaultRestTimer;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight Unit'**
  String get weightUnit;

  /// No description provided for @kilogramsKg.
  ///
  /// In en, this message translates to:
  /// **'Kilograms (kg)'**
  String get kilogramsKg;

  /// No description provided for @poundsLb.
  ///
  /// In en, this message translates to:
  /// **'Pounds (lb)'**
  String get poundsLb;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @vibrateOnTimerCompletion.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on timer completion'**
  String get vibrateOnTimerCompletion;

  /// No description provided for @autoStartRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Auto-start Rest Timer'**
  String get autoStartRestTimer;

  /// No description provided for @startTimerAfterSet.
  ///
  /// In en, this message translates to:
  /// **'Start timer after completing a set'**
  String get startTimerAfterSet;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @lastSyncedNever.
  ///
  /// In en, this message translates to:
  /// **'Last synced: Never'**
  String get lastSyncedNever;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @downloadWorkoutData.
  ///
  /// In en, this message translates to:
  /// **'Download your workout data'**
  String get downloadWorkoutData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @permanentlyDeleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all data'**
  String get permanentlyDeleteAllData;

  /// No description provided for @exportWorkoutData.
  ///
  /// In en, this message translates to:
  /// **'Export your workout data as JSON or CSV'**
  String get exportWorkoutData;

  /// No description provided for @chooseExportFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose export format:'**
  String get chooseExportFormat;

  /// No description provided for @json.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get json;

  /// No description provided for @csv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csv;

  /// No description provided for @exported.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exported;

  /// No description provided for @dataExportedAsJSON.
  ///
  /// In en, this message translates to:
  /// **'Data exported to clipboard as JSON'**
  String get dataExportedAsJSON;

  /// No description provided for @workoutsExportedAsCSV.
  ///
  /// In en, this message translates to:
  /// **'Workouts exported to clipboard as CSV'**
  String get workoutsExportedAsCSV;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @cloudSyncNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is not yet configured.'**
  String get cloudSyncNotConfigured;

  /// No description provided for @syncFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'This feature will allow you to:'**
  String get syncFeatureDescription;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete:'**
  String get deleteAccountConfirmation;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm:'**
  String get typeDeleteToConfirm;

  /// No description provided for @confirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirmation required'**
  String get confirmationRequired;

  /// No description provided for @pleaseTypeDelete.
  ///
  /// In en, this message translates to:
  /// **'Please type DELETE to confirm'**
  String get pleaseTypeDelete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @accountDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account data deleted'**
  String get accountDataDeleted;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @debugExerciseTypes.
  ///
  /// In en, this message translates to:
  /// **'Debug Exercise Types'**
  String get debugExerciseTypes;

  /// No description provided for @showAllExercises.
  ///
  /// In en, this message translates to:
  /// **'Show all exercises and their types'**
  String get showAllExercises;

  /// No description provided for @refreshLeaderboardStats.
  ///
  /// In en, this message translates to:
  /// **'Refresh Leaderboard Stats'**
  String get refreshLeaderboardStats;

  /// No description provided for @recalculateStats.
  ///
  /// In en, this message translates to:
  /// **'Recalculate stats from all workouts'**
  String get recalculateStats;

  /// No description provided for @debugShowUserStats.
  ///
  /// In en, this message translates to:
  /// **'Debug: Show User Stats'**
  String get debugShowUserStats;

  /// No description provided for @viewRawUserStats.
  ///
  /// In en, this message translates to:
  /// **'View raw user_stats table data'**
  String get viewRawUserStats;

  /// No description provided for @syncToSupabase.
  ///
  /// In en, this message translates to:
  /// **'Sync to Supabase'**
  String get syncToSupabase;

  /// No description provided for @uploadStatsToCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload stats to cloud for multi-user leaderboards'**
  String get uploadStatsToCloud;

  /// No description provided for @cleanDuplicateStats.
  ///
  /// In en, this message translates to:
  /// **'Clean Duplicate Stats'**
  String get cleanDuplicateStats;

  /// No description provided for @removeDuplicateEntries.
  ///
  /// In en, this message translates to:
  /// **'Remove duplicate local user_stats entries'**
  String get removeDuplicateEntries;

  /// No description provided for @fixDisplayNames.
  ///
  /// In en, this message translates to:
  /// **'Fix Display Names'**
  String get fixDisplayNames;

  /// No description provided for @removeEmailsFromNames.
  ///
  /// In en, this message translates to:
  /// **'Remove emails from display names'**
  String get removeEmailsFromNames;

  /// No description provided for @updateExerciseTypes.
  ///
  /// In en, this message translates to:
  /// **'Update Exercise Types'**
  String get updateExerciseTypes;

  /// No description provided for @reassignExerciseTypes.
  ///
  /// In en, this message translates to:
  /// **'Reassign exercise types to all exercises'**
  String get reassignExerciseTypes;

  /// No description provided for @reloadTemplatesExercises.
  ///
  /// In en, this message translates to:
  /// **'Reload Templates & Exercises'**
  String get reloadTemplatesExercises;

  /// No description provided for @loadNewTemplates.
  ///
  /// In en, this message translates to:
  /// **'Load new workout templates and exercises'**
  String get loadNewTemplates;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @activeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get activeWorkout;

  /// No description provided for @noActiveWorkout.
  ///
  /// In en, this message translates to:
  /// **'No active workout'**
  String get noActiveWorkout;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// No description provided for @cancelWorkout.
  ///
  /// In en, this message translates to:
  /// **'Cancel Workout'**
  String get cancelWorkout;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @removeExercise.
  ///
  /// In en, this message translates to:
  /// **'Remove Exercise'**
  String get removeExercise;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimer;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @m.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get m;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// No description provided for @removeSet.
  ///
  /// In en, this message translates to:
  /// **'Remove Set'**
  String get removeSet;

  /// No description provided for @previousBest.
  ///
  /// In en, this message translates to:
  /// **'Previous Best'**
  String get previousBest;

  /// No description provided for @newPR.
  ///
  /// In en, this message translates to:
  /// **'New PR!'**
  String get newPR;

  /// No description provided for @workoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummary;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed'**
  String get workoutCompleted;

  /// No description provided for @totalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get totalSets;

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal Records'**
  String get personalRecords;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @savingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Saving workout...'**
  String get savingWorkout;

  /// No description provided for @finishAnyway.
  ///
  /// In en, this message translates to:
  /// **'Finish Anyway'**
  String get finishAnyway;

  /// No description provided for @incompleteExercises.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Exercises'**
  String get incompleteExercises;

  /// No description provided for @someExercisesIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Some exercises don\'t have any completed sets. Finish anyway?'**
  String get someExercisesIncomplete;

  /// No description provided for @confirmFinish.
  ///
  /// In en, this message translates to:
  /// **'Confirm Finish'**
  String get confirmFinish;

  /// No description provided for @confirmFinishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish this workout?'**
  String get confirmFinishWorkout;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @allWorkouts.
  ///
  /// In en, this message translates to:
  /// **'All Workouts'**
  String get allWorkouts;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @workoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in Progress'**
  String get workoutInProgress;

  /// No description provided for @haveActiveWorkout.
  ///
  /// In en, this message translates to:
  /// **'You have an active workout \"{name}\" in progress.'**
  String haveActiveWorkout(Object name);

  /// No description provided for @startingNewWillEnd.
  ///
  /// In en, this message translates to:
  /// **'Starting a new workout will end the current one.'**
  String get startingNewWillEnd;

  /// No description provided for @doYouWantToContinue.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue?'**
  String get doYouWantToContinue;

  /// No description provided for @forceStartNewWorkout.
  ///
  /// In en, this message translates to:
  /// **'Force Start New Workout'**
  String get forceStartNewWorkout;

  /// No description provided for @clearAndStartNew.
  ///
  /// In en, this message translates to:
  /// **'Clear & Start New'**
  String get clearAndStartNew;

  /// No description provided for @leaveWorkout.
  ///
  /// In en, this message translates to:
  /// **'Leave Workout?'**
  String get leaveWorkout;

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @saveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveAndExit;

  /// No description provided for @discardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard Workout'**
  String get discardWorkout;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @followingExercisesNoSets.
  ///
  /// In en, this message translates to:
  /// **'The following exercises have no completed sets:'**
  String get followingExercisesNoSets;

  /// No description provided for @setsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsCount(Object count);

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @createExercise.
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExercise;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @exerciseType.
  ///
  /// In en, this message translates to:
  /// **'Exercise Type'**
  String get exerciseType;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @muscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Muscle Groups'**
  String get muscleGroups;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @customExercise.
  ///
  /// In en, this message translates to:
  /// **'Custom Exercise'**
  String get customExercise;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @weightReps.
  ///
  /// In en, this message translates to:
  /// **'Weight & Reps'**
  String get weightReps;

  /// No description provided for @bodyweightReps.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Reps'**
  String get bodyweightReps;

  /// No description provided for @weightedBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Weighted Bodyweight'**
  String get weightedBodyweight;

  /// No description provided for @assistedBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Assisted Bodyweight'**
  String get assistedBodyweight;

  /// No description provided for @durationOnly.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationOnly;

  /// No description provided for @durationWeight.
  ///
  /// In en, this message translates to:
  /// **'Duration & Weight'**
  String get durationWeight;

  /// No description provided for @distanceDuration.
  ///
  /// In en, this message translates to:
  /// **'Distance & Duration'**
  String get distanceDuration;

  /// No description provided for @weightDistance.
  ///
  /// In en, this message translates to:
  /// **'Weight & Distance'**
  String get weightDistance;

  /// No description provided for @upperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// No description provided for @lowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// No description provided for @core.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get core;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @flexibility.
  ///
  /// In en, this message translates to:
  /// **'Flexibility'**
  String get flexibility;

  /// No description provided for @olympic.
  ///
  /// In en, this message translates to:
  /// **'Olympic'**
  String get olympic;

  /// No description provided for @powerlifting.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get powerlifting;

  /// No description provided for @bodybuilding.
  ///
  /// In en, this message translates to:
  /// **'Bodybuilding'**
  String get bodybuilding;

  /// No description provided for @crossfit.
  ///
  /// In en, this message translates to:
  /// **'CrossFit'**
  String get crossfit;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @pilates.
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get pilates;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @barbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get barbell;

  /// No description provided for @dumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get dumbbell;

  /// No description provided for @kettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get kettlebell;

  /// No description provided for @machine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get machine;

  /// No description provided for @cable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get cable;

  /// No description provided for @bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get bodyweight;

  /// No description provided for @bands.
  ///
  /// In en, this message translates to:
  /// **'Bands'**
  String get bands;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @leaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get leaderboards;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @writePost.
  ///
  /// In en, this message translates to:
  /// **'Write your post...'**
  String get writePost;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @totalVolumeLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolumeLeaderboard;

  /// No description provided for @workoutCountLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Workout Count'**
  String get workoutCountLeaderboard;

  /// No description provided for @streakLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLeaderboard;

  /// No description provided for @prCountLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'PRs'**
  String get prCountLeaderboard;

  /// No description provided for @thisWeekPeriod.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeekPeriod;

  /// No description provided for @thisMonthPeriod.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthPeriod;

  /// No description provided for @allTimePeriod.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTimePeriod;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @yourStats.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get yourStats;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @totalWorkoutsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts Completed'**
  String get totalWorkoutsCompleted;

  /// No description provided for @totalVolumeLifted.
  ///
  /// In en, this message translates to:
  /// **'Total Volume Lifted'**
  String get totalVolumeLifted;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @volumeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Volume Analysis'**
  String get volumeAnalysis;

  /// No description provided for @strengthBalance.
  ///
  /// In en, this message translates to:
  /// **'Strength Balance'**
  String get strengthBalance;

  /// No description provided for @prPredictions.
  ///
  /// In en, this message translates to:
  /// **'PR Predictions'**
  String get prPredictions;

  /// No description provided for @nearMissPRs.
  ///
  /// In en, this message translates to:
  /// **'Near Miss PRs'**
  String get nearMissPRs;

  /// No description provided for @exerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise Progress'**
  String get exerciseProgress;

  /// No description provided for @plateauDetection.
  ///
  /// In en, this message translates to:
  /// **'Plateau Detection'**
  String get plateauDetection;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @saveWorkout.
  ///
  /// In en, this message translates to:
  /// **'Save Workout'**
  String get saveWorkout;

  /// No description provided for @workoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workoutName;

  /// No description provided for @enterWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Enter workout name'**
  String get enterWorkoutName;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'How did it feel? Any observations?'**
  String get notesPlaceholder;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @shareToSocialFeed.
  ///
  /// In en, this message translates to:
  /// **'Share to Social Feed'**
  String get shareToSocialFeed;

  /// No description provided for @letOthersSee.
  ///
  /// In en, this message translates to:
  /// **'Let others see your accomplishment'**
  String get letOthersSee;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @workoutNotSaved.
  ///
  /// In en, this message translates to:
  /// **'This workout will not be saved. All progress will be lost. Are you sure?'**
  String get workoutNotSaved;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @personalRecord.
  ///
  /// In en, this message translates to:
  /// **'Personal Record'**
  String get personalRecord;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @pleaseEnterWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a workout name'**
  String get pleaseEnterWorkoutName;

  /// No description provided for @exerciseVariant.
  ///
  /// In en, this message translates to:
  /// **'Exercise Variant'**
  String get exerciseVariant;

  /// No description provided for @variantType.
  ///
  /// In en, this message translates to:
  /// **'Variant Type'**
  String get variantType;

  /// No description provided for @changeEquipmentVariant.
  ///
  /// In en, this message translates to:
  /// **'Change equipment/variant'**
  String get changeEquipmentVariant;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @resistanceBand.
  ///
  /// In en, this message translates to:
  /// **'Resistance Band'**
  String get resistanceBand;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @assisted.
  ///
  /// In en, this message translates to:
  /// **'Assisted'**
  String get assisted;

  /// No description provided for @weighted.
  ///
  /// In en, this message translates to:
  /// **'Weighted'**
  String get weighted;

  /// No description provided for @tempo.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get tempo;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'pt':
      return SPt();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
