import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_models.dart';

/// Mock subscription service (RevenueCat temporarily disabled due to iOS build issues)
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

  /// Initialize subscription service (mock implementation)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('Initializing SubscriptionService (mock)...');
      // In a real app, this would initialize RevenueCat
      // await Purchases.setLogLevel(LogLevel.debug);
      // await Purchases.configure(PurchasesConfiguration("public_sdk_key"));
      
      // Load current subscription status
      await _loadCurrentSubscription();
      
      _isInitialized = true;
      print('✅ SubscriptionService (mock) initialized');
    } catch (e) {
      print('❌ Error initializing subscription service: $e');
      await _loadSubscriptionFromPrefs();
      _isInitialized = true;
    }
  }

  /// Load current subscription from local storage
  Future<void> _loadCurrentSubscription() async {
    try {
      await _loadSubscriptionFromPrefs();
    } catch (e) {
      print('❌ Error loading subscription: $e');
      // Use default free subscription
      _currentSubscription = Subscription(
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.none,
        expiresAt: DateTime(2099, 12, 31),
      );
      _subscriptionController.add(_currentSubscription);
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

  /// Start free trial (mock implementation)
  Future<bool> startFreeTrial() async {
    try {
      print('Starting mock free trial...');
      // In a real app, this would initiate a trial purchase via RevenueCat
      // For now, simulate success
      _currentSubscription = _currentSubscription.copyWith(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.trial,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        trialEndsAt: DateTime.now().add(const Duration(days: 7)),
        isTrialActive: true,
      );
      
      await _saveSubscriptionToPrefs();
      _subscriptionController.add(_currentSubscription);
      print('✅ Mock free trial started successfully');
      return true;
    } catch (e) {
      print('❌ Error starting free trial: $e');
      return false;
    }
  }

  /// Purchase subscription (mock implementation)
  Future<bool> purchaseSubscription(String productId) async {
    try {
      print('Purchasing mock product: $productId');
      // In a real app, this would initiate a purchase via RevenueCat
      // For now, simulate success
      _currentSubscription = _currentSubscription.copyWith(
        tier: SubscriptionTier.pro,
        status: SubscriptionStatus.active,
        expiresAt: DateTime.now().add(const Duration(days: 30)), // Approx 1 month
        isTrialActive: false,
      );
      
      await _saveSubscriptionToPrefs();
      _subscriptionController.add(_currentSubscription);
      print('✅ Mock product purchased successfully');
      return true;
    } catch (e) {
      print('❌ Error purchasing subscription: $e');
      return false;
    }
  }

  /// Restore purchases (mock implementation)
  Future<bool> restorePurchases() async {
    try {
      print('Restoring mock purchases...');
      // In a real app, this would restore purchases via RevenueCat
      // For now, simulate no purchases to restore
      print('No mock purchases to restore');
      return false;
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
        currencyCode: 'USD',
        duration: 1, // months
        tier: SubscriptionTier.pro,
        isPopular: false,
        discountPercentage: null,
      ),
      SubscriptionProduct(
        id: 'herq_pro_quarterly',
        title: 'HERQ Pro Quarterly',
        description: '3 months of premium features',
        price: 24.99,
        currencyCode: 'USD',
        duration: 3,
        tier: SubscriptionTier.pro,
        isPopular: true,
        discountPercentage: 5,
      ),
      SubscriptionProduct(
        id: 'herq_pro_yearly',
        title: 'HERQ Pro Yearly',
        description: '12 months of premium features',
        price: 99.99,
        currencyCode: 'USD',
        duration: 12,
        tier: SubscriptionTier.pro,
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