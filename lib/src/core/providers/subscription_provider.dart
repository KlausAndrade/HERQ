import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

/// Subscription service provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

/// Current subscription provider
final currentSubscriptionProvider = StreamProvider<Subscription>((ref) {
  final service = ref.read(subscriptionServiceProvider);
  return service.subscriptionStream;
});

/// Subscription status provider
final subscriptionStatusProvider = Provider<SubscriptionStatus>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.status,
    loading: () => SubscriptionStatus.none,
    error: (_, __) => SubscriptionStatus.none,
  );
});

/// Subscription tier provider
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.tier,
    loading: () => SubscriptionTier.free,
    error: (_, __) => SubscriptionTier.free,
  );
});

/// Is premium provider
final isPremiumProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.isPro || sub.isElite,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Is trial provider
final isTrialProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.isTrialActive,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Available products provider
final availableProductsProvider = FutureProvider<List<SubscriptionProduct>>((ref) async {
  final service = ref.read(subscriptionServiceProvider);
  return await service.getAvailableProducts();
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
          hasUnlimitedEvaluations: true,
          hasUnlimitedWorkoutBuilds: true,
          hasUnlimitedOptimizations: true,
        );
      } else {
        return AIUsageLimits(
          maxDailyEvaluations: 1, // Free tier limit
          maxDailyWorkoutBuilds: 1, // Free tier limit
          maxDailyOptimizations: 1, // Free tier limit
          hasUnlimitedEvaluations: false,
          hasUnlimitedWorkoutBuilds: false,
          hasUnlimitedOptimizations: false,
        );
      }
    },
    loading: () => AIUsageLimits(
      maxDailyEvaluations: 1,
      maxDailyWorkoutBuilds: 1,
      maxDailyOptimizations: 1,
      hasUnlimitedEvaluations: false,
      hasUnlimitedWorkoutBuilds: false,
      hasUnlimitedOptimizations: false,
    ),
    error: (_, __) => AIUsageLimits(
      maxDailyEvaluations: 1,
      maxDailyWorkoutBuilds: 1,
      maxDailyOptimizations: 1,
      hasUnlimitedEvaluations: false,
      hasUnlimitedWorkoutBuilds: false,
      hasUnlimitedOptimizations: false,
    ),
  );
});

/// Template limits provider
final templateLimitsProvider = Provider<TemplateLimits>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  
  return subscription.when(
    data: (sub) {
      if (sub.isPro || sub.isElite) {
        return TemplateLimits(
          maxTemplates: -1, // Unlimited
          hasUnlimitedTemplates: true,
        );
      } else {
        return TemplateLimits(
          maxTemplates: 3, // Free tier limit
          hasUnlimitedTemplates: false,
        );
      }
    },
    loading: () => TemplateLimits(
      maxTemplates: 3,
      hasUnlimitedTemplates: false,
    ),
    error: (_, __) => TemplateLimits(
      maxTemplates: 3,
      hasUnlimitedTemplates: false,
    ),
  );
});

/// AI Usage model
class AIUsage {
  const AIUsage({
    required this.dailyEvaluations,
    required this.dailyWorkoutBuilds,
    required this.dailyOptimizations,
    required this.lastResetDate,
  });

  final int dailyEvaluations;
  final int dailyWorkoutBuilds;
  final int dailyOptimizations;
  final DateTime lastResetDate;
}

/// AI Usage Limits model
class AIUsageLimits {
  const AIUsageLimits({
    required this.maxDailyEvaluations,
    required this.maxDailyWorkoutBuilds,
    required this.maxDailyOptimizations,
    required this.hasUnlimitedEvaluations,
    required this.hasUnlimitedWorkoutBuilds,
    required this.hasUnlimitedOptimizations,
  });

  final int maxDailyEvaluations;
  final int maxDailyWorkoutBuilds;
  final int maxDailyOptimizations;
  final bool hasUnlimitedEvaluations;
  final bool hasUnlimitedWorkoutBuilds;
  final bool hasUnlimitedOptimizations;
}

/// Template Limits model
class TemplateLimits {
  const TemplateLimits({
    required this.maxTemplates,
    required this.hasUnlimitedTemplates,
  });

  final int maxTemplates;
  final bool hasUnlimitedTemplates;
}

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
    // This would load from SharedPreferences
    // For now, we'll use default values
  }

  void recordAIEvaluation() {
    state = AIUsage(
      dailyEvaluations: state.dailyEvaluations + 1,
      dailyWorkoutBuilds: state.dailyWorkoutBuilds,
      dailyOptimizations: state.dailyOptimizations,
      lastResetDate: state.lastResetDate,
    );
  }

  void recordWorkoutBuild() {
    state = AIUsage(
      dailyEvaluations: state.dailyEvaluations,
      dailyWorkoutBuilds: state.dailyWorkoutBuilds + 1,
      dailyOptimizations: state.dailyOptimizations,
      lastResetDate: state.lastResetDate,
    );
  }

  void recordOptimization() {
    state = AIUsage(
      dailyEvaluations: state.dailyEvaluations,
      dailyWorkoutBuilds: state.dailyWorkoutBuilds,
      dailyOptimizations: state.dailyOptimizations + 1,
      lastResetDate: state.lastResetDate,
    );
  }
}

/// AI Usage provider
final aiUsageProvider = StateNotifierProvider<AIUsageNotifier, AIUsage>((ref) {
  return AIUsageNotifier();
});