import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herq/src/core/ui/notification_redesign/notification_card.dart';

void main() {
  testWidgets('NotificationCard renders and action buttons call callbacks', (
    WidgetTester tester,
  ) async {
    var primaryPressed = false;
    var secondaryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCard(
            id: 't1',
            title: 'Test Title',
            body:
                'This is the body of the notification used during widget tests.',
            leading: const Icon(Icons.info),
            primaryActionLabel: 'Open',
            onPrimaryAction: () => primaryPressed = true,
            secondaryActionLabel: 'Dismiss',
            onSecondaryAction: () => secondaryPressed = true,
          ),
        ),
      ),
    );

    // Should find title and body texts
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.textContaining('This is the body'), findsOneWidget);

    // Tap secondary
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(secondaryPressed, isTrue);

    // Tap primary
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(primaryPressed, isTrue);

    // Accessibility: ensure the semantics label is present
    final semantic = tester.getSemantics(find.byType(NotificationCard));
    // Ensure the semantics label contains the title so screen readers announce it.
    expect(semantic.label, isNotEmpty);
    expect(semantic.label, contains('Test Title'));
  });
}
