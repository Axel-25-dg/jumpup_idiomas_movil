import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/announcement_provider.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Anuncios del Sistema')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create_announcement',
        icon: const Icon(Icons.add),
        label: const Text('Nuevo anuncio'),
        onPressed: () => _showCreateDialog(context, ref),
      ),
      body: announcementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 12),
              Text('Error: $err'),
            ],
          ),
        ),
        data: (announcements) {
          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 64, color: colors.outline),
                  const SizedBox(height: 12),
                  Text(
                    'No hay anuncios disponibles.',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: colors.outline),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primer anuncio'),
                    onPressed: () => _showCreateDialog(context, ref),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(announcementsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final item = announcements[index];
                final isExpired = item.endDate.isBefore(DateTime.now());
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isExpired
                        ? BorderSide(color: colors.outlineVariant)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? colors.outlineVariant
                                    : colors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.campaign,
                                color:
                                    isExpired ? colors.outline : colors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isExpired ? colors.outline : null,
                                    ),
                                  ),
                                  if (isExpired)
                                    Text(
                                      'Vencido',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.error,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (!isExpired)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Activo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.content,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📅 ${item.startDate.toLocal().toString().split(' ')[0]} → ${item.endDate.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.bodySmall?.copyWith(
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
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    DateTimeRange? dateRange;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nuevo anuncio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    dateRange != null
                        ? '${dateRange!.start.toLocal().toString().split(' ')[0]} → ${dateRange!.end.toLocal().toString().split(' ')[0]}'
                        : 'Seleccionar fechas',
                  ),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: ctx,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 7)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => dateRange = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: titleCtrl.text.isEmpty ||
                      contentCtrl.text.isEmpty ||
                      dateRange == null
                  ? null
                  : () async {
                      try {
                        // Add POST call here once backend endpoint exists
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Funcionalidad de creación próximamente')),
                        );
                      } catch (e) {
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
