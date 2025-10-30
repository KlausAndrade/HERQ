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

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HERQ'**
  String get appTitle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'The title of the application'**
  String get description;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @readyForWorkout.
  ///
  /// In en, this message translates to:
  /// **'Ready for your next workout?'**
  String get readyForWorkout;

  /// No description provided for @welcomeFirstTime.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeFirstTime;

  /// No description provided for @readyForFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Ready for your first workout?'**
  String get readyForFirstWorkout;

  /// No description provided for @loggedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get loggedInSuccessfully;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// No description provided for @prsSet.
  ///
  /// In en, this message translates to:
  /// **'PRs Set'**
  String get prsSet;

  /// No description provided for @recentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent Workouts'**
  String get recentWorkouts;

  /// No description provided for @viewAll.
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
  /// **'Start First Workout'**
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
  /// **'sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
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
  /// **'minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
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

  /// Message shown when user has an active workout
  ///
  /// In en, this message translates to:
  /// **'You have an active workout: {workoutName}'**
  String haveActiveWorkout(String workoutName);

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

  /// No description provided for @viewAchievements.
  ///
  /// In en, this message translates to:
  /// **'View\\nAchievements'**
  String get viewAchievements;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @resumeWorkoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Resume Workout?'**
  String get resumeWorkoutQuestion;

  /// No description provided for @workoutCompleteExclamation.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete!'**
  String get workoutCompleteExclamation;

  /// No description provided for @youCompletedAllExercises.
  ///
  /// In en, this message translates to:
  /// **'You completed all exercises but forgot to finalize:'**
  String get youCompletedAllExercises;

  /// No description provided for @youHaveUnfinishedWorkout.
  ///
  /// In en, this message translates to:
  /// **'You have an unfinished workout:'**
  String get youHaveUnfinishedWorkout;

  /// No description provided for @finishedTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'Finished {timeAgo} ago - don\'t forget to save!'**
  String finishedTimeAgo(Object timeAgo);

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'String'**
  String get type;

  /// No description provided for @pausedTimeAgo.
  ///
  /// In en, this message translates to:
  /// **'Paused {timeAgo} ago'**
  String pausedTimeAgo(Object timeAgo);

  /// No description provided for @tapFinalizeToSave.
  ///
  /// In en, this message translates to:
  /// **'Tap \\'**
  String get tapFinalizeToSave;

  /// No description provided for @wouldYouLikeToContinue.
  ///
  /// In en, this message translates to:
  /// **'Would you like to continue where you left off?'**
  String get wouldYouLikeToContinue;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @finalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get finalize;

  /// No description provided for @resumeWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Resume Workout'**
  String get resumeWorkoutTitle;

  /// No description provided for @continueWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Continue {name}'**
  String continueWorkoutName(Object name);

  /// No description provided for @beginNewSession.
  ///
  /// In en, this message translates to:
  /// **'Begin a new session'**
  String get beginNewSession;

  /// No description provided for @checkYourStats.
  ///
  /// In en, this message translates to:
  /// **'Check your stats'**
  String get checkYourStats;

  /// No description provided for @browseExercises.
  ///
  /// In en, this message translates to:
  /// **'Browse exercises'**
  String get browseExercises;

  /// No description provided for @pastWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Past workouts'**
  String get pastWorkouts;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackYourProgress;

  /// No description provided for @socialFeed.
  ///
  /// In en, this message translates to:
  /// **'Social Feed'**
  String get socialFeed;

  /// No description provided for @friendsAndActivity.
  ///
  /// In en, this message translates to:
  /// **'Friends & activity'**
  String get friendsAndActivity;

  /// No description provided for @aiCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get aiCoach;

  /// No description provided for @smartTrainingHelp.
  ///
  /// In en, this message translates to:
  /// **'Smart training help'**
  String get smartTrainingHelp;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(Object count);

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @exerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

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

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or create a custom exercise'**
  String get tryAdjustingFilters;

  /// No description provided for @errorLoadingExercises.
  ///
  /// In en, this message translates to:
  /// **'Error loading exercises'**
  String get errorLoadingExercises;

  /// No description provided for @viewProgressions.
  ///
  /// In en, this message translates to:
  /// **'View Progressions'**
  String get viewProgressions;

  /// No description provided for @exerciseProgressions.
  ///
  /// In en, this message translates to:
  /// **'Exercise Progressions'**
  String get exerciseProgressions;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @showVariants.
  ///
  /// In en, this message translates to:
  /// **'Show Variants'**
  String get showVariants;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

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
  /// **'YOU'**
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
  /// **'Try Again'**
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

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @createFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Create your first post to share with the community!'**
  String get createFirstPost;

  /// No description provided for @searchForUsers.
  ///
  /// In en, this message translates to:
  /// **'Search for users'**
  String get searchForUsers;

  /// No description provided for @unknownAthlete.
  ///
  /// In en, this message translates to:
  /// **'Unknown Athlete'**
  String get unknownAthlete;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get whatsOnYourMind;

  /// No description provided for @failedToLoadFeed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load feed'**
  String get failedToLoadFeed;

  /// No description provided for @gamificationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Gamification not available'**
  String get gamificationNotAvailable;

  /// No description provided for @xpToLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} / {needed} XP to Level {level}'**
  String xpToLevel(Object level, Object needed, Object xp);

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Achievement Progress'**
  String get achievementProgress;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @workoutMilestones.
  ///
  /// In en, this message translates to:
  /// **'Workout Milestones'**
  String get workoutMilestones;

  /// No description provided for @streakAchievements.
  ///
  /// In en, this message translates to:
  /// **'Streak Achievements'**
  String get streakAchievements;

  /// No description provided for @volumeAchievements.
  ///
  /// In en, this message translates to:
  /// **'Volume Achievements'**
  String get volumeAchievements;

  /// No description provided for @consistencyAchievements.
  ///
  /// In en, this message translates to:
  /// **'Consistency Achievements'**
  String get consistencyAchievements;

  /// No description provided for @specialMilestones.
  ///
  /// In en, this message translates to:
  /// **'Special Milestones'**
  String get specialMilestones;

  /// No description provided for @levelN.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelN(Object level);

  /// No description provided for @xpProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total} XP'**
  String xpProgress(Object current, Object total);

  /// No description provided for @continueExercisesOrFinish.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue these exercises or finish anyway?'**
  String get continueExercisesOrFinish;

  /// No description provided for @shareWorkout.
  ///
  /// In en, this message translates to:
  /// **'Share Workout'**
  String get shareWorkout;

  /// No description provided for @noWorkoutHistory.
  ///
  /// In en, this message translates to:
  /// **'No workout history yet!'**
  String get noWorkoutHistory;

  /// No description provided for @compareCompete.
  ///
  /// In en, this message translates to:
  /// **'Compare & compete'**
  String get compareCompete;

  /// No description provided for @noWorkoutHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No Workout History'**
  String get noWorkoutHistoryTitle;

  /// No description provided for @completeFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Complete your first workout to see your history here'**
  String get completeFirstWorkout;

  /// No description provided for @allCompleted.
  ///
  /// In en, this message translates to:
  /// **'All Completed'**
  String get allCompleted;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @totalVolumeLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolumeLeaderboardTitle;

  /// No description provided for @workoutCountLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Count'**
  String get workoutCountLeaderboardTitle;

  /// No description provided for @streakLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLeaderboardTitle;

  /// No description provided for @prCountLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'PRs'**
  String get prCountLeaderboardTitle;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get recovery;

  /// No description provided for @progressAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressAnalysis;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @applyProgressiveOverload.
  ///
  /// In en, this message translates to:
  /// **'Apply Progressive Overload'**
  String get applyProgressiveOverload;

  /// No description provided for @applySuggestionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Apply this suggestion to your next {exercise} workout?'**
  String applySuggestionQuestion(Object exercise);

  /// No description provided for @suggestedWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight}kg'**
  String suggestedWeight(Object weight);

  /// No description provided for @suggestedReps.
  ///
  /// In en, this message translates to:
  /// **'Reps: {reps}'**
  String suggestedReps(Object reps);

  /// No description provided for @suggestedSets.
  ///
  /// In en, this message translates to:
  /// **'Sets: {sets}'**
  String suggestedSets(Object sets);

  /// No description provided for @workoutTemplates.
  ///
  /// In en, this message translates to:
  /// **'Workout Templates'**
  String get workoutTemplates;

  /// No description provided for @workoutInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout in Progress'**
  String get workoutInProgressTitle;

  /// No description provided for @startingNewWillEndCurrent.
  ///
  /// In en, this message translates to:
  /// **'Starting a new workout will end the current one.'**
  String get startingNewWillEndCurrent;

  /// No description provided for @startNewWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start New Workout'**
  String get startNewWorkout;

  /// No description provided for @defaultTemplates.
  ///
  /// In en, this message translates to:
  /// **'Default Templates'**
  String get defaultTemplates;

  /// No description provided for @pushDay.
  ///
  /// In en, this message translates to:
  /// **'Push Day'**
  String get pushDay;

  /// No description provided for @pullDay.
  ///
  /// In en, this message translates to:
  /// **'Pull Day'**
  String get pullDay;

  /// No description provided for @legDay.
  ///
  /// In en, this message translates to:
  /// **'Leg Day'**
  String get legDay;

  /// No description provided for @pushDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Chest, shoulders, and triceps workout'**
  String get pushDayDescription;

  /// No description provided for @pullDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Back and biceps workout'**
  String get pullDayDescription;

  /// No description provided for @legDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Quads, hamstrings, and calves workout'**
  String get legDayDescription;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @fixingDisplayNames.
  ///
  /// In en, this message translates to:
  /// **'Fixing display names...'**
  String get fixingDisplayNames;

  /// No description provided for @removeEmailsFromDisplayNames.
  ///
  /// In en, this message translates to:
  /// **'This will remove all emails from user display names and replace them with \\'**
  String get removeEmailsFromDisplayNames;

  /// No description provided for @thisFixesLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'This fixes leaderboards showing emails instead of names.'**
  String get thisFixesLeaderboards;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @fixNames.
  ///
  /// In en, this message translates to:
  /// **'Fix Names'**
  String get fixNames;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @createManage.
  ///
  /// In en, this message translates to:
  /// **'Create & Manage'**
  String get createManage;

  /// No description provided for @viewProgressHistory.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgressHistory;

  /// No description provided for @errorLoadingLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Error loading leaderboard'**
  String get errorLoadingLeaderboard;

  /// No description provided for @noLeaderboardData.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available'**
  String get noLeaderboardData;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// No description provided for @recentPersonalRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent Personal Records'**
  String get recentPersonalRecords;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @variations.
  ///
  /// In en, this message translates to:
  /// **'Variations'**
  String get variations;

  /// No description provided for @progression.
  ///
  /// In en, this message translates to:
  /// **'Progression'**
  String get progression;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @previousSet.
  ///
  /// In en, this message translates to:
  /// **'Previous Set'**
  String get previousSet;

  /// No description provided for @nextSet.
  ///
  /// In en, this message translates to:
  /// **'Next Set'**
  String get nextSet;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @kgLifted.
  ///
  /// In en, this message translates to:
  /// **'kg lifted'**
  String get kgLifted;

  /// No description provided for @avgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg Duration'**
  String get avgDuration;

  /// No description provided for @progressCharts.
  ///
  /// In en, this message translates to:
  /// **'Progress Charts'**
  String get progressCharts;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get newFolder;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @myTemplates.
  ///
  /// In en, this message translates to:
  /// **'My Templates'**
  String get myTemplates;

  /// No description provided for @sharedTemplates.
  ///
  /// In en, this message translates to:
  /// **'Shared Templates'**
  String get sharedTemplates;

  /// No description provided for @workoutOptions.
  ///
  /// In en, this message translates to:
  /// **'Workout Options'**
  String get workoutOptions;

  /// No description provided for @repeatWorkout.
  ///
  /// In en, this message translates to:
  /// **'Repeat Workout'**
  String get repeatWorkout;

  /// No description provided for @editNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit Notes'**
  String get editNotes;

  /// No description provided for @deleteWorkout.
  ///
  /// In en, this message translates to:
  /// **'Delete Workout'**
  String get deleteWorkout;

  /// No description provided for @addWorkoutNotes.
  ///
  /// In en, this message translates to:
  /// **'Add workout notes...'**
  String get addWorkoutNotes;

  /// No description provided for @unknownExercise.
  ///
  /// In en, this message translates to:
  /// **'Unknown Exercise'**
  String get unknownExercise;

  /// No description provided for @exerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise Not Found'**
  String get exerciseNotFound;

  /// No description provided for @exerciseNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found'**
  String get exerciseNotFoundMessage;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @quickWorkout.
  ///
  /// In en, this message translates to:
  /// **'Quick Workout'**
  String get quickWorkout;

  /// No description provided for @addToWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add to Workout'**
  String get addToWorkout;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @enterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get enterDisplayName;

  /// No description provided for @pleaseEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get pleaseEnterDisplayName;

  /// No description provided for @nameAtLeast2Chars.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameAtLeast2Chars;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @bioMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Bio must be less than 200 characters'**
  String get bioMaxLength;

  /// No description provided for @privateAccount.
  ///
  /// In en, this message translates to:
  /// **'Private Account'**
  String get privateAccount;

  /// No description provided for @privateAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'When your account is private, only followers can see your posts'**
  String get privateAccountDescription;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Your email cannot be changed. Contact support if you need assistance.'**
  String get emailCannotBeChanged;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed'**
  String get profileUpdateFailed;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @editExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExerciseTitle;

  /// No description provided for @exerciseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name *'**
  String get exerciseNameRequired;

  /// No description provided for @exerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Barbell Bench Press'**
  String get exerciseNameHint;

  /// No description provided for @pleaseEnterExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an exercise name'**
  String get pleaseEnterExerciseName;

  /// No description provided for @nameAtLeast3Chars.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get nameAtLeast3Chars;

  /// No description provided for @primaryMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Primary Muscle Group *'**
  String get primaryMuscleGroup;

  /// No description provided for @secondaryMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscle Groups'**
  String get secondaryMuscleGroups;

  /// No description provided for @equipmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Equipment *'**
  String get equipmentRequired;

  /// No description provided for @bodyweightExercise.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight Exercise'**
  String get bodyweightExercise;

  /// No description provided for @exerciseTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Exercise Type *'**
  String get exerciseTypeRequired;

  /// No description provided for @difficultyRequired.
  ///
  /// In en, this message translates to:
  /// **'Difficulty *'**
  String get difficultyRequired;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get categoryRequired;

  /// No description provided for @isThisVariant.
  ///
  /// In en, this message translates to:
  /// **'Is this a variant?'**
  String get isThisVariant;

  /// No description provided for @howToPerform.
  ///
  /// In en, this message translates to:
  /// **'How to perform this exercise...'**
  String get howToPerform;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

  /// No description provided for @pleaseFixErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors before saving'**
  String get pleaseFixErrors;

  /// No description provided for @missingName.
  ///
  /// In en, this message translates to:
  /// **'Missing name'**
  String get missingName;

  /// No description provided for @exerciseNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Exercise name is required'**
  String get exerciseNameRequiredError;

  /// No description provided for @databaseNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Database not available'**
  String get databaseNotAvailable;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deletePostConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirmation;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @glutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get glutes;

  /// No description provided for @calves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get calves;

  /// No description provided for @forearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get forearms;

  /// No description provided for @traps.
  ///
  /// In en, this message translates to:
  /// **'Traps'**
  String get traps;

  /// No description provided for @medicineBall.
  ///
  /// In en, this message translates to:
  /// **'Medicine Ball'**
  String get medicineBall;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @calisthenics.
  ///
  /// In en, this message translates to:
  /// **'Calisthenics'**
  String get calisthenics;

  /// No description provided for @regression.
  ///
  /// In en, this message translates to:
  /// **'Regression'**
  String get regression;

  /// No description provided for @strict.
  ///
  /// In en, this message translates to:
  /// **'Strict'**
  String get strict;

  /// No description provided for @angle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get angle;

  /// No description provided for @compound.
  ///
  /// In en, this message translates to:
  /// **'Compound'**
  String get compound;

  /// No description provided for @isolation.
  ///
  /// In en, this message translates to:
  /// **'Isolation'**
  String get isolation;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @pull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get pull;

  /// No description provided for @unilateral.
  ///
  /// In en, this message translates to:
  /// **'Unilateral'**
  String get unilateral;

  /// No description provided for @bilateral.
  ///
  /// In en, this message translates to:
  /// **'Bilateral'**
  String get bilateral;

  /// No description provided for @stability.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get stability;

  /// No description provided for @power.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power;

  /// No description provided for @hypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get hypertrophy;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @selectWorkout.
  ///
  /// In en, this message translates to:
  /// **'Select a Workout'**
  String get selectWorkout;

  /// No description provided for @workoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete'**
  String get workoutComplete;

  /// No description provided for @exerciseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Exercise Breakdown'**
  String get exerciseBreakdown;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Strength. Simplified.'**
  String get appTagline;

  /// HERQ brand story
  ///
  /// In en, this message translates to:
  /// **'Inspired by the spirit of Heracles — the original symbol of strength and perseverance — HERQ fuses ancient power with modern intelligence. Built for lifters, movers, and everyday heroes who believe strength isn\'t just physical — it\'s a mindset.'**
  String get brandStory;

  /// HERQ brand mission statement
  ///
  /// In en, this message translates to:
  /// **'Whether you\'re chasing your first pull-up or your next PR, HERQ helps you train smarter, recover better, and rise stronger.'**
  String get brandMission;

  /// Label for color theme selection
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// Default color theme option
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultTheme;

  /// HERQ color theme option
  ///
  /// In en, this message translates to:
  /// **'HERQ'**
  String get herqTheme;

  /// About HERQ menu item
  ///
  /// In en, this message translates to:
  /// **'About HERQ'**
  String get aboutHerq;

  /// Default share message for posts
  ///
  /// In en, this message translates to:
  /// **'Check out this post on {appName}!'**
  String checkOutThisPost(String appName);

  /// Share subject line for posts
  ///
  /// In en, this message translates to:
  /// **'Post from {appName}'**
  String postFrom(String appName);

  /// App tagline for auth screen
  ///
  /// In en, this message translates to:
  /// **'Your intelligent workout companion'**
  String get yourIntelligentWorkoutCompanion;

  /// Subtitle for web simple version
  ///
  /// In en, this message translates to:
  /// **'Mobile-First Workout Tracker'**
  String get mobileFirstWorkoutTracker;

  /// Web message about mobile optimization
  ///
  /// In en, this message translates to:
  /// **'{appName} is optimized for mobile devices with full offline support and native features.'**
  String optimizedForMobile(String appName);

  /// No description provided for @buildWorkout.
  ///
  /// In en, this message translates to:
  /// **'Build Workout'**
  String get buildWorkout;

  /// No description provided for @optimizeWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Optimize Workouts'**
  String get optimizeWorkouts;

  /// No description provided for @evaluateProgress.
  ///
  /// In en, this message translates to:
  /// **'Evaluate Progress'**
  String get evaluateProgress;

  /// No description provided for @buildMyNextWorkout.
  ///
  /// In en, this message translates to:
  /// **'Build My Next Workout'**
  String get buildMyNextWorkout;

  /// No description provided for @evaluateMyProgress.
  ///
  /// In en, this message translates to:
  /// **'Evaluate My Progress'**
  String get evaluateMyProgress;

  /// No description provided for @getProfessionalAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Get professional AI analysis of your training'**
  String get getProfessionalAnalysis;

  /// No description provided for @startEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Start Evaluation'**
  String get startEvaluation;

  /// No description provided for @evaluateProgressInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. AI analyzes your last 30 workout sessions\n2. Evaluates muscle group distribution and balance\n3. Assesses training frequency and recovery patterns\n4. Identifies your training goals based on data\n5. Provides direct, professional feedback on weaknesses\n6. Suggests specific, actionable improvements'**
  String get evaluateProgressInstructions;

  /// No description provided for @evaluateProgressWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This AI provides professional, brutally honest feedback. It will directly point out training gaps, muscle imbalances, and poor frequency without sugar-coating. Prepare for constructive criticism.'**
  String get evaluateProgressWarning;

  /// No description provided for @analyzingTrainingHistory.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your training history...'**
  String get analyzingTrainingHistory;

  /// No description provided for @thisMayTakeMoment.
  ///
  /// In en, this message translates to:
  /// **'This may take a moment'**
  String get thisMayTakeMoment;

  /// No description provided for @evaluationFailed.
  ///
  /// In en, this message translates to:
  /// **'Evaluation Failed'**
  String get evaluationFailed;

  /// No description provided for @failedToAnalyzeProgress.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze your progress: {error}'**
  String failedToAnalyzeProgress(String error);

  /// No description provided for @progressEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Progress Evaluation'**
  String get progressEvaluation;

  /// No description provided for @overallAssessment.
  ///
  /// In en, this message translates to:
  /// **'Overall Assessment'**
  String get overallAssessment;

  /// No description provided for @strengths.
  ///
  /// In en, this message translates to:
  /// **'Strengths'**
  String get strengths;

  /// No description provided for @areasNeedingAttention.
  ///
  /// In en, this message translates to:
  /// **'Areas Needing Attention'**
  String get areasNeedingAttention;

  /// No description provided for @muscleGroupBalance.
  ///
  /// In en, this message translates to:
  /// **'Muscle Group Balance'**
  String get muscleGroupBalance;

  /// No description provided for @detectedTrainingGoal.
  ///
  /// In en, this message translates to:
  /// **'Detected Training Goal'**
  String get detectedTrainingGoal;

  /// No description provided for @professionalRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Professional Recommendations'**
  String get professionalRecommendations;

  /// No description provided for @evaluationAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'Already Evaluated Today'**
  String get evaluationAlreadyDone;

  /// No description provided for @evaluationAlreadyDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already received your progress evaluation today. Complete a workout and come back tomorrow for a fresh analysis!'**
  String get evaluationAlreadyDoneMessage;

  /// No description provided for @seeAgain.
  ///
  /// In en, this message translates to:
  /// **'See Again'**
  String get seeAgain;

  /// No description provided for @generateMyNextWorkout.
  ///
  /// In en, this message translates to:
  /// **'Generate My Next Workout'**
  String get generateMyNextWorkout;

  /// No description provided for @optimizeMyWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Optimize My Workouts'**
  String get optimizeMyWorkouts;

  /// No description provided for @generatedWorkout.
  ///
  /// In en, this message translates to:
  /// **'Generated Workout'**
  String get generatedWorkout;

  /// No description provided for @optimizedWorkoutFolder.
  ///
  /// In en, this message translates to:
  /// **'Optimized Workout Folder'**
  String get optimizedWorkoutFolder;

  /// No description provided for @failedToGenerateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Failed to Generate Workout'**
  String get failedToGenerateWorkout;

  /// No description provided for @aiServiceBusy.
  ///
  /// In en, this message translates to:
  /// **'AI service is busy. Please wait a moment and try again.'**
  String get aiServiceBusy;

  /// No description provided for @aiReturnedInvalidData.
  ///
  /// In en, this message translates to:
  /// **'AI returned invalid data. Please try again.'**
  String get aiReturnedInvalidData;

  /// No description provided for @aiServiceConfigurationError.
  ///
  /// In en, this message translates to:
  /// **'AI service configuration error. Please contact support.'**
  String get aiServiceConfigurationError;

  /// No description provided for @requestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get requestTimedOut;

  /// No description provided for @noWorkoutHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No workout history found. Please complete some workouts first.'**
  String get noWorkoutHistoryFound;

  /// No description provided for @workoutFolderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout folder not found. Please refresh and try again.'**
  String get workoutFolderNotFound;

  /// No description provided for @noTemplatesFoundInFolder.
  ///
  /// In en, this message translates to:
  /// **'No workout templates found in this folder.'**
  String get noTemplatesFoundInFolder;

  /// No description provided for @failedToParseAiResponse.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse AI response. The AI may have returned invalid JSON. Please try again.'**
  String get failedToParseAiResponse;

  /// No description provided for @failedToSaveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to save template'**
  String get failedToSaveTemplate;

  /// No description provided for @failedToStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Failed to start workout'**
  String get failedToStartWorkout;

  /// No description provided for @failedToReplaceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to replace template'**
  String get failedToReplaceTemplate;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// No description provided for @startingAiGeneratedWorkout.
  ///
  /// In en, this message translates to:
  /// **'Starting AI-generated workout...'**
  String get startingAiGeneratedWorkout;

  /// No description provided for @aiGeneratedWorkoutCreated.
  ///
  /// In en, this message translates to:
  /// **'AI Generated Workout was created'**
  String get aiGeneratedWorkoutCreated;

  /// No description provided for @aiGeneratedWorkoutCreatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personalized workout has been generated based on your training history.'**
  String get aiGeneratedWorkoutCreatedDescription;

  /// No description provided for @saveAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get saveAsTemplate;

  /// No description provided for @saveOptimizedTemplates.
  ///
  /// In en, this message translates to:
  /// **'Save Optimized Templates'**
  String get saveOptimizedTemplates;

  /// No description provided for @replaceOriginalTemplates.
  ///
  /// In en, this message translates to:
  /// **'Replace Original Templates'**
  String get replaceOriginalTemplates;

  /// No description provided for @aiReasoning.
  ///
  /// In en, this message translates to:
  /// **'AI Reasoning'**
  String get aiReasoning;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated Duration'**
  String get estimatedDuration;

  /// No description provided for @aiGenerated.
  ///
  /// In en, this message translates to:
  /// **'AI Generated'**
  String get aiGenerated;

  /// No description provided for @endurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get endurance;

  /// No description provided for @skill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get skill;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @upper.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get upper;

  /// No description provided for @lower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lower;

  /// No description provided for @fullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get fullBody;

  /// No description provided for @incline.
  ///
  /// In en, this message translates to:
  /// **'Incline'**
  String get incline;

  /// No description provided for @deficit.
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get deficit;

  /// No description provided for @sumo.
  ///
  /// In en, this message translates to:
  /// **'Sumo'**
  String get sumo;

  /// No description provided for @neutralGrip.
  ///
  /// In en, this message translates to:
  /// **'Neutral Grip'**
  String get neutralGrip;

  /// No description provided for @warmup.
  ///
  /// In en, this message translates to:
  /// **'Warmup'**
  String get warmup;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get working;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @backoff.
  ///
  /// In en, this message translates to:
  /// **'Backoff'**
  String get backoff;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works:'**
  String get howItWorks;

  /// No description provided for @selectFolderToOptimize.
  ///
  /// In en, this message translates to:
  /// **'Select folder to optimize'**
  String get selectFolderToOptimize;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @analyzingAndOptimizing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing and optimizing...'**
  String get analyzingAndOptimizing;

  /// No description provided for @generatingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Generating workout'**
  String get generatingWorkout;

  /// No description provided for @generatePersonalizedWorkout.
  ///
  /// In en, this message translates to:
  /// **'Generate a personalized workout based on your training history'**
  String get generatePersonalizedWorkout;

  /// No description provided for @buildWorkoutInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. AI analyzes your last 14 workout sessions\n2. Identifies training patterns and progression\n3. Generates a personalized workout plan\n4. Save as template or start immediately'**
  String get buildWorkoutInstructions;

  /// No description provided for @generatingPersonalizedWorkout.
  ///
  /// In en, this message translates to:
  /// **'Generating your personalized workout...'**
  String get generatingPersonalizedWorkout;

  /// No description provided for @aiPoweredOptimization.
  ///
  /// In en, this message translates to:
  /// **'AI-powered optimization of your existing workout routines'**
  String get aiPoweredOptimization;

  /// No description provided for @optimizeWorkoutInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Select a workout folder from your templates\n2. AI analyzes all templates in the folder\n3. Get optimized versions with improvements\n4. Save as new templates or replace originals'**
  String get optimizeWorkoutInstructions;

  /// No description provided for @failedToOptimizeFolder.
  ///
  /// In en, this message translates to:
  /// **'Failed to optimize folder'**
  String get failedToOptimizeFolder;

  /// No description provided for @viewWorkout.
  ///
  /// In en, this message translates to:
  /// **'View Workout'**
  String get viewWorkout;

  /// No description provided for @workoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get workoutDetails;

  /// No description provided for @noExerciseDetailsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exercise details available'**
  String get noExerciseDetailsAvailable;

  /// No description provided for @saveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save Template'**
  String get saveTemplate;

  /// No description provided for @enterTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this workout template:'**
  String get enterTemplateName;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @templateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Leg Day - Classic'**
  String get templateNameHint;

  /// No description provided for @pleaseEnterTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get pleaseEnterTemplateName;

  /// No description provided for @templateNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Template name must be at least 3 characters'**
  String get templateNameMinLength;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template Saved'**
  String get templateSaved;

  /// No description provided for @templateSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Workout saved as \"{templateName}\" template!'**
  String templateSavedSuccess(String templateName);

  /// No description provided for @workoutStarted.
  ///
  /// In en, this message translates to:
  /// **'Workout Started'**
  String get workoutStarted;

  /// No description provided for @startingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Starting {workoutName} with {count} exercises...'**
  String startingWorkout(String workoutName, int count);

  /// No description provided for @noWorkoutDataFound.
  ///
  /// In en, this message translates to:
  /// **'No workout data found'**
  String get noWorkoutDataFound;

  /// No description provided for @postedToSocialFeed.
  ///
  /// In en, this message translates to:
  /// **'Posted to social feed'**
  String get postedToSocialFeed;

  /// No description provided for @yourWorkoutHasBeenShared.
  ///
  /// In en, this message translates to:
  /// **'Your workout has been shared!'**
  String get yourWorkoutHasBeenShared;

  /// No description provided for @failedToShareWorkout.
  ///
  /// In en, this message translates to:
  /// **'Failed to share workout'**
  String get failedToShareWorkout;

  /// No description provided for @shareToSocial.
  ///
  /// In en, this message translates to:
  /// **'Share to social'**
  String get shareToSocial;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @unfollowed.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed'**
  String get unfollowed;

  /// No description provided for @youUnfollowed.
  ///
  /// In en, this message translates to:
  /// **'You unfollowed {userName}'**
  String youUnfollowed(String userName);

  /// No description provided for @youAreNowFollowing.
  ///
  /// In en, this message translates to:
  /// **'You are now following {userName}'**
  String youAreNowFollowing(String userName);

  /// No description provided for @failedToFollowUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to follow user'**
  String get failedToFollowUser;

  /// No description provided for @failedToUnfollowUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to unfollow user'**
  String get failedToUnfollowUser;

  /// No description provided for @thisUser.
  ///
  /// In en, this message translates to:
  /// **'this user'**
  String get thisUser;
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
