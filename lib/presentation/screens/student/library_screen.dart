import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/domain/model/ecommerce_models.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Collect all purchased products (de-duplicate by product ID)
    final purchasedProducts = ordersAsync.when(
      data: (orders) {
        final Map<int, CatalogoModel> products = {};
        for (final order in orders) {
          if (order.estado == 'pagada') {
            for (final detalle in order.detalles) {
              // We don't have the full product here yet—we'll need to get it from somewhere,
              // but for now, let's just show what we have
            }
          }
        }
        return products.values.toList();
      },
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Biblioteca',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Error al cargar la biblioteca',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              TextButton(
                onPressed: () => ref.refresh(ordersProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (orders) {
          // Extract all paid order details
          final List<OrdenDetalleModel> paidItems = [];
          for (final order in orders) {
            if (order.estado == 'pagada') {
              paidItems.addAll(order.detalles);
            }
          }

          if (paidItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu biblioteca está vacía',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comprar productos para verlos aquí',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/student/catalog'),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Ir a la tienda'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: paidItems.length,
            itemBuilder: (context, index) {
              final item = paidItems[index];
              return _LibraryItemCard(item: item, isDark: isDark);
            },
          );
        },
      ),
    );
  }
}

class _LibraryItemCard extends StatelessWidget {
  final OrdenDetalleModel item;
  final bool isDark;

  const _LibraryItemCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.book_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productoTitulo ?? 'Producto #${item.productoId}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantidad: ${item.cantidad}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 28),
          ],
        ),
      ),
    );
  }
}
