import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/features/ai/data/services/ai_coaching_service.dart';
import 'package:herq/src/features/ai/presentation/providers/ai_providers.dart';

void main() {
  group('Provider Fix Test', () {
    setUpAll(() async {
      await dotenv.load();
    });

    test('should test AIActions with null Groq service', () async {
      print('🧪 Testing AIActions with null Groq service...');

      final mockService = AICoachingService();
      final aiActions = AIActions(null, mockService);

      final recommendations = await aiActions.getPersonalizedWorkouts(
        'default_user',
        muscleGroups: ['chest'],
        equipment: ['barbell'],
        duration: 60,
      );

      print('✅ AIActions recommendations: ${recommendations.length}');
      expect(recommendations.length, greaterThan(0));

      final recovery = await aiActions.analyzeRecovery('default_user');
      print('✅ AIActions recovery: ${(recovery.recoveryScore * 100).round()}%');
      expect(recovery.recoveryScore, isA<double>());

      final alternatives = await aiActions.findAlternativeExercises(
        'bench_press',
        equipment: ['dumbbell'],
      );
      print('✅ AIActions alternatives: ${alternatives.length}');
      expect(alternatives.length, greaterThan(0));

      print('🎉 All AIActions methods working with null Groq service!');
    });
  });
}
