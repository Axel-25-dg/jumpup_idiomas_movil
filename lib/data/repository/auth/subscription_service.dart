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

  Future<OrderModel> createOrder(int subscriptionId) async {
    return createOne('orders/', OrderModel.fromJson,
        data: {
          'subscription': subscriptionId,
        },
        message: 'No se pudo crear la orden');
  }

  Future<PaymentModel> registerPayment({
    required double amount,
    required String method,
  }) async {
    return createOne('payments/', PaymentModel.fromJson,
        data: {
          'amount': amount,
          'payment_method': method,
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
}
