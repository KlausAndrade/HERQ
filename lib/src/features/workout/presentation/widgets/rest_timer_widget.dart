import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
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
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
      scale: isAlmostDone ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAlmostDone
                ? [
                    Theme.of(context).colorScheme.error.withOpacity(0.8),
                    Theme.of(context).colorScheme.error,
                  ]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: [
            BoxShadow(
              color: (isAlmostDone
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary)
                  .withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAlmostDone ? 'Almost Done!' : 'Rest Timer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await HapticService.lightImpact();
                    ref.read(restTimerProvider.notifier).stopTimer();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
