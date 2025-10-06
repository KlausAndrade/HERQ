import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/database/database.dart';
import 'src/core/providers/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

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
      child: const GymAIApp(),
    ),
  );
}
