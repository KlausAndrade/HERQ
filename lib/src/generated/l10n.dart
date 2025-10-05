// This is a generated file. Do not edit manually.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;
      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) => Localizations.of(context, S);

  String get appTitle => 'GymAI';
  String get welcomeBack => 'Welcome back!';
  String get readyForWorkout => 'Ready for your next workout?';
  String get quickActions => 'Quick Actions';
  String get startWorkout => 'Start Workout';
  String get viewProgress => 'View Progress';
  String get exerciseLibrary => 'Exercise Library';
  String get history => 'History';
  String get thisWeek => 'This Week';
  String get workouts => 'Workouts';
  String get totalVolume => 'Total Volume';
  String get prsSet => 'PRs Set';
  String get recentWorkouts => 'Recent Workouts';
  String get viewAll => 'View All';
  String get home => 'Home';
  String get exercises => 'Exercises';
  String get progress => 'Progress';
  String get settings => 'Settings';
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales => const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

Future<bool> initializeMessages(String localeName) async => true;