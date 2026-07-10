import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

/// Pantalla de planes de suscripción — Premium Redesign
class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionsProvider);
    final mySubAsync = ref.watch(mySubscriptionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: Stack(
        children: [
          Positioned(top: -80, left: -80, child: _blob(Colors.purpleAccent, 250)),
          Positioned(bottom: 200, right: -60, child: _blob(Colors.blueAccent, 200)),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                expandedHeight: 180,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('✨ Suscripciones', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text('Desbloquea todo el potencial de JumpUp', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Active subscription banner
                    mySubAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (mySub) => mySub != null && mySub.isActive
                          ? _ActivePlanBanner(subscription: mySub)
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                    // Feature comparison header
                    const _FeatureHeader(),
                    const SizedBox(height: 24),
                    // Plans
                    plansAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                      error: (_, __) => const Center(child: Text('Error al cargar planes', style: TextStyle(color: Colors.redAccent))),
                      data: (plans) => Column(
                        children: plans.map((plan) => _PlanCard(plan: plan)).toList(),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 100)],
        ),
      );
}

class _ActivePlanBanner extends StatelessWidget {
  final dynamic subscription;
  const _ActivePlanBanner({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF388E3C)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan Activo: ${subscription.planName ?? "Pro"}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Vence: ${subscription.endDate ?? "N/A"}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHeader extends StatelessWidget {
  const _FeatureHeader();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Text('¿Qué incluye Pro?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _FeatureRow(icon: '🤖', feature: 'Tutor IA Ilimitado (GPT-4o)'),
          _FeatureRow(icon: '🎓', feature: 'Acceso a todos los cursos'),
          _FeatureRow(icon: '📜', feature: 'Certificados verificados'),
          _FeatureRow(icon: '🎮', feature: 'Todos los minijuegos'),
          _FeatureRow(icon: '📊', feature: 'Estadísticas avanzadas'),
          _FeatureRow(icon: '🔔', feature: 'Sin publicidad'),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon, feature;
  const _FeatureRow({required this.icon, required this.feature});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(feature, style: const TextStyle(color: Colors.white, fontSize: 14)),
        const Spacer(),
        const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18),
      ],
    ),
  );
}

class _PlanCard extends ConsumerWidget {
  final dynamic plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPopular = (plan.name ?? '').toLowerCase().contains('pro') || (plan.durationDays ?? 0) == 30;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(cartProvider.notifier).addItem(plan);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${plan.name} añadido al carrito'),
          backgroundColor: Colors.blueAccent,
          action: SnackBarAction(
            label: 'Ver Carrito',
            textColor: Colors.white,
            onPressed: () => context.push('/cart'),
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: isPopular
              ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isPopular ? null : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(24),
          border: isPopular ? null : Border.all(color: Colors.white12),
          boxShadow: isPopular
              ? [BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]
              : null,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: const Text('⭐ Más Popular', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            if (isPopular) const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name ?? 'Plan Pro', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(plan.durationLabel ?? '${plan.durationDays ?? 30} días', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(plan.formattedPrice ?? '\$${plan.price}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    const Text('/ período', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(cartProvider.notifier).addItem(plan);
                  context.push('/cart');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? Colors.white : Colors.blueAccent,
                  foregroundColor: isPopular ? const Color(0xFF6A11CB) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isPopular ? 'Suscribirse Ahora' : 'Seleccionar Plan',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
