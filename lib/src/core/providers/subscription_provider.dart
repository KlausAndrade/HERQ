import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

/// Subscription service provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Current subscription provider
final currentSubscriptionProvider = StreamProvider<Subscription>((ref) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return subscriptionService.subscriptionStream;
});

/// Subscription products provider
final subscriptionProductsProvider = FutureProvider<List<SubscriptionProduct>>((ref) async {
  final subscriptionService = ref.watch(subscriptionServiceProvider);
  return await subscriptionService.getAvailableProducts();
});

/// AI usage tracking provider
final aiUsageProvider = StateNotifierProvider<AIUsageNotifier, AIUsage>((ref) {
  return AIUsageNotifier();
});

/// Template usage tracking provider
final templateUsageProvider = StateNotifierProvider<TemplateUsageNotifier, TemplateUsage>((ref) {
  return TemplateUsageNotifier();
});

/// Premium features access provider
final premiumAccessProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.isPro || sub.isElite,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// AI usage limits provider
final aiUsageLimitsProvider = Provider<AIUsageLimits>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  
  return subscription.when(
    data: (sub) {
      if (sub.isPro || sub.isElite) {
        return AIUsageLimits(
          maxDailyEvaluations: -1, // Unlimited
          maxDailyWorkoutBuilds: -1, // Unlimited
          maxDailyOptimizations: -1, // Unlimited
        );
      } else {
        return AIUsageLimits(
          maxDailyEvaluations: 1,
          maxDailyWorkoutBuilds: 0,
          maxDailyOptimizations: 0,
        );
      }
    },
    loading: () => AIUsageLimits(
      maxDailyEvaluations: 1,
      maxDailyWorkoutBuilds: 0,
      maxDailyOptimizations: 0,
    ),
    error: (_, __) => AIUsageLimits(
      maxDailyEvaluations: 1,
      maxDailyWorkoutBuilds: 0,
      maxDailyOptimizations: 0,
    ),
  );
});

/// Template limits provider
final templateLimitsProvider = Provider<TemplateLimits>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  
  return subscription.when(
    data: (sub) {
      if (sub.isPro || sub.isElite) {
        return TemplateLimits(maxTemplates: -1); // Unlimited
      } else {
        return TemplateLimits(maxTemplates: 3); // Free tier limit
      }
    },
    loading: () => TemplateLimits(maxTemplates: 3),
    error: (_, __) => TemplateLimits(maxTemplates: 3),
  );
});

/// AI Usage Notifier
class AIUsageNotifier extends StateNotifier<AIUsage> {
  AIUsageNotifier() : super(AIUsage(
    dailyEvaluations: 0,
    dailyWorkoutBuilds: 0,
    dailyOptimizations: 0,
    lastResetDate: DateTime.now(),
  )) {
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString('ai_usage_last_reset');
    final now = DateTime.now();
    
    // Reset daily usage if it's a new day
    if (lastReset == null || 
        DateTime.parse(lastReset).day != now.day ||
        DateTime.parse(lastReset).month != now.month ||
        DateTime.parse(lastReset).year != now.year) {
      await _resetDailyUsage();
    } else {
      // Load existing usage
      final evaluations = prefs.getInt('ai_daily_evaluations') ?? 0;
      final workoutBuilds = prefs.getInt('ai_daily_workout_builds') ?? 0;
      final optimizations = prefs.getInt('ai_daily_optimizations') ?? 0;
      
      state = AIUsage(
        dailyEvaluations: evaluations,
        dailyWorkoutBuilds: workoutBuilds,
        dailyOptimizations: optimizations,
        lastResetDate: DateTime.parse(lastReset),
      );
    }
  }

  Future<void> _resetDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    await prefs.setString('ai_usage_last_reset', now.toIso8601String());
    await prefs.setInt('ai_daily_evaluations', 0);
    await prefs.setInt('ai_daily_workout_builds', 0);
    await prefs.setInt('ai_daily_optimizations', 0);
    
    state = AIUsage(
      dailyEvaluations: 0,
      dailyWorkoutBuilds: 0,
      dailyOptimizations: 0,
      lastResetDate: now,
    );
  }

  Future<void> recordAIEvaluation() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = state.dailyEvaluations + 1;
    await prefs.setInt('ai_daily_evaluations', newCount);
    
    state = state.copyWith(dailyEvaluations: newCount);
  }

  Future<void> recordWorkoutBuild() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = state.dailyWorkoutBuilds + 1;
    await prefs.setInt('ai_daily_workout_builds', newCount);
    
    state = state.copyWith(dailyWorkoutBuilds: newCount);
  }

  Future<void> recordOptimization() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = state.dailyOptimizations + 1;
    await prefs.setInt('ai_daily_optimizations', newCount);
    
    state = state.copyWith(dailyOptimizations: newCount);
  }
}

/// Template Usage Notifier
class TemplateUsageNotifier extends StateNotifier<TemplateUsage> {
  TemplateUsageNotifier() : super(const TemplateUsage(
    totalTemplates: 0,
    maxTemplates: 3,
  ));

  void updateTemplateCount(int count) {
    state = TemplateUsage(
      totalTemplates: count,
      maxTemplates: state.maxTemplates,
    );
  }

  void setMaxTemplates(int max) {
    state = TemplateUsage(
      totalTemplates: state.totalTemplates,
      maxTemplates: max,
    );
  }
}

/// AI Usage Limits
class AIUsageLimits {
  const AIUsageLimits({
    required this.maxDailyEvaluations,
    required this.maxDailyWorkoutBuilds,
    required this.maxDailyOptimizations,
  });

  final int maxDailyEvaluations;
  final int maxDailyWorkoutBuilds;
  final int maxDailyOptimizations;

  bool get hasUnlimitedEvaluations => maxDailyEvaluations == -1;
  bool get hasUnlimitedWorkoutBuilds => maxDailyWorkoutBuilds == -1;
  bool get hasUnlimitedOptimizations => maxDailyOptimizations == -1;
}

/// Template Limits
class TemplateLimits {
  const TemplateLimits({
    required this.maxTemplates,
  });

  final int maxTemplates;

  bool get hasUnlimitedTemplates => maxTemplates == -1;
}
