// lib/presentation/screens/admin/subscriptions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_subscription_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/subscription_provider.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _isProcessing = false;

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
        } else {
          if (currentContext.mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              const SnackBar(
                content: Text('No se puede abrir el enlace de pago'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      // ✅ Guardar contexto en variable local
      final currentContext = context;
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('❌ Error al iniciar pago: $e'),
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

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionNotifierProvider);
    final notifier = ref.read(subscriptionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Planes Premium'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: LoadingOverlay(
          isLoading: subscriptionsAsync.isLoading,
          child: subscriptionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => _buildErrorView(error, notifier),
            data: (plans) {
              if (plans.isEmpty) {
                return const EmptyState(
                  title: 'No hay planes disponibles',
                  subtitle: 'Los planes premium se mostrarán aquí',
                  icon: Icons.workspace_premium_rounded,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: plans.length,
                itemBuilder: (ctx, index) {
                  final plan = plans[index];
                  return _SubscriptionCard(
                    plan: plan,
                    onSubscribe: () => _handlePayment(plan.id),
                    isProcessing: _isProcessing,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error, SubscriptionNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar planes', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.plan,
    required this.onSubscribe,
    required this.isProcessing,
  });

  final Subscription plan;
  final VoidCallback onSubscribe;
  final bool isProcessing;

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

  @override
  Widget build(BuildContext context) {
    final planColor = _getPlanColor(plan.name);
    final features = _parseFeatures(plan.features);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: planColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: planColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [planColor, planColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.durationDays} días de duración',
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${plan.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: planColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Features
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Beneficios incluidos:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: planColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
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
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Suscribirse',
                onPressed: isProcessing ? null : onSubscribe,
                loading: isProcessing,                
              ),
            ),
          ),
        ],
      ),
    );
  }
}