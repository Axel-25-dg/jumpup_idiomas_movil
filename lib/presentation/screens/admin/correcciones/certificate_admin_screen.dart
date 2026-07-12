// lib/presentation/screens/admin/certificates_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/certificate_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/certificate_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/user_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class CertificatesAdminScreen extends ConsumerStatefulWidget {
  const CertificatesAdminScreen({super.key});

  @override
  ConsumerState<CertificatesAdminScreen> createState() => _CertificatesAdminScreenState();
}

class _CertificatesAdminScreenState extends ConsumerState<CertificatesAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'TODOS';
  int? _selectedStudentId;
  String? _selectedLevel;

  final List<Map<String, String>> _levels = [
    {'value': 'A1', 'label': 'Principiante A1'},
    {'value': 'A2', 'label': 'Elemental A2'},
    {'value': 'B1', 'label': 'Intermedio B1'},
    {'value': 'B2', 'label': 'Intermedio Alto B2'},
    {'value': 'C1', 'label': 'Avanzado C1'},
    {'value': 'C2', 'label': 'Maestría C2'},
  ];

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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificatesAsync = ref.watch(certificateNotifierProvider);
    final notifier = ref.read(certificateNotifierProvider.notifier);
    final studentsAsync = ref.watch(studentsProvider);

    final filteredCertificates = certificatesAsync.when(
      data: (certificates) {
        if (_searchQuery.isEmpty && _statusFilter == 'TODOS') {
          return AsyncValue.data(certificates);
        }
        final filtered = certificates.where((c) {
          final matchSearch = _searchQuery.isEmpty ||
              c.title.toLowerCase().contains(_searchQuery) ||
              (c.studentEmail?.toLowerCase().contains(_searchQuery) ?? false) ||
              (c.certificateCode?.toLowerCase().contains(_searchQuery) ?? false);
          final matchStatus = _statusFilter == 'TODOS' || c.status == _statusFilter;
          return matchSearch && matchStatus;
        }).toList();
        return AsyncValue.data(filtered);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, stack) => AsyncValue.error(e, stack),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Certificados'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context, studentsAsync),
            tooltip: 'Crear certificado',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BrandedTextField(
                controller: _searchController,
                label: 'Buscar certificado',
                hint: 'Título, estudiante o código...',
                prefixIcon: Icons.search_rounded,
              ),
            ),
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
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'Pendiente',
                      selected: _statusFilter == 'pending',
                      onSelected: () => setState(() => _statusFilter = 'pending'),
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'Emitido',
                      selected: _statusFilter == 'issued',
                      onSelected: () => setState(() => _statusFilter = 'issued'),
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: 'Revocado',
                      selected: _statusFilter == 'revoked',
                      onSelected: () => setState(() => _statusFilter = 'revoked'),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LoadingOverlay(
                isLoading: filteredCertificates.isLoading,
                child: filteredCertificates.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorView(error, notifier),
                  data: (certificates) {
                    if (certificates.isEmpty) {
                      return EmptyState(
                        title: _searchQuery.isNotEmpty
                            ? 'No se encontraron certificados'
                            : 'No hay certificados',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Intenta con otro término de búsqueda'
                            : 'Crea tu primer certificado para comenzar',
                        icon: Icons.verified_rounded,
                        buttonText: _searchQuery.isEmpty ? 'Crear certificado' : 'Limpiar búsqueda',
                        onButtonPressed: _searchQuery.isEmpty
                            ? () => _showAddEditDialog(context, studentsAsync)
                            : () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        final certificate = certificates[index];
                        return _CertificateCard(
                          certificate: certificate,
                          onIssue: certificate.status == 'pending'
                              ? () => notifier.issueCertificate(certificate.id!)
                              : null,
                          onRevoke: certificate.status == 'issued'
                              ? () => notifier.revokeCertificate(certificate.id!)
                              : null,
                          onEdit: () => _showAddEditDialog(
                            context,
                            studentsAsync,
                            certificate: certificate,
                          ),
                          onDelete: () => _confirmDelete(
                            context,
                            certificate.id!,
                            notifier,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error, CertificateNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar certificados', style: AppTextStyles.titleMedium),
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

  void _showAddEditDialog(
    BuildContext context,
    AsyncValue<List<User>> studentsAsync, {
    Certificate? certificate,
  }) {
    final isEditing = certificate != null;

    if (isEditing) {
      _titleController.text = certificate.title;
      _descriptionController.text = certificate.description ?? '';
      _selectedStudentId = certificate.student;
      _selectedLevel = certificate.level;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _selectedStudentId = null;
      _selectedLevel = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        int? localStudentId = _selectedStudentId;
        String? localLevel = _selectedLevel;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar certificado' : 'Crear certificado'),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        studentsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error al cargar estudiantes'),
                          data: (students) {
                            return DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Estudiante',
                                prefixIcon: Icon(Icons.person_rounded),
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Selecciona un estudiante'),
                              value: localStudentId,
                              items: students.map((user) {
                                final displayName = '${user.firstName} ${user.lastName}'.trim();
                                final displayText = displayName.isNotEmpty 
                                    ? displayName 
                                    : user.username;
                                return DropdownMenuItem(
                                  value: user.id,
                                  child: Text(
                                    displayText,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                localStudentId = value;
                                setDialogState(() {});
                              },
                              validator: (value) => value == null ? 'Selecciona un estudiante' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: localLevel,
                          decoration: const InputDecoration(
                            labelText: 'Nivel',
                            prefixIcon: Icon(Icons.signal_cellular_alt_rounded),
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Selecciona un nivel'),
                          items: _levels.map((level) {
                            return DropdownMenuItem(
                              value: level['value'],
                              child: Text(level['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            localLevel = value;
                            setDialogState(() {});
                          },
                          validator: (value) => value == null ? 'Selecciona un nivel' : null,
                        ),
                        const SizedBox(height: 16),
                        BrandedTextField(
                          controller: _titleController,
                          label: 'Título',
                          prefixIcon: Icons.title_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El título es obligatorio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        BrandedTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          prefixIcon: Icons.description_rounded,
                          maxLines: 3,
                        ),
                        if (isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                Icon(
                                  certificate.status == 'issued'
                                      ? Icons.check_circle_rounded
                                      : certificate.status == 'revoked'
                                          ? Icons.cancel_rounded
                                          : Icons.pending_rounded,
                                  color: certificate.status == 'issued'
                                      ? Colors.green
                                      : certificate.status == 'revoked'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Estado: ${certificate.statusDisplay ?? certificate.status}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                PrimaryButton(
                  label: isEditing ? 'Actualizar' : 'Crear',
                  onPressed: () {
                    if (_formKey.currentState!.validate() && localStudentId != null && localLevel != null) {
                      final notifier = ref.read(certificateNotifierProvider.notifier);

                      final data = {
                        'student': localStudentId!,
                        'level': localLevel!,
                        'title': _titleController.text.trim(),
                        'description': _descriptionController.text.trim(),
                      };

                      if (isEditing) {
                        notifier.updateCertificate(certificate.id!, data);
                      } else {
                        notifier.createCertificate(data);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int id, CertificateNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar certificado'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este certificado?\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteCertificate(id);
              Navigator.pop(ctx);
            },
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

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.certificate,
    required this.onIssue,
    required this.onRevoke,
    required this.onEdit,
    required this.onDelete,
  });

  final Certificate certificate;
  final VoidCallback? onIssue;
  final VoidCallback? onRevoke;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'issued':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'revoked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'issued':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.pending_rounded;
      case 'revoked':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(certificate.status);

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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(certificate.status),
                color: statusColor,
              ),
            ),
            title: Text(
              certificate.title,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estudiante: ${certificate.studentEmail ?? ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
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
                        certificate.statusDisplay ?? certificate.status,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        certificate.levelDisplay ?? certificate.level,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.purple,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Código: ${certificate.certificateCode ?? 'N/A'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.blue,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onIssue != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                    onPressed: onIssue,
                    tooltip: 'Emitir',
                  ),
                if (onRevoke != null)
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                    onPressed: onRevoke,
                    tooltip: 'Revocar',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: onEdit,
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: onDelete,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}