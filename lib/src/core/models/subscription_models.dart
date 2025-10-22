import 'package:equatable/equatable.dart';

/// Subscription tier enumeration
enum SubscriptionTier {
  free,
  pro,
  elite,
}

/// Subscription status enumeration
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  trial,
  none,
}

/// Subscription model
class Subscription extends Equatable {
  const Subscription({
    required this.tier,
    required this.status,
    required this.expiresAt,
    this.trialEndsAt,
    this.isTrialActive = false,
    this.autoRenew = false,
  });

  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime expiresAt;
  final DateTime? trialEndsAt;
  final bool isTrialActive;
  final bool autoRenew;

  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.trial;
  bool get isPro => tier == SubscriptionTier.pro && isActive;
  bool get isElite => tier == SubscriptionTier.elite && isActive;
  bool get isFree => tier == SubscriptionTier.free || !isActive;

  @override
  List<Object?> get props => [tier, status, expiresAt, trialEndsAt, isTrialActive, autoRenew];
}

/// Subscription product model
class SubscriptionProduct extends Equatable {
  const SubscriptionProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currencyCode,
    required this.duration,
    required this.tier,
    this.discountPercentage,
    this.isPopular = false,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String currencyCode;
  final int duration; // in months
  final SubscriptionTier tier;
  final int? discountPercentage;
  final bool isPopular;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get durationText {
    if (duration == 1) return '1 month';
    if (duration == 3) return '3 months';
    if (duration == 6) return '6 months';
    if (duration == 12) return '1 year';
    return '$duration months';
  }

  @override
  List<Object?> get props => [id, title, description, price, currencyCode, duration, tier, discountPercentage, isPopular];
}

/// AI usage tracking model
class AIUsage extends Equatable {
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

  bool get hasReachedDailyLimit => dailyEvaluations >= 1; // Free tier limit
  bool get canUseAI => !hasReachedDailyLimit;

  AIUsage copyWith({
    int? dailyEvaluations,
    int? dailyWorkoutBuilds,
    int? dailyOptimizations,
    DateTime? lastResetDate,
  }) {
    return AIUsage(
      dailyEvaluations: dailyEvaluations ?? this.dailyEvaluations,
      dailyWorkoutBuilds: dailyWorkoutBuilds ?? this.dailyWorkoutBuilds,
      dailyOptimizations: dailyOptimizations ?? this.dailyOptimizations,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  @override
  List<Object?> get props => [dailyEvaluations, dailyWorkoutBuilds, dailyOptimizations, lastResetDate];
}

/// Template usage tracking model
class TemplateUsage extends Equatable {
  const TemplateUsage({
    required this.totalTemplates,
    required this.maxTemplates,
  });

  final int totalTemplates;
  final int maxTemplates;

  bool get hasReachedLimit => totalTemplates >= maxTemplates;
  bool get canCreateTemplate => !hasReachedLimit;

  @override
  List<Object?> get props => [totalTemplates, maxTemplates];
}
