import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/report_provider.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _statusFilter = 'TODOS';
  Color _getStatusColor(String status) {
    switch (status) {
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Reportes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'Todos',
                    selected: _statusFilter == 'TODOS',
                    color: colors.outline,
                    onTap: () => setState(() => _statusFilter = 'TODOS'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Abiertos',
                    selected: _statusFilter == 'OPEN',
                    color: Colors.orange,
                    onTap: () => setState(() => _statusFilter = 'OPEN'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'En progreso',
                    selected: _statusFilter == 'IN_PROGRESS',
                    color: Colors.blue,
                    onTap: () => setState(() => _statusFilter = 'IN_PROGRESS'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Resueltos',
                    selected: _statusFilter == 'RESOLVED',
                    color: Colors.green,
                    onTap: () => setState(() => _statusFilter = 'RESOLVED'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Rechazados',
                    selected: _statusFilter == 'REJECTED',
                    color: Colors.red,
                    onTap: () => setState(() => _statusFilter = 'REJECTED'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error al cargar: $e')),
              data: (reports) {
                final filtered = _statusFilter == 'TODOS'
                    ? reports
                    : reports.where((r) => r.status == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: colors.outline),
                        const SizedBox(height: 12),
                        Text(
                          _statusFilter != 'TODOS'
                              ? 'No hay reportes con estado "$_statusFilter"'
                              : 'No hay reportes',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: colors.outline),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(reportsProvider.notifier).fetchReports(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final r = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(r.status).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(r.status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      r.reportType,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    tooltip: 'Cambiar estado',
                                    onSelected: (newStatus) {
                                      ref
                                          .read(reportsProvider.notifier)
                                          .updateStatus(r.id, newStatus);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'OPEN',
                                        child: Text('🔴 Abierto'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'IN_PROGRESS',
                                        child: Text('🔵 En progreso'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'RESOLVED',
                                        child: Text('🟢 Resuelto'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'REJECTED',
                                        child: Text('⚪ Rechazado'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                r.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '📅 ${r.createdAt.toLocal().toString().split('.')[0]}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: color.withOpacity(0.2),
      onSelected: (_) => onTap(),
    );
  }
}
