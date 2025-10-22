import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_models.dart';

/// Simplified subscription service (without RevenueCat for now)
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isInitialized = false;
  late StreamController<Subscription> _subscriptionController = StreamController<Subscription>.broadcast();
  
  Stream<Subscription> get subscriptionStream => _subscriptionController.stream;
  Subscription _currentSubscription = Subscription(
    tier: SubscriptionTier.free,
    status: SubscriptionStatus.none,
    expiresAt: DateTime(2099, 12, 31), // Far future date for free tier
  );

  Subscription get currentSubscription => _currentSubscription;

  /// Initialize subscription service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // For now, just load from SharedPreferences
      await _loadSubscriptionFromPrefs();
      _isInitialized = true;
      print('✅ Subscription service initialized (simplified mode)');
    } catch (e) {
      print('❌ Error initializing subscription service: $e');
    }
  }

  /// Load subscription from SharedPreferences
  Future<void> _loadSubscriptionFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tierString = prefs.getString('subscription_tier') ?? 'free';
    final statusString = prefs.getString('subscription_status') ?? 'none';
    final expiresAtString = prefs.getString('subscription_expires_at');
    
    final tier = SubscriptionTier.values.firstWhere(
      (t) => t.name == tierString,
      orElse: () => SubscriptionTier.free,
    );
    
    final status = SubscriptionStatus.values.firstWhere(
      (s) => s.name == statusString,
      orElse: () => SubscriptionStatus.none,
    );
    
    final expiresAt = expiresAtString != null 
        ? DateTime.parse(expiresAtString)
        : DateTime(2099, 12, 31);
    
    _currentSubscription = Subscription(
      tier: tier,
      status: status,
      expiresAt: expiresAt,
    );
    
    _subscriptionController.add(_currentSubscription);
  }

  /// Save subscription to SharedPreferences
  Future<void> _saveSubscriptionToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_tier', _currentSubscription.tier.name);
    await prefs.setString('subscription_status', _currentSubscription.status.name);
    await prefs.setString('subscription_expires_at', _currentSubscription.expiresAt.toIso8601String());
  }

  /// Start free trial
  Future<bool> startFreeTrial() async {
    try {
      _currentSubscription = Subscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.trial,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );
      
      await _saveSubscriptionToPrefs();
      _subscriptionController.add(_currentSubscription);
      
      print('✅ Free trial started');
      return true;
    } catch (e) {
      print('❌ Error starting free trial: $e');
      return false;
    }
  }

  /// Purchase subscription (mock implementation)
  Future<bool> purchaseSubscription(String productId) async {
    try {
      // Mock purchase - in real app, this would integrate with RevenueCat
      _currentSubscription = Subscription(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.active,
        expiresAt: DateTime.now().add(const Duration(days: 30)), // 1 month
      );
      
      await _saveSubscriptionToPrefs();
      _subscriptionController.add(_currentSubscription);
      
      print('✅ Subscription purchased: $productId');
      return true;
    } catch (e) {
      print('❌ Error purchasing subscription: $e');
      return false;
    }
  }

  /// Restore purchases (mock implementation)
  Future<bool> restorePurchases() async {
    try {
      // Mock restore - in real app, this would check RevenueCat
      await _loadSubscriptionFromPrefs();
      print('✅ Purchases restored');
      return true;
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      return false;
    }
  }

  /// Get available products (mock implementation)
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    // Mock products - in real app, this would fetch from RevenueCat
    return [
      SubscriptionProduct(
        id: 'herq_pro_monthly',
        title: 'HERQ Pro Monthly',
        description: 'Unlimited AI coaching and premium features',
        price: 9.99,
        duration: 1, // months
        isPopular: false,
        discountPercentage: null,
      ),
      SubscriptionProduct(
        id: 'herq_pro_quarterly',
        title: 'HERQ Pro Quarterly',
        description: '3 months of premium features',
        price: 24.99,
        duration: 3,
        isPopular: true,
        discountPercentage: 5,
      ),
      SubscriptionProduct(
        id: 'herq_pro_yearly',
        title: 'HERQ Pro Yearly',
        description: '12 months of premium features',
        price: 99.99,
        duration: 12,
        isPopular: false,
        discountPercentage: 20,
      ),
    ];
  }

  /// Check if user has active subscription
  bool get hasActiveSubscription => 
      _currentSubscription.status == SubscriptionStatus.active ||
      _currentSubscription.status == SubscriptionStatus.trial;

  /// Check if user is on trial
  bool get isOnTrial => _currentSubscription.status == SubscriptionStatus.trial;

  /// Check if subscription is expired
  bool get isExpired => 
      _currentSubscription.status == SubscriptionStatus.active &&
      DateTime.now().isAfter(_currentSubscription.expiresAt);

  /// Dispose resources
  void dispose() {
    _subscriptionController.close();
  }
}