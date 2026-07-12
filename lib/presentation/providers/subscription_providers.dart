import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/subscription_models.dart';
import 'package:jumpup_app/data/repository/auth/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return const SubscriptionService();
});

final subscriptionsProvider =
    FutureProvider<List<SubscriptionModel>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getSubscriptions();
});

final mySubscriptionProvider =
    FutureProvider<UserSubscriptionModel?>((ref) async {
  return ref.watch(subscriptionServiceProvider).getMySubscription();
});

final paymentHistoryProvider = FutureProvider<List<PaymentModel>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getPaymentHistory();
});

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getOrders();
});

enum PaymentStatus { idle, loading, success, failure }

class PaymentNotifier extends StateNotifier<PaymentStatus> {
  PaymentNotifier(this._service) : super(PaymentStatus.idle);
  final SubscriptionService _service;

  Future<void> processPayment({
    required int subscriptionId,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    state = PaymentStatus.loading;
    try {
      final order = await _service.createOrder(
        subscriptionId: subscriptionId,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
      );
      await _service.registerPayment(
        orderId: order.id,
        amount: order.totalAmount,
        paymentMethod: paymentMethod,
      );
      state = PaymentStatus.success;
    } catch (_) {
      state = PaymentStatus.failure;
    }
  }

  void reset() => state = PaymentStatus.idle;
}

final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, PaymentStatus>((ref) {
  return PaymentNotifier(ref.watch(subscriptionServiceProvider));
});

// ── Stripe Payment Intent ─────────────────────────────────────────────────────

class StripePaymentIntentState {
  final bool isLoading;
  final String? clientSecret;
  final String? publishableKey;
  final int? orderId;
  final String? error;

  const StripePaymentIntentState({
    this.isLoading = false,
    this.clientSecret,
    this.publishableKey,
    this.orderId,
    this.error,
  });

  StripePaymentIntentState copyWith({
    bool? isLoading,
    String? clientSecret,
    String? publishableKey,
    int? orderId,
    String? error,
  }) {
    return StripePaymentIntentState(
      isLoading: isLoading ?? this.isLoading,
      clientSecret: clientSecret ?? this.clientSecret,
      publishableKey: publishableKey ?? this.publishableKey,
      orderId: orderId ?? this.orderId,
      error: error,
    );
  }
}

class StripePaymentNotifier extends StateNotifier<StripePaymentIntentState> {
  StripePaymentNotifier(this._service) : super(const StripePaymentIntentState());
  final SubscriptionService _service;

  Future<bool> createIntent({required int subscriptionId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.createPaymentIntent(
        subscriptionId: subscriptionId,
      );
      state = state.copyWith(
        isLoading: false,
        clientSecret: data['client_secret']?.toString(),
        publishableKey: data['publishable_key']?.toString(),
        orderId: data['order_id'] as int?,
      );
      return state.clientSecret != null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Ejecuta un flujo de compra simulado (para desarrollo)
  Future<bool> executeMockPurchase({required int subscriptionId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _service.mockPurchase(subscriptionId: subscriptionId);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() => state = const StripePaymentIntentState();
}

final stripePaymentProvider =
    StateNotifierProvider<StripePaymentNotifier, StripePaymentIntentState>((ref) {
  return StripePaymentNotifier(ref.watch(subscriptionServiceProvider));
});
