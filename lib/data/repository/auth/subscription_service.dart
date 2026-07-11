import 'package:jumpup_app/domain/model/subscription_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class SubscriptionService extends BaseRepository {
  const SubscriptionService();

  Future<List<SubscriptionModel>> getSubscriptions() async {
    return getList('subscriptions/', SubscriptionModel.fromJson,
        message: 'No se pudieron cargar los planes');
  }

  Future<UserSubscriptionModel?> getMySubscription() async {
    return handleRequest<UserSubscriptionModel?>(() async {
      final response = await dio.get<dynamic>('my-subscriptions/');
      final data = response.data;
      if (data == null) return null;
      final list = data is List ? data : (data['results'] as List?) ?? [];
      if (list.isEmpty) return null;
      return UserSubscriptionModel.fromJson(
        list.first is Map ? Map<String, dynamic>.from(list.first) : {},
      );
    }, message: 'No se pudo obtener tu suscripción');
  }

  Future<OrderModel> createOrder({
    required int subscriptionId,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    return createOne('orders/', OrderModel.fromJson,
        data: {
          'subscription': subscriptionId,
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
        },
        message: 'No se pudo crear la orden');
  }

  Future<PaymentModel> registerPayment({
    required int orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    return createOne('payments/', PaymentModel.fromJson,
        data: {
          'order': orderId,
          'amount': amount,
          'payment_method': paymentMethod,
          'status': 'approved',
        },
        message: 'No se pudo procesar el pago');
  }

  Future<List<PaymentModel>> getPaymentHistory() async {
    return getList('payments/', PaymentModel.fromJson,
        message: 'No se pudo obtener el historial de pagos');
  }

  Future<List<OrderModel>> getOrders() async {
    return getList('orders/', OrderModel.fromJson,
        message: 'No se pudieron cargar las órdenes');
  }

  /// Crea un PaymentIntent en Stripe a través del backend.
  /// Retorna { client_secret, publishable_key, order_id }
  Future<Map<String, dynamic>> createPaymentIntent({
    required int subscriptionId,
    String paymentMethod = 'credit_card',
  }) async {
    return handleRequest<Map<String, dynamic>>(() async {
      final response = await dio.post<dynamic>(
        'stripe/create-payment-intent/',
        data: {
          'subscription_id': subscriptionId,
          'payment_method': paymentMethod,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return Map<String, dynamic>.from(response.data as Map);
    }, message: 'No se pudo crear el intento de pago');
  }

  /// Cancela la suscripción activa del usuario.
  Future<String> cancelSubscription(int subscriptionId) async {
    return handleRequest<String>(() async {
      final response = await dio.post<dynamic>(
        'my-subscriptions/$subscriptionId/cancel/',
      );
      final data = response.data;
      if (data is Map) return data['detail']?.toString() ?? 'Suscripción cancelada.';
      return 'Suscripción cancelada.';
    }, message: 'No se pudo cancelar la suscripción');
  }
}
