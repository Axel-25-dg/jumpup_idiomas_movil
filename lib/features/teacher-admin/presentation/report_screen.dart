import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/providers/report_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RESOLVED': return Colors.green.shade200;
      case 'IN_PROGRESS': return Colors.blue.shade200;
      case 'REJECTED': return Colors.red.shade200;
      default: return Colors.orange.shade200;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Reportes')),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar: $e')),
        data: (reports) => ListView.builder(
          itemCount: reports.length,
          itemBuilder: (ctx, i) {
            final r = reports[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text(r.reportType, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${r.description}\n${r.createdAt.toLocal().toString().split('.')[0]}"),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  child: Chip(
                    label: Text(r.status),
                    backgroundColor: _getStatusColor(r.status),
                  ),
                  onSelected: (newStatus) {
                    ref.read(reportsProvider.notifier).updateStatus(r.id, newStatus);
                  },
                  itemBuilder: (_) => ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'REJECTED']
                      .map((status) => PopupMenuItem(value: status, child: Text(status)))
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}