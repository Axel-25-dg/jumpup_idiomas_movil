import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/ecommerce_models.dart';
import 'package:jumpup_app/data/repository/auth/ecommerce_repository_impl.dart';

// --- Proveedor del Servicio de Ecommerce ---
final ecommerceServiceProvider = Provider<EcommerceRepositoryImpl>((ref) {
  return const EcommerceRepositoryImpl();
});

// --- Proveedor del Carrito ---
final cartProvider = FutureProvider<CarritoModel>((ref) async {
  final service = ref.watch(ecommerceServiceProvider);
  return await service.getCarrito();
});

// --- Proveedor de Órdenes (Historial de Pagos) ---
final ordersProvider = FutureProvider<List<OrdenCompraModel>>((ref) async {
  final service = ref.watch(ecommerceServiceProvider);
  return await service.getOrdenes();
});

// --- Proveedor de Acciones del Carrito ---
final cartActionsProvider = Provider<CartActions>((ref) {
  final service = ref.watch(ecommerceServiceProvider);
  return CartActions(service, ref);
});

class CartActions {
  final EcommerceRepositoryImpl _service;
  final Ref _ref;

  CartActions(this._service, this._ref);

  Future<void> addItem(int productId, {int cantidad = 1}) async {
    await _service.agregarAlCarrito(productId, cantidad: cantidad);
    _ref.invalidate(cartProvider);
  }

  Future<void> removeItem(int productId) async {
    await _service.eliminarDelCarrito(productId);
    _ref.invalidate(cartProvider);
  }

  Future<OrdenCompraModel> checkout() async {
    final order = await _service.comprar();
    _ref.invalidate(cartProvider);
    _ref.invalidate(ordersProvider);
    return order;
  }

  Future<void> refresh() async {
    _ref.invalidate(cartProvider);
  }
}
