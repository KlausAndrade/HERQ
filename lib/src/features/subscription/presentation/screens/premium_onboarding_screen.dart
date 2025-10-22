import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/models/subscription_models.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/widgets/swipe_back_wrapper.dart';
import '../widgets/subscription_product_card.dart';
import '../widgets/premium_features_list.dart';

class PremiumOnboardingScreen extends ConsumerStatefulWidget {
  const PremiumOnboardingScreen({super.key});

  @override
  ConsumerState<PremiumOnboardingScreen> createState() => _PremiumOnboardingScreenState();
}

class _PremiumOnboardingScreenState extends ConsumerState<PremiumOnboardingScreen> {
  String? _selectedProductId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final productsAsync = ref.watch(subscriptionProductsProvider);
    final subscription = ref.watch(currentSubscriptionProvider);

    return SwipeBackWrapperWithFeedback(
      onSwipeBack: () => context.go('/'),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/'),
          ),
          title: Text(l10n.upgradeToPro),
          centerTitle: true,
        ),
        body: subscription.when(
          data: (sub) {
            if (sub.isPro || sub.isElite) {
              return _buildAlreadyPremiumView(context, l10n);
            }
            return _buildUpgradeView(context, l10n, productsAsync);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildErrorView(context, l10n),
        ),
        bottomNavigationBar: _buildBottomBar(context, l10n),
      ),
    );
  }

  Widget _buildAlreadyPremiumView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.alreadyPremium,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.alreadyPremiumMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: Text(l10n.continueToApp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeView(BuildContext context, AppLocalizations l10n, AsyncValue<List<SubscriptionProduct>> productsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.unlockPremiumFeatures,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.premiumFeaturesDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Premium Features
          PremiumFeaturesList(),
          const SizedBox(height: 24),

          // Subscription Products
          Text(
            l10n.chooseYourPlan,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          productsAsync.when(
            data: (products) => _buildProductsList(products),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildErrorView(context, l10n),
          ),

          const SizedBox(height: 24),

          // Free Trial Info
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.freeTrialAvailable,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.freeTrialDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<SubscriptionProduct> products) {
    return Column(
      children: products.map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SubscriptionProductCard(
            product: product,
            isSelected: _selectedProductId == product.id,
            onTap: () {
              setState(() {
                _selectedProductId = product.id;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingProducts,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingProductsMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(subscriptionProductsProvider);
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context, AppLocalizations l10n) {
    final subscription = ref.watch(currentSubscriptionProvider);
    
    return subscription.when(
      data: (sub) {
        if (sub.isPro || sub.isElite) return null;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedProductId != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _startFreeTrial,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.startFreeTrial),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.trialTerms,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.selectAPlan),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<void> _startFreeTrial() async {
    if (_selectedProductId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final success = await subscriptionService.startFreeTrial(_selectedProductId!);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)!.trialStarted),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to home
        context.go('/');
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)!.trialStartFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
