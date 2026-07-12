import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/data/repository/auth/ecommerce_repository_impl.dart';
import 'package:jumpup_app/domain/model/ecommerce_models.dart';

// --- Proveedor de Catálogo ---
final catalogProvider = FutureProvider<List<CatalogoModel>>((ref) async {
  final service = ref.watch(ecommerceServiceProvider);
  return await service.getCatalogo();
});

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Blobs
          if (isDark)
            Positioned(
              top: -50,
              right: -50,
              child: _BlurBlob(color: Colors.blueAccent.withValues(alpha: 0.1), size: 300),
            ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _CatalogHeader(ref: ref, isDark: isDark),
              catalogAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: _ErrorState(onRetry: () => ref.invalidate(catalogProvider), isDark: isDark),
                ),
                data: (catalog) {
                  if (catalog.isEmpty) {
                    return SliverFillRemaining(child: _EmptyState(isDark: isDark));
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = catalog[index];
                          return FadeInUp(
                            duration: Duration(milliseconds: 400 + (index * 100)),
                            child: _ProductCard(product: product, isDark: isDark, ref: ref),
                          );
                        },
                        childCount: catalog.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatalogHeader extends ConsumerWidget {
  final WidgetRef ref;
  final bool isDark;

  const _CatalogHeader({required this.ref, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef thisRef) {
    final cartCount = ref.watch(cartProvider).when(
          data: (cart) => cart.items.fold(0, (sum, item) => sum + item.cantidad),
          loading: () => 0,
          error: (_, __) => 0,
        );

    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: isDark
          ? const Color(0xFF0F111A).withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 16),
        title: Text(
          'Tienda',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -1,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white : Colors.black87, size: 28),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '$cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CatalogoModel product;
  final bool isDark;
  final WidgetRef ref;

  const _ProductCard({required this.product, required this.isDark, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  product.tipo == 'libro' ? Icons.book_rounded : Icons.school_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 56,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.tipo,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          ref.read(cartActionsProvider).addItem(product.id);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text(
            'No hay productos disponibles',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve pronto para más novedades.',
            style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorState({required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
          const SizedBox(height: 20),
          Text('Error al cargar el catálogo', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
