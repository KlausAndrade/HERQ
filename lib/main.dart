import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/database/database.dart';
import 'src/core/providers/database_provider.dart';
import 'src/core/services/notification_service.dart'
    if (dart.library.html) 'src/core/services/notification_service_stub.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log deployment information
  final now = DateTime.now();
  const version = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  const buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: '');
  const buildNumber =
      String.fromEnvironment('BUILD_NUMBER', defaultValue: 'dev');

  print('');
  print('═══════════════════════════════════════════════════');
  print('🚀 HERQ - AI-Powered Workout Tracker');
  print('📦 Version: $version+$buildNumber');
  print(
      '📅 Deployed at: ${buildDate.isNotEmpty ? buildDate : now.toIso8601String()}');
  print('🌍 Platform: ${kIsWeb ? "Web" : "Mobile"}');
  print('👤 Author: Klaus Andrade');
  print('═══════════════════════════════════════════════════');
  print('');

  // Load environment variables (gracefully handle missing .env file)
  try {
    await dotenv.load();
  } catch (e) {
    print('ℹ️ No .env file found, using compile-time config');
  }

  // Get Supabase credentials from compile-time constants (--dart-define)
  // or fall back to .env file
  const supabaseUrlConst = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  const supabaseAnonKeyConst = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  final supabaseUrl = supabaseUrlConst.isNotEmpty
      ? supabaseUrlConst
      : (dotenv.env['SUPABASE_URL'] ?? '');
  final supabaseAnonKey = supabaseAnonKeyConst.isNotEmpty
      ? supabaseAnonKeyConst
      : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('⚠️ Supabase configuration missing. App will run in offline mode.');
  } else {
    print('✅ Supabase configured: ${supabaseUrl.substring(0, 20)}...');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize notifications (only on native platforms)
  if (!kIsWeb) {
    await NotificationService().initialize();
  }

  // Initialize local database only for non-web platforms
  AppDatabase? database;
  if (!kIsWeb) {
    database = AppDatabase();
  }

  runApp(
    ProviderScope(
      overrides: [
        if (database != null) databaseProvider.overrideWithValue(database),
      ],
      child: const HerqApp(),
    ),
  );
}
