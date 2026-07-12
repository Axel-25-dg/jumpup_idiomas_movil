// lib/data/repository/teacher_admin/subscription_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_subscription_model.dart';

class SubscriptionRepository extends BaseRepository {
  Future<List<Subscription>> fetchSubscriptions() {
    return getList<Subscription>(
      'subscriptions/',
      (json) => Subscription.fromJson(json),
      message: 'Error al cargar suscripciones',
    );
  }

  Future<String> initiateCheckout(int subscriptionId) async {
    try {
      final response = await dio.post(
        'subscriptions/$subscriptionId/checkout/',
      );
      return response.data['url'] as String;
    } on DioException catch (e) {
      throw ApiException('Error al iniciar pago', e.response?.statusCode, e);
    }
  }
}