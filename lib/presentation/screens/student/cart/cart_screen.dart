import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';
import 'package:jumpup_app/domain/model/subscription_models.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F111A) : const Color(0xFFF0F4F8);
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
        title: Text(
          '🛒 Carrito',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(cartProvider.notifier).clear();
              },
              child: const Text('Vaciar', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? const _EmptyCartView()
          : Stack(
              children: [
                Positioned(top: -60, right: -60, child: _blob(Colors.blueAccent, 200)),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return _CartItemCard(item: item, ref: ref);
                        },
                      ),
                    ),
                    _CartSummaryPanel(cart: cart),
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

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora nuestros planes premium',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Explorar Planes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final SubscriptionModel item;
  final WidgetRef ref;

  const _CartItemCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item.durationLabel,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('✅ Incluye Tutor IA', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedPrice,
                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).removeItem(item.id);
                },
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Cart Summary + Stripe Checkout ────────────────────────────────────────────

class _CartSummaryPanel extends ConsumerStatefulWidget {
  final CartState cart;
  const _CartSummaryPanel({required this.cart});

  @override
  ConsumerState<_CartSummaryPanel> createState() => _CartSummaryPanelState();
}

class _CartSummaryPanelState extends ConsumerState<_CartSummaryPanel> {
  String _statusText = '';
  bool _processing = false;

  Future<void> _handleCheckout() async {
    HapticFeedback.mediumImpact();
    final cartItems = ref.read(cartProvider).items;
    if (cartItems.isEmpty) return;

    final plan = cartItems.first;
    setState(() { _processing = true; _statusText = 'Preparando pago...'; });

    try {
      // 1. Pedir client_secret al backend
      setState(() => _statusText = 'Conectando con el servidor...');
      final ok = await ref.read(stripePaymentProvider.notifier)
          .createIntent(subscriptionId: plan.id);

      if (!ok) {
        final err = ref.read(stripePaymentProvider).error;
        setState(() { _processing = false; _statusText = err ?? 'Error al crear el pago.'; });
        return;
      }

      final intentState = ref.read(stripePaymentProvider);
      final clientSecret   = intentState.clientSecret!;
      final publishableKey = intentState.publishableKey;

      // 2. Configurar Stripe con la key que devuelve el backend
      if (publishableKey != null && publishableKey.isNotEmpty) {
        Stripe.publishableKey = publishableKey;
      }
      // applySettings() se llama aquí, ya con la Activity lista
      await Stripe.instance.applySettings();

      // 3. Inicializar el Payment Sheet
      setState(() => _statusText = 'Cargando formulario de pago...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'JumpUp UTE',
          style: ThemeMode.system,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'usd',
            testEnv: true, // ← false en producción
          ),
        ),
      );

      // 4. Presentar el Sheet nativo de Stripe
      setState(() => _statusText = '');
      await Stripe.instance.presentPaymentSheet();

      // 5. Pago confirmado — esperar al webhook y refrescar
      setState(() => _statusText = 'Activando suscripción...');
      
      // Intentar refrescar varias veces para dar tiempo al webhook
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(seconds: 2));
        ref.invalidate(mySubscriptionProvider);
        final sub = await ref.read(mySubscriptionProvider.future);
        if (sub?.isActive == true) break;
      }

      ref.read(cartProvider.notifier).clear();
      ref.read(stripePaymentProvider.notifier).reset();

      if (mounted) _showSuccess(plan.name.isNotEmpty ? plan.name : 'Pro');

    } on StripeException catch (e) {
      setState(() {
        _processing = false;
        _statusText = e.error.code == FailureCode.Canceled
            ? 'Pago cancelado.'
            : 'Tarjeta rechazada: ${e.error.localizedMessage}';
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _statusText = 'Error: ${e.toString().replaceAll("Exception: ", "")}';
      });
    }
  }

  void _showSuccess(String planName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 28),
            SizedBox(width: 10),
            Text('¡Pago exitoso!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Tu plan $planName ya está activo.\n'
          'Ahora tienes acceso al Tutor IA y todos los beneficios Pro.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.go('/student');
            },
            child: const Text('¡Comenzar!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final totalTextColor = isDark ? Colors.white54 : Colors.black54;
    final totalLabelColor = isDark ? Colors.white : Colors.black87;
    final hasError = _statusText.startsWith('Error') ||
        _statusText.contains('rechazada') ||
        _statusText.contains('cancelado');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, -8))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(color: totalTextColor, fontSize: 14)),
                Text('\$${widget.cart.total.toStringAsFixed(2)}', style: TextStyle(color: totalLabelColor, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(color: totalLabelColor, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '\$${widget.cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            // Status message
            if (_statusText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_processing && !hasError)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                    ),
                  if (_processing && !hasError) const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: hasError ? Colors.redAccent : Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _processing ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _processing
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('Pagar con Stripe', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('🔒 Pago seguro con Stripe', style: TextStyle(color: Colors.blueAccent, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
