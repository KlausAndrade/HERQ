import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get facebookAppId => dotenv.env['FACEBOOK_ID'] ?? '';
  static String get facebookClientToken =>
      dotenv.env['FACEBOOK_CLIENT_TOKEN'] ?? '';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
