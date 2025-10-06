import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/active_workout_provider.dart';

class RestTimerWidget extends ConsumerWidget {
  const RestTimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restTimer = ref.watch(restTimerProvider);

    if (!restTimer.isActive) return const SizedBox.shrink();

    final progress = (restTimer.totalSeconds - restTimer.remainingSeconds) /
        restTimer.totalSeconds;
    final minutes = restTimer.remainingSeconds ~/ 60;
    final seconds = restTimer.remainingSeconds % 60;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rest Timer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(restTimerProvider.notifier).stopTimer();
            },
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
