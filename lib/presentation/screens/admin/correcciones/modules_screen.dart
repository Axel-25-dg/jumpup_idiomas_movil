// lib/presentation/screens/admin/modules_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/correcciones/course_provider.dart';
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
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController();
  String _searchQuery = '';
  ModuleModel? _editingModule;
  int? _selectedCourseId;

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
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(moduleNotifierProvider);
    final notifier = ref.read(moduleNotifierProvider.notifier);
    final coursesAsync = ref.watch(courseNotifierProvider);

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
            onPressed: () => _showAddEditDialog(context, coursesAsync),
            tooltip: 'Crear módulo',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: BrandedTextField(
              controller: _searchController,
              label: 'Buscar módulo',
              hint: 'ID de curso o nombre del módulo...',
              prefixIcon: Icons.search_rounded,
            ),
          ),

          // Lista de módulos
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: modulesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorView(error, notifier),
                data: (modules) {
                  final filtered =
                      modules.where((module) {
                        if (_searchQuery.isEmpty) return true;
                        return module.course.toString().contains(
                              _searchQuery,
                            ) ||
                            module.title.toLowerCase().contains(_searchQuery) ||
                            module.courseTitle.toLowerCase().contains(
                              _searchQuery,
                            );
                      }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      title:
                          _searchQuery.isEmpty
                              ? 'No hay módulos creados'
                              : 'No se encontraron módulos',
                      subtitle:
                          _searchQuery.isEmpty
                              ? 'Crea tu primer módulo para comenzar'
                              : 'Intenta con otro término de búsqueda',
                      icon: Icons.view_module_rounded,
                      buttonText:
                          _searchQuery.isEmpty
                              ? 'Crear módulo'
                              : 'Limpiar búsqueda',
                      onButtonPressed:
                          _searchQuery.isEmpty
                              ? () => _showAddEditDialog(context, coursesAsync)
                              : () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final module = filtered[index];
                      return _ModuleCard(
                        module: module,
                        onEdit:
                            () => _showAddEditDialog(
                              context,
                              coursesAsync,
                              module: module,
                            ),
                        onDelete:
                            () => _confirmDelete(context, module.id, notifier),
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
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
    AsyncValue<List<Course>> coursesAsync, {
    ModuleModel? module,
  }) {
    _editingModule = module;
    final isEditing = module != null;

    if (isEditing) {
      _titleController.text = module.title;
      _orderController.text = module.order.toString();
      _selectedCourseId = module.course;
    } else {
      _titleController.clear();
      _orderController.clear();
      _selectedCourseId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar módulo' : 'Crear módulo'),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Selector de curso con Dropdown
                      coursesAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error al cargar cursos'),
                        data:
                            (courses) => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Curso',
                                prefixIcon: Icon(Icons.menu_book_rounded),
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Selecciona un curso'),
                              value: _selectedCourseId,
                              items:
                                  courses.map((course) {
                                    return DropdownMenuItem(
                                      value: course.id,
                                      child: Text(
                                        '${course.title} (ID: ${course.id})',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                _selectedCourseId = value;
                                setDialogState(() {});
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Selecciona un curso'
                                          : null,
                            ),
                      ),
                      const SizedBox(height: 16),
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
                    if (_formKey.currentState!.validate() &&
                        _selectedCourseId != null) {
                      final notifier = ref.read(
                        moduleNotifierProvider.notifier,
                      );

                      final data = {
                        'course':
                            _selectedCourseId!, // Cambiado de 'course_id' a 'course'
                        'title': _titleController.text.trim(),
                        'order': int.parse(_orderController.text.trim()),
                      };

                      if (isEditing) {
                        notifier.updateModule(_editingModule!.id, data);
                      } else {
                        notifier.addModule(data);
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

  void _confirmDelete(
    BuildContext context,
    int moduleId,
    ModuleNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
                  notifier.deleteModule(moduleId, 0);
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
              'Curso: ${module.courseTitle} (ID: ${module.course})',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
