import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';
import 'package:jumpup_app/domain/model/subscription_models.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F111A) : const Color(0xFFF0F4F8);
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: titleColor),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          '🛒 Shopping Cart',
          style: TextStyle(
            color: titleColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(cartProvider.notifier).clear();
                },
                child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background Blobs Animated
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -60 + (40 * _blobController.value),
                    right: -50 + (30 * _blobController.value),
                    child: _blob(const Color(0xFF7C4DFF), 300, isDark ? 0.12 : 0.08),
                  ),
                  Positioned(
                    bottom: 150 - (40 * _blobController.value),
                    left: -80 + (20 * _blobController.value),
                    child: _blob(const Color(0xFF00E5FF), 280, isDark ? 0.1 : 0.06),
                  ),
                ],
              );
            },
          ),

          if (cart.items.isEmpty)
            const _EmptyCartView()
          else
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Text('🛒', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore our premium plans',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 15),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 200,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Explore Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
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
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.all(20),
      blur: 24,
      opacity: isDark ? 0.06 : 0.08,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.durationLabel,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
                  ),
                  child: const Text('✅ Includes AI Tutor', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedPrice,
                style: const TextStyle(
                  color: Color(0xFF00E5FF), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(cartProvider.notifier).removeItem(item.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    setState(() { _processing = true; _statusText = 'Preparing payment...'; });

    try {
      setState(() => _statusText = 'Connecting to server...');
      final ok = await ref.read(stripePaymentProvider.notifier)
          .createIntent(subscriptionId: plan.id);

      if (!ok) {
        final err = ref.read(stripePaymentProvider).error;
        setState(() { _processing = false; _statusText = err ?? 'Error creating payment.'; });
        return;
      }

      final intentState = ref.read(stripePaymentProvider);
      final clientSecret   = intentState.clientSecret!;
      final publishableKey = intentState.publishableKey;

      if (publishableKey != null && publishableKey.isNotEmpty) {
        Stripe.publishableKey = publishableKey;
      }
      await Stripe.instance.applySettings();

      setState(() => _statusText = 'Loading payment sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'JumpUp Idiomas',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF7C4DFF),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
              shadow: PaymentSheetShadowParams(color: Colors.black),
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'usd',
            testEnv: true,
          ),
        ),
      );

      setState(() => _statusText = '');
      await Stripe.instance.presentPaymentSheet();

      setState(() => _statusText = 'Activating subscription...');
      
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
            ? 'Payment canceled.'
            : 'Card declined: ${e.error.localizedMessage}';
      });
    } catch (e) {
      setState(() {
        _processing = false;
        _statusText = 'Error: ${e.toString().replaceAll("Exception: ", "")}';
      });
    }
  }

  Future<void> _handleMockPurchase() async {
    HapticFeedback.heavyImpact();
    final cartItems = ref.read(cartProvider).items;
    if (cartItems.isEmpty) return;

    final plan = cartItems.first;
    setState(() { _processing = true; _statusText = 'Processing mock purchase...'; });

    try {
      final success = await ref.read(stripePaymentProvider.notifier)
          .executeMockPurchase(subscriptionId: plan.id);

      if (success) {
        for (int i = 0; i < 2; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          ref.invalidate(mySubscriptionProvider);
        }
        
        ref.read(cartProvider.notifier).clear();
        if (mounted) _showSuccess(plan.name);
      } else {
        setState(() { _processing = false; _statusText = 'Simulation error.'; });
      }
    } catch (e) {
      setState(() {
        _processing = false;
        _statusText = 'Error: ${e.toString()}';
      });
    }
  }

  void _showSuccess(String planName) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 28),
                SizedBox(width: 10),
                Text('Payment Successful!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Your $planName plan is now active.\n'
              'You now have access to the AI Tutor and all Pro benefits.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/student');
                  },
                  child: const Text('Get Started!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTextColor = isDark ? Colors.white54 : Colors.black54;
    final totalLabelColor = isDark ? Colors.white : Colors.black87;
    final hasError = _statusText.startsWith('Error') ||
        _statusText.contains('rechazada') ||
        _statusText.contains('cancelado');

    return GlassContainer(
      blur: 32,
      opacity: isDark ? 0.12 : 0.25,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(color: totalTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
                Text('\$${widget.cart.total.toStringAsFixed(2)}', style: TextStyle(color: totalLabelColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(color: totalLabelColor, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  '\$${widget.cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF), 
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            if (_statusText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (hasError ? Colors.redAccent : Colors.blueAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_processing && !hasError)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                      ),
                    if (_processing && !hasError) const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: hasError ? Colors.redAccent : Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _processing ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _processing
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text('PAY WITH STRIPE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 14),
                SizedBox(width: 6),
                Text('100% Secure Payment with Stripe', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _processing ? null : _handleMockPurchase,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('🧪 SIMULATE PURCHASE (DEBUG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
