import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/ecommerce_models.dart';
import 'package:jumpup_app/data/repository/auth/ecommerce_repository_impl.dart';
import 'package:jumpup_app/presentation/providers/progress_providers.dart';

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

// --- Proveedor de Selección de Ítems ---
final selectedCartItemsProvider = StateProvider<Set<int>>((ref) => {});

// --- Proveedor del Total Seleccionado ---
final selectedTotalProvider = Provider<double>((ref) {
  final cartAsync = ref.watch(cartProvider);
  final selectedIds = ref.watch(selectedCartItemsProvider);
  
  return cartAsync.maybeWhen(
    data: (cart) {
      double total = 0.0;
      for (var item in cart.items) {
        if (selectedIds.contains(item.productoId)) {
          total += (item.producto?.precio ?? 0) * item.cantidad;
        }
      }
      return total;
    },
    orElse: () => 0.0,
  );
});

class CartActions {
  final EcommerceRepositoryImpl _service;
  final Ref _ref;

  CartActions(this._service, this._ref);

  void toggleSelection(int productId) {
    final selected = _ref.read(selectedCartItemsProvider);
    final newSelected = Set<int>.from(selected);
    if (newSelected.contains(productId)) {
      newSelected.remove(productId);
    } else {
      newSelected.add(productId);
    }
    _ref.read(selectedCartItemsProvider.notifier).state = newSelected;
  }

  void selectAll(List<int> productIds) {
    _ref.read(selectedCartItemsProvider.notifier).state = Set<int>.from(productIds);
  }

  void clearSelection() {
    _ref.read(selectedCartItemsProvider.notifier).state = {};
  }

  Future<void> addItem(int productId, {int cantidad = 1}) async {
    try {
      await _service.agregarAlCarrito(productId, cantidad: cantidad);
      _ref.invalidate(cartProvider);
    } catch (e) {
      // Ignore errors or show snackbar if needed
    }
  }

  Future<void> removeItem(int productId) async {
    try {
      await _service.eliminarDelCarrito(productId);

      final selected = _ref.read(selectedCartItemsProvider);
      if (selected.contains(productId)) {
        final newSelected = Set<int>.from(selected)..remove(productId);
        _ref.read(selectedCartItemsProvider.notifier).state = newSelected;
      }

      _ref.invalidate(cartProvider);
      _ref.invalidate(ordersProvider);
      await _ref.read(cartProvider.future);
    } catch (e) {
      // Ignore errors or show snackbar if needed
    }
  }

  Future<OrdenCompraModel?> checkout() async {
    try {
      final selectedIds = _ref.read(selectedCartItemsProvider).toList();
      
      // Enviar los IDs seleccionados para procesar solo esos productos
      final order = await _service.comprar(productoIds: selectedIds);
      
      // Limpiar selección tras compra exitosa
      clearSelection();

      _ref.invalidate(cartProvider);
      _ref.invalidate(ordersProvider);

      // Invalida proveedores de progreso y ranking para reflejar beneficios de compra
      _ref.invalidate(progressSummaryProvider);
      _ref.invalidate(userStatsProvider);
      _ref.invalidate(rankingProvider);

      return order;
    } catch (e, stack) {
      print('Error en checkout: $e');
      print(stack);
      rethrow; // Lanzar el error para que la UI pueda capturarlo y mostrarlo
    }
  }

  Future<void> refresh() async {
    _ref.invalidate(cartProvider);
  }
}
