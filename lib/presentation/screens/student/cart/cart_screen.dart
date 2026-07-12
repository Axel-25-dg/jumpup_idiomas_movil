import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/providers/cart/cart_provider.dart';
import 'package:jumpup_app/domain/model/ecommerce_models.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> with TickerProviderStateMixin {
  late AnimationController _blobController;
  bool _processing = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    HapticFeedback.mediumImpact();
    final selectedIds = ref.read(selectedCartItemsProvider);
    if (selectedIds.isEmpty) {
      setState(() { _statusText = 'Por favor, selecciona al menos un producto'; });
      return;
    }

    setState(() { _processing = true; _statusText = 'Procesando tu orden...'; });

    try {
      final actions = ref.read(cartActionsProvider);
      final order = await actions.checkout();

      if (mounted) {
        setState(() { _processing = false; });
        if (order != null) {
          _statusText = '';
          _showSuccess(order.id.toString());
        } else {
          setState(() { _statusText = 'Error: No se pudo completar el pago. Intenta de nuevo.'; });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() { 
          _processing = false; 
          _statusText = 'Error: ${e.toString().split(':').last.trim()}'; 
        });
      }
    }
  }

  void _showSuccess(String orderId) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, child) {
        final curve = Curves.easeOutBack.transform(a1.value);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15 * a1.value, sigmaY: 15 * a1.value),
          child: Opacity(
            opacity: a1.value,
            child: Transform.scale(
              scale: 0.8 + (0.2 * curve),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                content: GlassContainer(
                  blur: 20,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(32),
                  padding: const EdgeInsets.all(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 64),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '¡Pago Exitoso!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tu orden #$orderId ha sido procesada.\n'
                        'El contenido ya está disponible en tu biblioteca.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.go('/student');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Explorar Contenido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F111A) : const Color(0xFFF0F4F8);
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: titleColor),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          '🛒 Carrito',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all_rounded),
            tooltip: 'Seleccionar todos',
            onPressed: () {
              final cart = ref.read(cartProvider).value;
              if (cart != null) {
                ref.read(cartActionsProvider).selectAll(
                  cart.items.map((e) => e.productoId).toList()
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push('/student/payment-history'),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                const SizedBox(height: 24),
                Text(
                  'Error al cargar el carrito',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  e.toString(),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Reintentar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (cart) => Stack(
          children: [
            // Background Blobs Animated
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: -60 + (40 * _blobController.value),
                      right: -50 + (30 * _blobController.value),
                      child: _blob(const Color(0xFF7C4DFF), 300, isDark ? 0.12 : 0.08),
                    ),
                    Positioned(
                      bottom: 150 - (40 * _blobController.value),
                      left: -80 + (20 * _blobController.value),
                      child: _blob(const Color(0xFF00E5FF), 280, isDark ? 0.1 : 0.06),
                    ),
                  ],
                );
              },
            ),
            if (cart.items.isEmpty)
              const _EmptyCartView()
            else
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return _CartItemCard(item: item, ref: ref);
                      },
                    ),
                  ),
                  _CartSummaryPanel(cart: cart, onCheckout: _handleCheckout, processing: _processing, statusText: _statusText),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _blob(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity + 0.05),
              blurRadius: 100,
              spreadRadius: 20,
            ),
          ],
        ),
      );
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Text('🛒', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explora la tienda para agregar productos',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CarritoItemModel item;
  final WidgetRef ref;

  const _CartItemCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = item.producto;
    final selectedIds = ref.watch(selectedCartItemsProvider);
    final isSelected = selectedIds.contains(item.productoId);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.zero,
      blur: 24,
      opacity: isSelected ? (isDark ? 0.15 : 0.2) : (isDark ? 0.06 : 0.08),
      border: Border.all(
        color: isSelected 
            ? const Color(0xFF00E5FF).withValues(alpha: 0.5) 
            : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        width: 1.5,
      ),
      child: Row(
        children: [
          // Área de selección (toda la parte izquierda y central)
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(cartActionsProvider).toggleSelection(item.productoId);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Checkbox personalizado
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00E5FF) : (isDark ? Colors.white24 : Colors.black26),
                          width: 2,
                        ),
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
                      ),
                      child: isSelected 
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                    ),
                    const SizedBox(width: 16),
                    // Imagen/Icono
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected 
                            ? [const Color(0xFF7C4DFF), const Color(0xFF00E5FF)]
                            : [const Color(0xFF7C4DFF).withValues(alpha: 0.7), const Color(0xFF00E5FF).withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        product?.tipo == 'libro' ? Icons.book_rounded : Icons.school_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info Producto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.titulo ?? 'Producto',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product?.tipo?.toUpperCase() ?? 'PRODUCTO',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Área de Acción (Precio y Eliminar) - Separada para evitar interferencia de clics
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (product != null)
                  Text(
                    '\$${product.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                const SizedBox(height: 12),
                IconButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    ref.read(cartActionsProvider).removeItem(item.productoId);
                  },
                  icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryPanel extends ConsumerWidget {
  final CarritoModel cart;
  final VoidCallback onCheckout;
  final bool processing;
  final String statusText;

  const _CartSummaryPanel({required this.cart, required this.onCheckout, required this.processing, required this.statusText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalTextColor = isDark ? Colors.white54 : Colors.black54;
    final totalLabelColor = isDark ? Colors.white : Colors.black87;
    final hasError = statusText.startsWith('Error');
    
    final selectedTotal = ref.watch(selectedTotalProvider);
    final selectedIds = ref.watch(selectedCartItemsProvider);
    final hasSelection = selectedIds.isNotEmpty;

    return GlassContainer(
      blur: 32,
      opacity: isDark ? 0.12 : 0.25,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Seleccionado', style: TextStyle(color: totalTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(
                      '${selectedIds.length} ítems',
                      style: TextStyle(color: totalTextColor.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  '\$${selectedTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: hasSelection ? const Color(0xFF00E5FF) : totalLabelColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (statusText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (hasError ? Colors.redAccent : Colors.blueAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (processing && !hasError)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                      ),
                    if (processing && !hasError) const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        statusText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasError ? Colors.redAccent : Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !hasSelection || processing ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: !hasSelection 
                        ? [Colors.grey.shade700, Colors.grey.shade600]
                        : [const Color(0xFF7C4DFF), const Color(0xFF00E5FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: hasSelection ? [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ] : [],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: processing
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        : Text(
                            hasSelection ? 'Finalizar Compra' : 'Selecciona productos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
