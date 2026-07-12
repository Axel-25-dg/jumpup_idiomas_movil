// lib/presentation/screens/admin/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/report_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/report_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';


class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'TODOS';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportNotifierProvider);
    final notifier = ref.read(reportNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reportes de Contenido'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: BrandedTextField(
              controller: _searchController,
              label: 'Buscar reporte',
              hint: 'Tipo, descripción o usuario...',
              prefixIcon: Icons.search_rounded,
            ),
          ),
          // ✅ Filtros por estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'Todos',
                    selected: _statusFilter == 'TODOS',
                    onSelected: () => setState(() => _statusFilter = 'TODOS'),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Pendiente',
                    selected: _statusFilter == 'OPEN',
                    onSelected: () => setState(() => _statusFilter = 'OPEN'),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'En progreso',
                    selected: _statusFilter == 'IN_PROGRESS',
                    onSelected: () => setState(() => _statusFilter = 'IN_PROGRESS'),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Resuelto',
                    selected: _statusFilter == 'RESOLVED',
                    onSelected: () => setState(() => _statusFilter = 'RESOLVED'),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'Rechazado',
                    selected: _statusFilter == 'REJECTED',
                    onSelected: () => setState(() => _statusFilter = 'REJECTED'),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ✅ Lista de reportes
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorView(error, notifier),
                data: (reports) {
                  final filtered = _filterReports(reports);
                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: _searchQuery.isNotEmpty
                          ? 'No se encontraron reportes'
                          : 'No hay reportes',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'Intenta con otro término de búsqueda'
                          : _statusFilter != 'TODOS'
                              ? 'No hay reportes con el estado seleccionado'
                              : 'Todos los reportes han sido procesados',
                      icon: Icons.flag_rounded,
                      buttonText: _searchQuery.isNotEmpty ? 'Limpiar búsqueda' : null,
                      onButtonPressed: _searchQuery.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            }
                          : null,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final report = filtered[index];
                      return _ReportCard(
                        report: report,
                        onUpdateStatus: (status) {
                          notifier.updateReport(report.id, {'status': status});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Report> _filterReports(List<Report> reports) {
    var filtered = reports;
    // ✅ Filtrar por estado
    if (_statusFilter != 'TODOS') {
      filtered = filtered.where((r) => r.status == _statusFilter).toList();
    }
    // ✅ Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) =>
        r.reportType.toLowerCase().contains(_searchQuery) ||
        r.description.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    return filtered;
  }

  Widget _buildErrorView(Object error, ReportNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar reportes', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
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
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.white,
      selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.2),
      checkmarkColor: color ?? AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? (color ?? AppColors.primary) : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  const _ReportCard({
    required this.report,
    required this.onUpdateStatus,
  });

  final Report report;
  final Function(String) onUpdateStatus;

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'OPEN':
        return 'Pendiente';
      case 'IN_PROGRESS':
        return 'En progreso';
      case 'RESOLVED':
        return 'Resuelto';
      case 'REJECTED':
        return 'Rechazado';
      default:
        return status;
    }
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    const all = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'];
    return all.where((s) => s != currentStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.report.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            title: Text(
              'Reporte #${widget.report.id}',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  widget.report.reportType,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.report.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(widget.report.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(widget.report.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),
          // Actions (expandido)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Cambiar estado:',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getAvailableStatuses(widget.report.status).map((status) {
                      return PrimaryButton(
                        label: _getStatusLabel(status),
                        onPressed: () => widget.onUpdateStatus(status),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace unos segundos';
    }
  }
}