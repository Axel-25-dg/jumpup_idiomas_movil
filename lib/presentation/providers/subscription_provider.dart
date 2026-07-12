// lib/presentation/providers/subscription_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/subscription_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_subscription_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final subscriptionNotifierProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<List<Subscription>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).subscriptions;
  return SubscriptionNotifier(repository);
});

class SubscriptionNotifier extends StateNotifier<AsyncValue<List<Subscription>>> {
  final SubscriptionRepository _repository;

  SubscriptionNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    state = const AsyncValue.loading();
    try {
      final subscriptions = await _repository.fetchSubscriptions();
      state = AsyncValue.data(subscriptions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String> initiateCheckout(int subscriptionId) async {
    try {
      return await _repository.initiateCheckout(subscriptionId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    await fetchSubscriptions();
  }
}

// Provider de solo lectura
final subscriptionsProvider = FutureProvider<List<Subscription>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).subscriptions;
  return repository.fetchSubscriptions();
});
