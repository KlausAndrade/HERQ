import 'package:flutter/material.dart';
import 'notification_card.dart';

class NotificationDemoScreen extends StatelessWidget {
  const NotificationDemoScreen({super.key});

  void _onPrimary() {
    // In a real app this would navigate or perform an action.
  }

  void _onSecondary() {
    // Secondary action (dismiss / snooze)
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notification Demo')),
    body: ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Example notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        NotificationCard(
          id: 'n1',
          title: 'Workout complete — Great job!',
          body:
              'You finished "Upper Body Strength" and set a new PR on Bench Press. Tap to view details.',
          leading: const Icon(Icons.check_circle, color: Colors.green),
          primaryActionLabel: 'View',
          onPrimaryAction: _onPrimary,
          secondaryActionLabel: 'Dismiss',
          onSecondaryAction: _onSecondary,
        ),
        NotificationCard(
          id: 'n2',
          title: 'Reminder: Finish your workout',
          body:
              'You started a workout 45 minutes ago and didn\'t finish. Would you like to resume?',
          leading: const Icon(Icons.timer, color: Colors.orange),
          primaryActionLabel: 'Resume',
          onPrimaryAction: _onPrimary,
          secondaryActionLabel: 'Snooze',
          onSecondaryAction: _onSecondary,
        ),
        NotificationCard(
          id: 'n3',
          title: 'New program available',
          body:
              'Try the 8-week hypertrophy program hand-curated by our coaches.',
          leading: const Icon(Icons.fitness_center),
          primaryActionLabel: 'Explore',
          onPrimaryAction: _onPrimary,
        ),
      ],
    ),
  );
}
