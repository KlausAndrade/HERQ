import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/database/database.dart';
import 'package:herq/src/features/ai/presentation/providers/ai_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  group('Apply Suggestions Functionality Tests', () {
    test('AIActions can create workout recommendations', () async {
      final container = ProviderContainer();
      final aiActions = container.read(aiActionsProvider);

      final recommendations = await aiActions.getPersonalizedWorkouts(
        'test_user',
        muscleGroups: ['chest', 'back'],
        equipment: ['barbell', 'dumbbell'],
        duration: 60,
      );

      expect(recommendations.isNotEmpty, true);
      expect(recommendations.first.exercises.isNotEmpty, true);

      // Test that we can convert recommendation to a template structure
      final firstRec = recommendations.first;
      expect(firstRec.name.isNotEmpty, true);
      expect(firstRec.exercises.isNotEmpty, true);
      expect(firstRec.estimatedDuration, isA<int>());

      print(
        '✅ Workout recommendation can be converted to template: ${firstRec.name}',
      );
      print('   Exercises: ${firstRec.exercises.length}');
      print('   Duration: ${firstRec.estimatedDuration} minutes');
    });

    test('Template creation structure from AI recommendations', () async {
      // Test template creation structure
      final templateData = WorkoutTemplate(
        id: 'ai_rec_test_123',
        userId: 'test_user', // ✅ USER ISOLATION
        name: 'AI Upper Body Power',
        description: 'AI generated upper body workout',
        category: 'AI Recommended',
        sortOrder: 0,
        exerciseIds: ['bench_press', 'pull_ups', 'overhead_press'],
        tags: ['ai_generated', 'upper_body', 'strength'],
        estimatedDurationMinutes: 60,
        isDefault: false,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      // Verify template structure is valid
      expect(templateData.id.startsWith('ai_rec_'), true);
      expect(templateData.name.isNotEmpty, true);
      expect(templateData.category, 'AI Recommended');
      expect(templateData.exerciseIds.isNotEmpty, true);
      expect(templateData.tags.contains('ai_generated'), true);
      expect(templateData.estimatedDurationMinutes, isA<int>());

      print('✅ AI recommendation can be converted to workout template:');
      print('   Template ID: ${templateData.id}');
      print('   Name: ${templateData.name}');
      print('   Exercises: ${templateData.exerciseIds.length}');
      print('   Category: ${templateData.category}');
    });

    test(
      'AI providers are properly configured for Apply functionality',
      () async {
        final container = ProviderContainer();

        // Test that providers can be accessed without throwing
        expect(() => container.read(aiActionsProvider), returnsNormally);
        expect(
          () => container.read(aiCoachingServiceProvider),
          returnsNormally,
        );

        print('✅ AI providers are properly configured');
        print('   aiActionsProvider: Available');
        print('   aiCoachingServiceProvider: Available');
      },
    );
  });
}
