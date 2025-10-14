import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';

/// Web-specific entry point for HERQ
/// Simplified web version - full app requires native platform
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load();

    // Initialize Supabase for web
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    print('✅ Web platform initialized with Supabase');
  } catch (e) {
    print('⚠️ Web initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: HerqWebApp(),
    ),
  );
}

class HerqWebApp extends StatelessWidget {
  const HerqWebApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'HERQ - Smart Strength Training',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BFA6),
          ), // HERQ Teal
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BFA6), // HERQ Teal
            brightness: Brightness.dark,
          ),
        ),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('pt'),
        ],
        home: const WebComingSoonScreen(),
      );
}

class WebComingSoonScreen extends StatelessWidget {
  const WebComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 120,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                Text(
                  S.of(context)!.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  S.of(context)!.mobileFirstWorkoutTracker,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.construction,
                                color: Colors.orange),
                            const SizedBox(width: 12),
                            Text(
                              'Web Version Coming Soon',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          S
                              .of(context)!
                              .optimizedForMobile(S.of(context)!.appTitle),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '📱 Download the mobile app for the complete experience:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Web users can see the URL in app store badges below
                            // Direct navigation: window.location.href = 'https://herq.app'
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Learn more at herq.app'),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureList(),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Available Features:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        _buildAvailableFeatures(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Link to App Store
                      },
                      icon: const Icon(Icons.apple),
                      label: const Text('iOS App'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Link to Play Store
                      },
                      icon: const Icon(Icons.android),
                      label: const Text('Android App'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFeatureList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem('✅ Offline-first workout tracking'),
          _buildFeatureItem('✅ Comprehensive exercise library'),
          _buildFeatureItem('✅ Progress analytics & charts'),
          _buildFeatureItem('✅ Social features & leaderboards'),
          _buildFeatureItem('✅ AI-powered coaching insights'),
          _buildFeatureItem('✅ Custom workout templates'),
        ],
      );

  Widget _buildAvailableFeatures() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem('🌐 Cloud sync with Supabase'),
          _buildFeatureItem('🔐 Authentication ready'),
          _buildFeatureItem('📊 Real-time data updates'),
        ],
      );

  Widget _buildFeatureItem(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      );
}
