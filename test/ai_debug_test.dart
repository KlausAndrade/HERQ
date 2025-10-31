import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/services/groq_service.dart';
import 'package:herq/src/features/ai/data/services/ai_coaching_service.dart';

void main() {
  group('AI Debug Tests', () {
    setUpAll(() async {
      // Load environment variables
      await dotenv.load();
    });

    test('should check Groq service initialization', () async {
      try {
        final groqService = GroqService();
        print('✅ Groq service initialized successfully');

        final response = await groqService.chat(
          prompt: 'Hello',
          systemPrompt: 'You are helpful. Just say "Working".',
        );
        print('✅ Groq response: $response');
      } catch (e) {
        print('❌ Groq initialization failed: $e');
        print('📋 This means the fallback mock service should be used');

        // Test mock service works
        final mockService = AICoachingService();
        final mockRecs = await mockService.getWorkoutRecommendations(
          'test_user',
        );
        print('✅ Mock service has ${mockRecs.length} recommendations');
      }
    });

    test('should check mock recovery analysis', () async {
      final mockService = AICoachingService();
      final recovery = await mockService.getRecoveryAnalysis('current_user');

      print('📊 Mock Recovery Analysis:');
      print('   Recovery Score: ${(recovery.recoveryScore * 100).round()}%');
      print('   Fatigue Level: ${recovery.fatigueLevel}');
      print('   Recommendations: ${recovery.recommendations.length}');
      print('   Next Workout: ${recovery.nextWorkoutSuggestion}');

      // Check why it might be showing poor recovery
      for (final rec in recovery.recommendations) {
        print('   - ${rec.type}: ${rec.title}');
      }
    });
  });
}
