import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:herq/src/core/services/snackbar_service.dart';
import 'package:herq/src/core/services/notification_service.dart';
import 'package:herq/src/core/ui/notification_redesign/in_app_notification.dart';

void main() {
  testWidgets('SnackbarService.showFromSnackBar emits in-app notification and shows SnackBar',
      (WidgetTester tester) async {
    // Await the next in-app notification from the NotificationService stream.
    // Using `first` is simpler and avoids managing a Completer/subscription.

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  SnackbarService.showFromSnackBar(
                    context,
                    const SnackBar(content: Text('Hello from snack')),
                    preserveFallback: true,
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

  // Subscribe to the next in-app notification before triggering the action
  final notifFuture = NotificationService().inAppStream.first.timeout(const Duration(seconds: 5));

  // Trigger the button which calls showFromSnackBar
  await tester.tap(find.text('Show'));
  await tester.pump();

  // Wait for the in-app notification emission
  final notif = await notifFuture;
  expect(notif.title, contains('Hello from snack'));

  // Advance the frame to let the SnackBar animation run and appear
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('Hello from snack'), findsOneWidget);
  });
}
