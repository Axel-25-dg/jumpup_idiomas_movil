// lib/presentation/screens/admin/subscriptions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_subscription_model.dart';
import 'package:jumpup_app/presentation/providers/subscription_provider.dart';
import 'package:jumpup_app/presentation/providers/stats_provider.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> with TickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment(int subscriptionId) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final notifier = ref.read(subscriptionNotifierProvider.notifier);
      final url = await notifier.initiateCheckout(subscriptionId);

      // ✅ Guardar contexto en variable local
      final currentContext = context;
      if (currentContext.mounted) {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
          
          // Payment waiting feedback
          if (currentContext.mounted) {
            _showPaymentWaitingDialog(currentContext);
          }
        } else {
          if (currentContext.mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              const SnackBar(
                content: Text('Cannot open payment link'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      // ✅ Save context in local variable
      final currentContext = context;
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('❌ Error initiating payment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showPaymentWaitingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF7C4DFF)),
            SizedBox(width: 16),
            Text('Processing payment', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Please complete the payment in your browser. '
          'Once finished, press the button to verify.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.invalidate(adminStatsProvider);
              ref.read(subscriptionNotifierProvider.notifier).refresh();
            },
            child: const Text('I HAVE PAID',
                style: TextStyle(color: Color(0xFF7C4DFF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionNotifierProvider);
    final notifier = ref.read(subscriptionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Premium Plans',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Blobs
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (30 * _blobController.value),
                    right: -50 + (20 * _blobController.value),
                    child: _blob(const Color(0xFF7C4DFF), 350, 0.12),
                  ),
                  Positioned(
                    bottom: 100 - (30 * _blobController.value),
                    left: -80 + (15 * _blobController.value),
                    child: _blob(const Color(0xFF00B0FF), 300, 0.08),
                  ),
                ],
              );
            },
          ),

          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            onRefresh: () => notifier.refresh(),
            child: LoadingOverlay(
              isLoading: subscriptionsAsync.isLoading,
              child: subscriptionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                ),
                error: (error, _) => _buildErrorView(error, notifier),
                data: (plans) {
                  if (plans.isEmpty) {
                    return const EmptyState(
                      title: 'No plans available',
                      subtitle: 'Premium plans will appear here',
                      icon: Icons.workspace_premium_rounded,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 40, 16, 40),
                    physics: const BouncingScrollPhysics(),
                    itemCount: plans.length,
                    itemBuilder: (ctx, index) {
                      final plan = plans[index];
                      return _SubscriptionCard(
                        plan: plan,
                        onSubscribe: () => _handlePayment(plan.id),
                        isProcessing: _isProcessing,
                        ref: ref,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity + 0.05),
              blurRadius: 100,
              spreadRadius: 20,
            ),
          ],
        ),
      );

  Widget _buildErrorView(Object error, SubscriptionNotifier notifier) {
    return Center(
      child: GlassContainer(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        blur: 24,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Error loading plans',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Retry',
                onPressed: () => notifier.refresh(),
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.plan,
    required this.onSubscribe,
    required this.isProcessing,
    required this.ref,
  });

  final Subscription plan;
  final VoidCallback onSubscribe;
  final bool isProcessing;
  final WidgetRef ref;

  Color _getPlanColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('gold') || lowerName.contains('premium') || lowerName.contains('pro')) {
      return const Color(0xFFFFD700);
    }
    if (lowerName.contains('silver')) {
      return const Color(0xFFC0C0C0);
    }
    if (lowerName.contains('bronze')) {
      return const Color(0xFFCD7F32);
    }
    return AppColors.primary;
  }

  List<String> _parseFeatures(String features) {
    if (features.contains(',')) {
      return features.split(',').map((f) => f.trim()).toList();
    }
    if (features.contains('\n')) {
      return features.split('\n').map((f) => f.trim()).toList();
    }
    return [features];
  }

  void _showPaymentWaitingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(width: 16),
            Text('Processing payment'),
          ],
        ),
        content: const Text(
          'Please complete the payment in your browser. '
          'Once finished, press the button to verify.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.invalidate(adminStatsProvider);
              ref.read(subscriptionNotifierProvider.notifier).refresh();
            },
            child: const Text('I HAVE PAID'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planColor = _getPlanColor(plan.name);
    final features = _parseFeatures(plan.features);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(24),
        blur: 20,
        opacity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [planColor.withValues(alpha: 0.8), planColor.withValues(alpha: 0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.durationDays} days duration',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '\$${plan.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Features
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Included benefits:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: planColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Subscribe Now',
                  onPressed: isProcessing ? null : onSubscribe,
                  loading: isProcessing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
