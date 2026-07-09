import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/subscription_models.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';

/// Pantalla de planes de suscripción.
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionsProvider);
    final mySubAsync = ref.watch(mySubscriptionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Suscripciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mi suscripción activa ──────────────────────────────────
            mySubAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (mySub) => mySub != null && mySub.isActive
                  ? _ActiveSubscriptionCard(subscription: mySub)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            const Text(
              'Elige tu plan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              'Desbloquea todo el contenido sin límites',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // ── Planes disponibles ─────────────────────────────────────
            plansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
              error: (_, __) => const Text('Error al cargar planes', style: TextStyle(color: Colors.redAccent)),
              data: (plans) => Column(
                children: plans.map((plan) => _PlanCard(plan: plan)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSubscriptionCard extends StatelessWidget {
  const _ActiveSubscriptionCard({required this.subscription});
  final UserSubscriptionModel subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.subscription.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${subscription.daysRemaining} días restantes', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
            child: const Text('Activo', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});
  final SubscriptionModel plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPopular = plan.price == 9.99;
    final paymentStatus = ref.watch(paymentNotifierProvider);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1828),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPopular ? const Color(0xFF7C4DFF) : Colors.white12,
              width: isPopular ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(plan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(plan.formattedPrice, style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 20)),
                        if (!plan.isFree)
                          Text('/ ${plan.durationLabel}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(plan.description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 12),
                ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                      const SizedBox(width: 8),
                      Text(f, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: plan.isFree || paymentStatus == PaymentStatus.loading
                        ? null
                        : () => _showPaymentDialog(context, ref, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isFree ? Colors.white12 : const Color(0xFF7C4DFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      plan.isFree ? 'Plan actual' : 'Suscribirse',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isPopular)
          Positioned(
            top: 12,
            right: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, SubscriptionModel plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Suscribirse a ${plan.name}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: ${plan.formattedPrice} / ${plan.durationLabel}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text('Método de pago:', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 8),
            ...['Tarjeta de crédito', 'PayPal'].map((method) => ListTile(
              leading: Icon(
                method.contains('Tarjeta') ? Icons.credit_card : Icons.account_balance_wallet,
                color: const Color(0xFF7C4DFF),
              ),
              title: Text(method, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ref.read(paymentNotifierProvider.notifier).processPayment(
                  subscriptionId: plan.id,
                  paymentMethod: method.toLowerCase().replaceAll(' ', '_'),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
