import '../repositories/base_repository.dart';
import '../models/subscription_models.dart';

/// Servicio para los endpoints de Suscripciones y Pagos.
///
/// Endpoints:
/// - GET  /api/subscriptions/     — Planes disponibles
/// - GET  /api/my-subscriptions/  — Mi suscripción activa
/// - POST /api/my-subscriptions/  — Suscribirse a un plan
/// - GET  /api/payments/          — Historial de pagos
/// - POST /api/payments/          — Registrar pago
/// - GET  /api/orders/            — Mis órdenes
/// - POST /api/orders/            — Crear orden
class SubscriptionService extends BaseRepository {
  const SubscriptionService();

  Future<List<SubscriptionModel>> getSubscriptions() async {
    return handleRequest(() async => _mockSubscriptions(),
        message: 'No se pudieron cargar los planes');
  }

  Future<UserSubscriptionModel?> getMySubscription() async {
    return handleRequest(() async => _mockMySubscription(),
        message: 'No se pudo obtener tu suscripción');
  }

  Future<OrderModel> createOrder(int subscriptionId) async {
    return handleRequest(() async {
      final sub = _mockSubscriptions().firstWhere((s) => s.id == subscriptionId);
      return OrderModel(
        id: DateTime.now().millisecondsSinceEpoch,
        subscription: sub,
        totalAmount: sub.price,
        status: 'pending',
        createdAt: DateTime.now(),
      );
    }, message: 'No se pudo crear la orden');
  }

  Future<PaymentModel> registerPayment({
    required double amount,
    required String method,
  }) async {
    return handleRequest(() async {
      return PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch,
        amount: amount,
        status: 'completed',
        method: method,
        createdAt: DateTime.now(),
        transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      );
    }, message: 'No se pudo procesar el pago');
  }

  Future<List<PaymentModel>> getPaymentHistory() async {
    return handleRequest(() async => _mockPayments(),
        message: 'No se pudo obtener el historial de pagos');
  }

  Future<List<OrderModel>> getOrders() async {
    return handleRequest(() async => _mockOrders(),
        message: 'No se pudieron cargar las órdenes');
  }

  // ─── Mock Data ────────────────────────────────────────────────────────────

  List<SubscriptionModel> _mockSubscriptions() => [
        const SubscriptionModel(
          id: 1, name: 'Gratis', description: 'Acceso básico a la plataforma',
          price: 0.0, durationDays: 365,
          features: ['5 lecciones por día', 'Acceso a cursos A1', 'Progreso básico'],
        ),
        const SubscriptionModel(
          id: 2, name: 'Premium', description: 'Acceso completo sin límites',
          price: 9.99, durationDays: 30,
          features: ['Lecciones ilimitadas', 'Todos los idiomas', 'Sin anuncios', 'Descarga offline', 'Certificados'],
        ),
        const SubscriptionModel(
          id: 3, name: 'Premium Anual', description: 'El mejor valor — 2 meses gratis',
          price: 79.99, durationDays: 365,
          features: ['Todo lo de Premium', '2 meses gratis', 'Soporte prioritario', 'Acceso anticipado a novedades'],
        ),
      ];

  UserSubscriptionModel? _mockMySubscription() => UserSubscriptionModel(
        id: 1,
        subscription: _mockSubscriptions()[1],
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        isActive: true,
      );

  List<PaymentModel> _mockPayments() => [
        PaymentModel(id: 1, amount: 9.99, status: 'completed', method: 'credit_card', createdAt: DateTime.now().subtract(const Duration(days: 5)), transactionId: 'TXN-001'),
        PaymentModel(id: 2, amount: 9.99, status: 'completed', method: 'paypal', createdAt: DateTime.now().subtract(const Duration(days: 35)), transactionId: 'TXN-002'),
      ];

  List<OrderModel> _mockOrders() => [
        OrderModel(id: 1, subscription: _mockSubscriptions()[1], totalAmount: 9.99, status: 'completed', createdAt: DateTime.now().subtract(const Duration(days: 5))),
      ];
}
