import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/subscription_models.dart';

class CartState {
  final List<SubscriptionModel> items;
  
  CartState({this.items = const []});

  double get total => items.fold(0, (sum, item) => sum + item.price);
  int get itemCount => items.length;

  CartState copyWith({List<SubscriptionModel>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addItem(SubscriptionModel subscription) {
    if (state.items.any((item) => item.id == subscription.id)) return;
    state = state.copyWith(items: [...state.items, subscription]);
  }

  void removeItem(int subscriptionId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != subscriptionId).toList(),
    );
  }

  void clear() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
