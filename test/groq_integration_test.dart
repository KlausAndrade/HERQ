import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/src/core/services/groq_service.dart';

void main() {
  group('Groq Service Tests', () {
    late GroqService groqService;

    setUpAll(() async {
      // Load environment variables
      await dotenv.load();
    });

    setUp(() {
      groqService = GroqService();
    });

    test('should send a simple chat message to Groq', () async {
      try {
        final response = await groqService.chat(
          prompt: 'Hello! Just say "Groq AI working" if you can read this.',
          systemPrompt: 'You are a helpful assistant. Be concise.',
        );

        print('✅ Groq Response: $response');
        expect(response, isNotEmpty);
        expect(response.toLowerCase(), contains('groq'));
      } catch (e) {
        print('❌ Groq Test Failed: $e');
        fail('Groq integration test failed: $e');
      }
    });

    test('should generate JSON response', () async {
      try {
        final response = await groqService.chatJson(
          prompt: 'Create a simple workout: {"name": "Test Workout", "exercises": ["Push-ups", "Squats"]}',
          systemPrompt: 'You are a fitness coach. Return only valid JSON.',
        );

        print('✅ Groq JSON Response: $response');
        expect(response, isNotEmpty);
        // Should be valid JSON format
        expect(response.trim().startsWith('{'), isTrue);
      } catch (e) {
        print('❌ Groq JSON Test Failed: $e');
        fail('Groq JSON test failed: $e');
      }
    });
  });
}