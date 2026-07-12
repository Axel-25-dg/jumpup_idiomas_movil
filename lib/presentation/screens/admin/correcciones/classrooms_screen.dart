// lib/presentation/screens/admin/classrooms_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';


class ClassroomsScreen extends ConsumerStatefulWidget {
  const ClassroomsScreen({super.key});

  @override
  ConsumerState<ClassroomsScreen> createState() => _ClassroomsScreenState();
}

class _ClassroomsScreenState extends ConsumerState<ClassroomsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _searchQuery = '';
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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classroomsAsync = ref.watch(classroomNotifierProvider);
    final notifier = ref.read(classroomNotifierProvider.notifier);
    final coursesAsync = ref.watch(coursesProvider);

    // ✅ Filtrar aulas por búsqueda
    final filteredClassrooms = classroomsAsync.when(
      data: (classrooms) {
        if (_searchQuery.isEmpty) return AsyncValue.data(classrooms);
        final filtered = classrooms.where((c) =>
          c.name.toLowerCase().contains(_searchQuery) ||
          c.description.toLowerCase().contains(_searchQuery) ||
          c.accessCode.toLowerCase().contains(_searchQuery) ||
          (c.courseName?.toLowerCase().contains(_searchQuery) ?? false) ||
          c.courseId?.toString().contains(_searchQuery) == true
        ).toList();
        return AsyncValue.data(filtered);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, stack) => AsyncValue.error(e, stack),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Aulas'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context, coursesAsync),
            tooltip: 'Crear aula',
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
            // ✅ Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: BrandedTextField(
                controller: _searchController,
                label: 'Buscar aula',
                hint: 'Nombre, descripción, código o curso...',
                prefixIcon: Icons.search_rounded,
              ),
            ),
            // Lista de aulas
            Expanded(
              child: LoadingOverlay(
                isLoading: filteredClassrooms.isLoading,
                child: filteredClassrooms.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorView(error, notifier),
                  data: (classrooms) {
                    if (classrooms.isEmpty) {
                      return EmptyState(
                        title: _searchQuery.isEmpty
                            ? 'No hay aulas creadas'
                            : 'No se encontraron aulas',
                        subtitle: _searchQuery.isEmpty
                            ? 'Crea tu primera aula para comenzar'
                            : 'Intenta con otro término de búsqueda',
                        icon: Icons.class_rounded,
                        buttonText: _searchQuery.isEmpty ? 'Crear aula' : 'Limpiar búsqueda',
                        onButtonPressed: _searchQuery.isEmpty
                            ? () => _showAddEditDialog(context, coursesAsync)
                            : () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: classrooms.length,
                      itemBuilder: (context, index) {
                        final classroom = classrooms[index];
                        return _ClassroomCard(
                          classroom: classroom,
                          onEdit: () => _showAddEditDialog(
                            context,
                            coursesAsync,
                            classroom: classroom,
                          ),
                          onDelete: () => _confirmDelete(
                            context,
                            classroom.id,
                            notifier,
                          ),
                          onViewStudents: () => _showStudentsDialog(
                            context,
                            classroom.id,
                            classroom.name,
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

  Widget _buildErrorView(Object error, ClassroomNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar aulas', style: AppTextStyles.titleMedium),
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
    AsyncValue<List<Course>> coursesAsync, {
    ClassroomModel? classroom,
  }) {
    if (classroom != null) {
      _nameController.text = classroom.name;
      _descriptionController.text = classroom.description;
      _selectedCourseId = classroom.courseId;
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _selectedCourseId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        int? localCourseId = _selectedCourseId;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(classroom != null ? 'Editar aula' : 'Crear aula'),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrandedTextField(
                        controller: _nameController,
                        label: 'Nombre del aula',
                        prefixIcon: Icons.class_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es obligatorio';
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
                      const SizedBox(height: 16),
                      coursesAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error al cargar cursos'),
                        data: (courses) => DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Curso',
                            prefixIcon: Icon(Icons.menu_book_rounded),
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Selecciona un curso'),
                          value: localCourseId,
                          items: courses.map((course) {
                            return DropdownMenuItem(
                              value: course.id,
                              child: Text('${course.title} (ID: ${course.id})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            localCourseId = value;
                            setDialogState(() {});
                          },
                          validator: (value) => value == null ? 'Selecciona un curso' : null,
                        ),
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
                  label: classroom != null ? 'Actualizar' : 'Crear',
                  onPressed: () {
                    if (_formKey.currentState!.validate() && localCourseId != null) {
                      final notifier = ref.read(classroomNotifierProvider.notifier);

                      if (classroom != null) {
                        notifier.updateClassroom(
                          id: classroom.id,
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                        );
                      } else {
                        notifier.addClassroom(
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                          courseId: localCourseId!,
                        );
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

  void _confirmDelete(BuildContext context, int id, ClassroomNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar aula'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta aula?\n'
          'Esta acción eliminará todas las inscripciones asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteClassroom(id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showStudentsDialog(BuildContext context, int classroomId, String className) {
    final enrollmentsAsync = ref.watch(enrollmentsProvider(classroomId));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alumnos de $className'),
        content: SizedBox(
          width: 400,
          height: 400,
          child: enrollmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error al cargar alumnos: $error',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
            data: (enrollments) {
              if (enrollments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'No hay alumnos inscritos',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: enrollments.length,
                itemBuilder: (context, index) {
                  final enrollment = enrollments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        enrollment.studentUsername.isNotEmpty
                            ? enrollment.studentUsername[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      enrollment.studentUsername,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      enrollment.studentEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_rounded, color: AppColors.error),
                      onPressed: () {
                        final notifier = ref.read(classroomNotifierProvider.notifier);
                        notifier.removeStudent(enrollment.id);
                        ref.invalidate(enrollmentsProvider(classroomId));
                        if (mounted) {
                          Navigator.pop(ctx);
                          _showStudentsDialog(context, classroomId, className);
                        }
                      },
                      tooltip: 'Eliminar alumno',
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  const _ClassroomCard({
    required this.classroom,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStudents,
  });

  final ClassroomModel classroom;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStudents;

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
            color: const Color(0xFFE65100).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.class_rounded,
            color: Color(0xFFE65100),
          ),
        ),
        title: Text(
          classroom.name,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (classroom.description.isNotEmpty) ...[
              Text(
                classroom.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Curso: ${classroom.courseName ?? 'ID ${classroom.courseId}'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: classroom.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    classroom.isActive ? 'Activo' : 'Inactivo',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: classroom.isActive ? Colors.green : Colors.red,
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
                    'Código: ${classroom.accessCode}',
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
            IconButton(
              icon: const Icon(Icons.people_rounded, size: 20),
              onPressed: onViewStudents,
              color: Colors.blue,
              tooltip: 'Ver alumnos',
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