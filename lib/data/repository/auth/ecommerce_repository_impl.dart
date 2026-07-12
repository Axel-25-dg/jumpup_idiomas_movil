import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/ecommerce_models.dart';

class EcommerceRepositoryImpl extends BaseRepository {
  const EcommerceRepositoryImpl();

  // ── Catalogo ───────────────────────────────────────────────────────────────

  Future<List<CatalogoModel>> getCatalogo() async {
    return getList('catalogo/', CatalogoModel.fromJson,
        message: 'No se pudo cargar el catálogo');
  }

  // ── Carrito ────────────────────────────────────────────────────────────────

  Future<CarritoModel> getCarrito() async {
    return getOne('carrito/', CarritoModel.fromJson,
        message: 'No se pudo cargar el carrito');
  }

  Future<CarritoModel> agregarAlCarrito(int productoId, {int cantidad = 1}) async {
    return createOne('carrito/agregar/', CarritoModel.fromJson,
        data: {
          'producto_id': productoId,
          'cantidad': cantidad,
        },
        message: 'No se pudo agregar al carrito');
  }

  Future<CarritoModel> eliminarDelCarrito(int productoId) async {
    return createOne('carrito/eliminar/', CarritoModel.fromJson,
        data: {'producto_id': productoId},
        message: 'No se pudo eliminar del carrito');
  }

  Future<OrdenCompraModel> comprar() async {
    return createOne('carrito/comprar/', OrdenCompraModel.fromJson,
        message: 'No se pudo procesar la compra');
  }

  // ── Ordenes ────────────────────────────────────────────────────────────────

  Future<List<OrdenCompraModel>> getOrdenes() async {
    return getList('ordenes-compra/', OrdenCompraModel.fromJson,
        message: 'No se pudo cargar las órdenes');
  }

  Future<OrdenCompraModel> getOrden(int ordenId) async {
    return getOne('ordenes-compra/$ordenId/', OrdenCompraModel.fromJson,
        message: 'No se pudo cargar la orden');
  }
}
