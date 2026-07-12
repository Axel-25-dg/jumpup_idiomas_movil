// lib/presentation/screens/admin/resources_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/domain/model/resource_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/course_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/lesson_provider.dart';
import 'package:jumpup_app/presentation/providers/correcciones/resource_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/loading_overlay.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';


class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _fileUrlController = TextEditingController();
  String _searchQuery = '';
  String _selectedResourceType = 'pdf';
  bool _isPublic = true;
  int? _selectedCourseId;
  int? _selectedLessonId;
  TeacherResource? _editingResource;

  final List<Map<String, String>> _resourceTypes = [
    {'value': 'pdf', 'label': 'PDF'},
    {'value': 'audio', 'label': 'Audio'},
    {'value': 'video', 'label': 'Video'},
    {'value': 'word', 'label': 'Documento Word'},
    {'value': 'image', 'label': 'Imagen'},
    {'value': 'link', 'label': 'Enlace externo'},
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
    _fileUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(resourceNotifierProvider);
    final notifier = ref.read(resourceNotifierProvider.notifier);
    final coursesAsync = ref.watch(coursesProvider);

    final filteredResources = resourcesAsync.when(
      data: (resources) {
        if (_searchQuery.isEmpty) return AsyncValue.data(resources);
        final filtered = resources.where((r) =>
          r.title.toLowerCase().contains(_searchQuery) ||
          r.description.toLowerCase().contains(_searchQuery) ||
          r.resourceTypeDisplay.toLowerCase().contains(_searchQuery) ||
          r.courseTitle.toLowerCase().contains(_searchQuery)
        ).toList();
        return AsyncValue.data(filtered);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, stack) => AsyncValue.error(e, stack),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Recursos'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEditDialog(context, coursesAsync),
            tooltip: 'Subir recurso',
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
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: BrandedTextField(
                controller: _searchController,
                label: 'Buscar recurso',
                hint: 'Título, descripción o tipo...',
                prefixIcon: Icons.search_rounded,
              ),
            ),
            // Lista de recursos
            Expanded(
              child: LoadingOverlay(
                isLoading: filteredResources.isLoading,
                child: filteredResources.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorView(error, notifier),
                  data: (resources) {
                    if (resources.isEmpty) {
                      return EmptyState(
                        title: _searchQuery.isEmpty
                            ? 'No hay recursos'
                            : 'No se encontraron recursos',
                        subtitle: _searchQuery.isEmpty
                            ? 'Sube tu primer recurso para comenzar'
                            : 'Intenta con otro término de búsqueda',
                        icon: Icons.folder_rounded,
                        buttonText: _searchQuery.isEmpty ? 'Subir recurso' : 'Limpiar búsqueda',
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
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        final resource = resources[index];
                        return _ResourceCard(
                          resource: resource,
                          onEdit: () => _showAddEditDialog(
                            context,
                            coursesAsync,
                            resource: resource,
                          ),
                          onDelete: () => _confirmDelete(
                            context,
                            resource.id,
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

  Widget _buildErrorView(Object error, ResourceNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar recursos', style: AppTextStyles.titleMedium),
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
    TeacherResource? resource,
  }) {
    _editingResource = resource;
    final isEditing = resource != null;

    if (isEditing) {
      _titleController.text = resource.title;
      _descriptionController.text = resource.description;
      _fileUrlController.text = resource.fileUrl ?? '';
      _selectedResourceType = resource.resourceType;
      _isPublic = resource.isPublic;
      _selectedCourseId = resource.course;
      _selectedLessonId = resource.lesson;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _fileUrlController.clear();
      _selectedResourceType = 'pdf';
      _isPublic = true;
      _selectedCourseId = null;
      _selectedLessonId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        int? localCourseId = _selectedCourseId;
        int? localLessonId = _selectedLessonId;
        String localResourceType = _selectedResourceType;
        bool localIsPublic = _isPublic;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // ✅ Lecciones del curso seleccionado
            final localLessonsAsync = localCourseId != null
                ? ref.watch(lessonsByModuleProvider(localCourseId!))
                : const AsyncValue<List<LessonModel>>.loading();

            return AlertDialog(
              title: Text(isEditing ? 'Editar recurso' : 'Subir recurso'),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Curso
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
                              localLessonId = null;
                              setDialogState(() {});
                            },
                            validator: (value) => value == null ? 'Selecciona un curso' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Lección (opcional)
                        localLessonsAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Error al cargar lecciones'),
                          data: (lessons) => DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Lección (opcional)',
                              prefixIcon: Icon(Icons.book_rounded),
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Selecciona una lección'),
                            value: localLessonId,
                            items: lessons.map((lesson) {
                              return DropdownMenuItem(
                                value: lesson.id,
                                child: Text('${lesson.title} (ID: ${lesson.id})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              localLessonId = value;
                              setDialogState(() {});
                            },
                          ),
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
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: localResourceType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de recurso',
                            prefixIcon: Icon(Icons.folder_rounded),
                            border: OutlineInputBorder(),
                          ),
                          items: _resourceTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'],
                              child: Text(type['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            localResourceType = value!;
                            setDialogState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        BrandedTextField(
                          controller: _fileUrlController,
                          label: 'URL del archivo',
                          hint: 'https://...',
                          prefixIcon: Icons.link_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La URL es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: localIsPublic,
                              onChanged: (value) {
                                localIsPublic = value!;
                                setDialogState(() {});
                              },
                              activeColor: AppColors.primary,
                            ),
                            const Text('Público'),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
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
                  label: isEditing ? 'Actualizar' : 'Subir',
                  onPressed: () {
                    if (_formKey.currentState!.validate() && localCourseId != null) {
                      final notifier = ref.read(resourceNotifierProvider.notifier);

                      final Map<String, dynamic> data = {
                        'course': localCourseId!,
                        'title': _titleController.text.trim(),
                        'description': _descriptionController.text.trim(),
                        'resource_type': localResourceType,
                        'file_url': _fileUrlController.text.trim(),
                        'is_public': localIsPublic,
                      };

                      if (localLessonId != null) {
                        data['lesson'] = localLessonId;
                      }

                      if (isEditing && _editingResource != null) {
                        notifier.updateResource(_editingResource!.id, data);
                      } else {
                        notifier.uploadResource(data);
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

  void _confirmDelete(BuildContext context, int id, ResourceNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar recurso'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este recurso?\n'
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
              notifier.deleteResource(id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.onEdit,
    required this.onDelete,
  });

  final TeacherResource resource;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _getTypeColor(String type) {
    switch (type) {
      case 'pdf':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'video':
        return Colors.blue;
      case 'word':
        return Colors.blue;
      case 'image':
        return Colors.green;
      case 'link':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'word':
        return Icons.description_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'link':
        return Icons.link_rounded;
      default:
        return Icons.folder_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(resource.resourceType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(resource.resourceType),
            color: typeColor,
          ),
        ),
        title: Text(
          resource.title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Curso: ${resource.courseTitle}',
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
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    resource.resourceTypeDisplay,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: typeColor,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: resource.isPublic
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    resource.isPublic ? 'Público' : 'Privado',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: resource.isPublic ? Colors.green : Colors.grey,
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