// lib/presentation/screens/admin/announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/announcement_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementNotifierProvider);
    final notifier = ref.read(announcementNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Anuncios y Avisos'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context),
            tooltip: 'Crear anuncio',
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
        child: announcementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(error, notifier),
          data: (announcements) {
            if (announcements.isEmpty) {
              return EmptyState(
                title: 'No hay anuncios',
                subtitle: 'Crea tu primer anuncio para comunicarte con los usuarios',
                icon: Icons.campaign_rounded,
                buttonText: 'Crear anuncio',
                onButtonPressed: () => _showAddEditDialog(context),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _AnnouncementCard(
                  announcement: announcement,
                  onEdit: () => _showAddEditDialog(
                    context,
                    announcement: announcement,
                  ),
                  onDelete: () => _confirmDelete(
                    context,
                    announcement.id,
                    notifier,
                  ),
                  onToggleStatus: () {
                    notifier.updateAnnouncement(
                      id: announcement.id,
                      title: announcement.title,
                      content: announcement.content,
                      startDate: announcement.startDate,
                      endDate: announcement.endDate,
                      isActive: !announcement.isActive,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error, AnnouncementNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
           Text('Error al cargar anuncios', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
           SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Announcement? announcement}) {

    if (announcement != null) {
      _titleController.text = announcement.title;
      _contentController.text = announcement.content;
      _startDate = announcement.startDate;
      _endDate = announcement.endDate;
      _isActive = announcement.isActive;
    } else {
      _titleController.clear();
      _contentController.clear();
      _startDate = null;
      _endDate = null;
      _isActive = true;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(announcement != null ? 'Editar anuncio' : 'Crear anuncio'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandedTextField(
                  controller: _titleController,
                  label: 'Título del anuncio',
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
                  controller: _contentController,
                  label: 'Contenido',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El contenido es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Fecha inicio',
                        date: _startDate,
                        onChanged: (date) => setState(() => _startDate = date),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DatePickerField(
                        label: 'Fecha fin',
                        date: _endDate,
                        onChanged: (date) => setState(() => _endDate = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value ?? true),
                    ),
                    const Text('Activo'),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: announcement != null ? 'Actualizar' : 'Publicar',
            onPressed: () {
              if (_formKey.currentState!.validate() && _startDate != null && _endDate != null) {
                final notifier = ref.read(announcementNotifierProvider.notifier);

                if (announcement != null) {
                  notifier.updateAnnouncement(
                    id: announcement.id,
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    startDate: _startDate!,
                    endDate: _endDate!,
                    isActive: _isActive,
                  );
                } else {
                  notifier.createAnnouncement(
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    startDate: _startDate!,
                    endDate: _endDate!,
                    isActive: _isActive,
                  );
                }
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, AnnouncementNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar anuncio'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este anuncio?\n'
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
              notifier.deleteAnnouncement(id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onChanged,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date!.day}/${date!.month}/${date!.year}'
                        : 'Seleccionar fecha',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: date != null ? AppColors.textPrimary : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final Announcement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool get _isActive {
    final now = DateTime.now();
    return announcement.isActive &&
        announcement.startDate.isBefore(now) &&
        announcement.endDate.isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.campaign_rounded,
            color: isActive ? AppColors.primary : Colors.grey,
          ),
        ),
        title: Text(
          announcement.title,
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
              announcement.content,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isActive ? Colors.green : Colors.red,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(announcement.startDate)} → ${_formatDate(announcement.endDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                announcement.isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: announcement.isActive ? Colors.green : Colors.grey,
                size: 20,
              ),
              onPressed: onToggleStatus,
              tooltip: announcement.isActive ? 'Desactivar' : 'Activar',
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
    );
  }
}