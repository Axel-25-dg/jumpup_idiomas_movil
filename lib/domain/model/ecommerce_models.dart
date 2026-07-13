// Reemplaza al antiguo módulo de suscripciones

class CatalogoModel {
  const CatalogoModel({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.precio,
    this.contenidoUrl,
    this.cursoId,
    this.cursoInfo,
    this.createdAt,
  });

  final int id;
  final String titulo;
  final String tipo; // 'curso' | 'libro'
  final double precio;
  final String? contenidoUrl;
  final int? cursoId;
  final Map<String, dynamic>? cursoInfo;
  final DateTime? createdAt;

  factory CatalogoModel.fromJson(Map<String, dynamic> json) {
    return CatalogoModel(
      id: json['id'] as int,
      titulo: json['titulo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'curso',
      precio: double.tryParse(json['precio']?.toString() ?? '0.0') ?? 0.0,
      contenidoUrl: json['contenido_url']?.toString(),
      cursoId: json['curso'] as int?,
      cursoInfo: json['curso_info'] as Map<String, dynamic>?,
      createdAt: json['creado_at'] != null
          ? DateTime.tryParse(json['creado_at'].toString())
          : null,
    );
  }
}

class CarritoItemModel {
  const CarritoItemModel({
    required this.productoId,
    required this.cantidad,
    this.producto,
  });

  final int productoId;
  final int cantidad;
  final CatalogoModel? producto;

  factory CarritoItemModel.fromJson(Map<String, dynamic> json) {
    return CarritoItemModel(
      productoId: json['producto_id'] as int? ?? json['id'] as int? ?? 0,
      cantidad: json['cantidad'] as int? ?? 1,
      producto: json['producto_info'] != null 
        ? CatalogoModel.fromJson(json['producto_info'] as Map<String, dynamic>)
        : null,
    );
  }
}

class CarritoModel {
  const CarritoModel({
    required this.id,
    required this.estudianteEmail,
    required this.items,
    this.total = 0.0,
  });

  final int id;
  final String estudianteEmail;
  final List<CarritoItemModel> items;
  final double total;

  factory CarritoModel.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? [];
    final items = list.map((i) => CarritoItemModel.fromJson(i as Map<String, dynamic>)).toList();
    
    double calculatedTotal = double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0;
    
    // Si el backend devuelve 0 pero tenemos items, calculamos el total localmente
    if (calculatedTotal == 0 && items.isNotEmpty) {
      for (var item in items) {
        if (item.producto != null) {
          calculatedTotal += (item.producto!.precio * item.cantidad);
        }
      }
    }

    return CarritoModel(
      id: json['id'] as int? ?? 0,
      estudianteEmail: json['estudiante_email']?.toString() ?? '',
      items: items,
      total: calculatedTotal,
    );
  }
}

class OrdenCompraModel {
  const OrdenCompraModel({
    required this.id,
    required this.estudianteEmail,
    required this.total,
    required this.estado,
    required this.fechaCreacion,
    this.detalles = const [],
  });

  final int id;
  final String estudianteEmail;
  final double total;
  final String estado; // 'pendiente' | 'pagada' | 'cancelada'
  final DateTime fechaCreacion;
  final List<OrdenDetalleModel> detalles;

  factory OrdenCompraModel.fromJson(Map<String, dynamic> json) {
    final list = json['detalles'] as List? ?? [];
    return OrdenCompraModel(
      id: json['id'] as int? ?? 0,
      estudianteEmail: json['estudiante_email']?.toString() ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
      estado: json['estado']?.toString() ?? 'pendiente',
      fechaCreacion: DateTime.tryParse(json['fecha_creacion']?.toString() ?? '') ?? DateTime.now(),
      detalles: list.map((d) => OrdenDetalleModel.fromJson(d as Map<String, dynamic>)).toList(),
    );
  }
}

class OrdenDetalleModel {
  const OrdenDetalleModel({
    required this.id,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    this.productoTitulo,
  });

  final int id;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final String? productoTitulo;

  factory OrdenDetalleModel.fromJson(Map<String, dynamic> json) {
    return OrdenDetalleModel(
      id: json['id'] as int? ?? 0,
      productoId: json['catalogo'] as int? ?? json['producto_id'] as int? ?? 0,
      cantidad: json['cantidad'] as int? ?? 1,
      precioUnitario: double.tryParse(json['precio_unitario']?.toString() ?? '0.0') ?? 0.0,
      productoTitulo: json['producto_titulo']?.toString(),
    );
  }
}
