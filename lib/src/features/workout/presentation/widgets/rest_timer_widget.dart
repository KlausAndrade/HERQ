import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/haptic_service.dart';
import '../providers/active_workout_provider.dart';

class RestTimerWidget extends ConsumerStatefulWidget {
  const RestTimerWidget({super.key});

  @override
  ConsumerState<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends ConsumerState<RestTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restTimer = ref.watch(restTimerProvider);

    if (!restTimer.isActive) return const SizedBox.shrink();

    final progress = (restTimer.totalSeconds - restTimer.remainingSeconds) /
        restTimer.totalSeconds;
    final minutes = restTimer.remainingSeconds ~/ 60;
    final seconds = restTimer.remainingSeconds % 60;

    // Determine if we're in the last 10 seconds for extra emphasis
    final isAlmostDone = restTimer.remainingSeconds <= 10;

    return ScaleTransition(
      scale: isAlmostDone ? _pulseAnimation : const AlwaysStoppedAnimation(1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAlmostDone
                ? [
                    Theme.of(context)
                        .colorScheme
                        .error
                        .withAlpha((0.9 * 255).round()),
                    Theme.of(context)
                        .colorScheme
                        .error
                        .withAlpha((0.7 * 255).round()),
                  ]
                : [
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.9 * 255).round()),
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.7 * 255).round()),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (isAlmostDone
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary)
                  .withAlpha((0.2 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Compact circular progress (32x32)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor:
                            Colors.white.withAlpha((0.3 * 255).round()),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Compact text display
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        isAlmostDone ? '⏰ ' : '💤 ',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              height: 1,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAlmostDone ? 'Almost!' : 'Rest',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Colors.white.withAlpha((0.8 * 255).round()),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                // Compact close button
                IconButton(
                  onPressed: () async {
                    await HapticService.lightImpact();
                    ref.read(restTimerProvider.notifier).stopTimer();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  iconSize: 18,
                  splashRadius: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
