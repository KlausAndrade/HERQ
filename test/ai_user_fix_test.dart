import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/features/ai/data/services/ai_coaching_service.dart';

void main() {
  group('AI User ID Fix Tests', () {
    setUpAll(() async {
      await dotenv.load();
    });

    test('should verify mock service works with default_user', () async {
      final mockService = AICoachingService();

      // Test workout recommendations
      final recommendations = await mockService.getWorkoutRecommendations(
        'default_user',
      );
      print('✅ Mock recommendations: ${recommendations.length} workouts');
      expect(recommendations.length, greaterThan(0));

      // Test recovery analysis
      final recovery = await mockService.getRecoveryAnalysis('default_user');
      print(
        '✅ Mock recovery: ${(recovery.recoveryScore * 100).round()}% score',
      );
      expect(recovery.recoveryScore, isA<double>());

      // Test progressive overload
      final overload = await mockService.getProgressiveOverloadSuggestions(
        'default_user',
        'bench_press',
      );
      print('✅ Mock overload: ${overload.length} suggestions');
      expect(overload.length, greaterThan(0));

      // Test general suggestions
      final suggestions = await mockService.getGeneralSuggestions(
        'default_user',
      );
      print('✅ Mock suggestions: ${suggestions.length} tips');
      expect(suggestions.length, greaterThan(0));

      print('\n🎉 All AI features working with default_user ID!');
    });
  });
}
