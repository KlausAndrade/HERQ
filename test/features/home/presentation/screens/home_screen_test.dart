import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/features/home/presentation/screens/home_screen.dart';

import '../../../../helpers/test_db_helper.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('should display welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: overrideWithTestProviders(),
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Ready for your next workout?'), findsOneWidget);
    });

    testWidgets('should display quick action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: overrideWithTestProviders(),
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('View Progress'), findsOneWidget);
      expect(find.text('Exercise Library'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('should display bottom navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: overrideWithTestProviders(),
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
