import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/subscription_models.dart';
import 'package:jumpup_app/presentation/providers/subscription_providers.dart';

/// Pantalla de historial de pagos y órdenes del usuario.
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentHistoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1828),
          title: const Text('Historial de Pagos',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: Color(0xFF7C4DFF),
            unselectedLabelColor: Colors.white54,
            indicatorColor: Color(0xFF7C4DFF),
            tabs: [
              Tab(text: 'Pagos'),
              Tab(text: 'Órdenes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab Pagos ────────────────────────────────────────────
            paymentsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
              error: (_, __) => const Center(
                  child: Text('Error al cargar pagos',
                      style: TextStyle(color: Colors.redAccent))),
              data: (payments) => payments.isEmpty
                  ? const _EmptyState(message: 'No tienes pagos registrados')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      itemBuilder: (_, i) => _PaymentTile(payment: payments[i]),
                    ),
            ),

            // ── Tab Órdenes ──────────────────────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final ordersAsync = ref.watch(ordersProvider);
                return ordersAsync.when(
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  error: (_, __) => const Center(
                      child: Text('Error al cargar órdenes',
                          style: TextStyle(color: Colors.redAccent))),
                  data: (orders) => orders.isEmpty
                      ? const _EmptyState(
                          message: 'No tienes órdenes registradas')
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          itemBuilder: (_, i) => _OrderTile(order: orders[i]),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});
  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        payment.isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.receipt_long, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(payment.method.replaceAll('_', ' ').toUpperCase(),
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
                if (payment.transactionId != null)
                  Text(payment.transactionId!,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(payment.statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(_formatDate(payment.createdAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Text('📦', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.subscription.name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text('\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF7C4DFF), fontSize: 14)),
              ],
            ),
          ),
          Text(_formatDate(order.createdAt),
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_outlined, color: Colors.white24, size: 60),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: Colors.white54, fontSize: 15)),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
