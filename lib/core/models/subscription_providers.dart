import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_models.dart';
import '../auth/services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return const SubscriptionService();
});

final subscriptionsProvider = FutureProvider<List<SubscriptionModel>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getSubscriptions();
});

final mySubscriptionProvider = FutureProvider<UserSubscriptionModel?>((ref) async {
  return ref.watch(subscriptionServiceProvider).getMySubscription();
});

final paymentHistoryProvider = FutureProvider<List<PaymentModel>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getPaymentHistory();
});

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.watch(subscriptionServiceProvider).getOrders();
});

/// Estado del proceso de pago
enum PaymentStatus { idle, loading, success, failure }

class PaymentNotifier extends StateNotifier<PaymentStatus> {
  PaymentNotifier(this._service) : super(PaymentStatus.idle);
  final SubscriptionService _service;

  Future<void> processPayment({
    required int subscriptionId,
    required String paymentMethod,
  }) async {
    state = PaymentStatus.loading;
    try {
      final order = await _service.createOrder(subscriptionId);
      await _service.registerPayment(amount: order.totalAmount, method: paymentMethod);
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
