// lib/presentation/screens/admin/modules_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/correcciones/module_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class ModulesScreen extends ConsumerStatefulWidget {
  const ModulesScreen({super.key});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController();
  int? _currentCourseId;
  ModuleModel? _editingModule;

  @override
  void dispose() {
    _courseIdController.dispose();
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsync = _currentCourseId != null
        ? ref.watch(modulesByCourseProvider(_currentCourseId!))
        : const AsyncValue<List<ModuleModel>>.loading();

    final notifier = ref.read(moduleNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Módulos'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _currentCourseId != null
                ? () => _showAddEditDialog(context)
                : null,
            tooltip: 'Crear módulo',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _currentCourseId != null
                ? () => notifier.refresh(_currentCourseId!)
                : null,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Campo de búsqueda por ID de Curso
              BrandedTextField(
                controller: _courseIdController,
                label: 'ID de Curso',
                hint: 'Ej: 1, 2, 3...',
                prefixIcon: Icons.menu_book_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Buscar',
                onPressed: () {
                  final id = int.tryParse(_courseIdController.text);
                  if (id != null && id > 0) {
                    setState(() => _currentCourseId = id);
                    notifier.refresh(id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa un ID de curso válido'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: Icons.search_rounded,
              ),
              const SizedBox(height: 16),

              // Lista de módulos
              Expanded(
                child: _currentCourseId == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Busca un curso para ver sus módulos',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ingresa el ID del curso y presiona Buscar',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => notifier.refresh(_currentCourseId!),
                        child: modulesAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => _buildErrorView(error, notifier),
                          data: (modules) {
                            if (modules.isEmpty) {
                              return Center(
                                child: EmptyState(
                                  title: 'No hay módulos',
                                  subtitle: 'Crea el primer módulo para este curso',
                                  icon: Icons.view_module_rounded,
                                  buttonText: 'Crear módulo',
                                  onButtonPressed: () => _showAddEditDialog(context),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: modules.length,
                              itemBuilder: (context, index) {
                                final module = modules[index];
                                return _ModuleCard(
                                  module: module,
                                  onEdit: () => _showAddEditDialog(
                                    context,
                                    module: module,
                                  ),
                                  onDelete: () => _confirmDelete(
                                    context,
                                    module.id,
                                    _currentCourseId!,
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
      ),
    );
  }

  Widget _buildErrorView(Object error, ModuleNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar módulos', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(_currentCourseId!),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {ModuleModel? module}) {
    _editingModule = module;
    final isEditing = module != null;

    if (isEditing) {
      _titleController.text = module.title;
      _orderController.text = module.order.toString();
    } else {
      _titleController.clear();
      _orderController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar módulo' : 'Crear módulo'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandedTextField(
                  controller: _titleController,
                  label: 'Título del módulo',
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
                  controller: _orderController,
                  label: 'Orden',
                  hint: 'Ej: 1, 2, 3...',
                  prefixIcon: Icons.sort_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El orden es obligatorio';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
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
            label: isEditing ? 'Actualizar' : 'Guardar',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final notifier = ref.read(moduleNotifierProvider.notifier);

                final data = {
                  'course_id': _currentCourseId!,
                  'title': _titleController.text.trim(),
                  'order': int.parse(_orderController.text.trim()),
                };

                if (isEditing) {
                  // ✅ ACTUALIZAR MÓDULO
                  notifier.updateModule(_editingModule!.id, data);
                } else {
                  // ✅ CREAR MÓDULO
                  notifier.addModule(data);
                }
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int moduleId,
    int courseId,
    ModuleNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar módulo'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este módulo?\n'
          'Esta acción eliminará todas las lecciones asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteModule(moduleId, courseId);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.module,
    required this.onEdit,
    required this.onDelete,
  });

  final ModuleModel module;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.view_module_rounded,
            color: Color(0xFF6A1B9A),
          ),
        ),
        title: Text(
          module.title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Curso: ${module.courseTitle}',
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Orden: ${module.order}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.blue,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${module.lessonsCount} lecciones',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.orange,
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