import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/src/features/ai/data/services/ai_coaching_service.dart';
import '../lib/src/core/services/groq_service.dart';

void main() {
  group('AI Recommendations Debug', () {
    setUpAll(() async {
      await dotenv.load();
    });

    test('should test mock service recommendations only', () async {
      print('🧪 Testing Mock AI Service...');
      
      final mockService = AICoachingService();
      final recommendations = await mockService.getWorkoutRecommendations(
        'default_user',
        preferredMuscleGroups: ['chest', 'back', 'shoulders'],
        availableEquipment: ['barbell', 'dumbbell', 'bench'],
        maxDuration: 60,
      );
      
      print('✅ Mock recommendations: ${recommendations.length}');
      for (final rec in recommendations) {
        print('   - ${rec.name}: ${rec.exercises.length} exercises');
      }
      
      expect(recommendations.length, greaterThan(0));
      expect(recommendations.first.exercises.length, greaterThan(0));
    });

    test('should test Groq service initialization', () async {
      print('🧪 Testing Groq Service...');
      
      try {
        final groqService = GroqService();
        print('✅ Groq service created successfully');
        
        // Try a simple chat
        final response = await groqService.chat(
          prompt: 'Say "test"',
          systemPrompt: 'Be brief',
        );
        print('✅ Groq response: $response');
        
      } catch (e) {
        print('❌ Groq service failed: $e');
        print('📋 This means fallback to mock should happen');
      }
    });

    test('should test providers logic manually', () async {
      print('🧪 Testing Provider Logic...');
      
      // Simulate what the provider does
      try {
        print('   Trying Groq first...');
        final groqService = GroqService();
        // This will fail if there's an issue
        final response = await groqService.chat(prompt: 'test', systemPrompt: 'test');
        print('✅ Groq working: $response');
        
        // If we get here, Groq should work
        print('   Groq is working, provider should use real AI');
        
      } catch (e) {
        print('❌ Groq failed: $e');
        print('   Should fallback to mock service...');
        
        final mockService = AICoachingService();
        final recommendations = await mockService.getWorkoutRecommendations('default_user');
        print('✅ Mock fallback working: ${recommendations.length} recommendations');
      }
    });
  });
}