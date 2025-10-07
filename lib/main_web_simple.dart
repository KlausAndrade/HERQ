import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Web-specific entry point for GymAI
/// Simplified web version - full app requires native platform
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
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
      child: GymAIWebApp(),
    ),
  );
}

class GymAIWebApp extends StatelessWidget {
  const GymAIWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymAI - Workout Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const WebComingSoonScreen(),
    );
  }
}

class WebComingSoonScreen extends StatelessWidget {
  const WebComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'GymAI',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mobile-First Workout Tracker',
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
                          const Icon(Icons.construction, color: Colors.orange),
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
                      const Text(
                        'GymAI is optimized for mobile devices with full offline support and native features.',
                        style: TextStyle(fontSize: 16),
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
                      _buildFeatureList(),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Available Features:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
  }

  Widget _buildFeatureList() {
    return Column(
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
  }

  Widget _buildAvailableFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem('🌐 Cloud sync with Supabase'),
        _buildFeatureItem('🔐 Authentication ready'),
        _buildFeatureItem('📊 Real-time data updates'),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
