// lib/presentation/screens/admin/lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/correcciones/lesson_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _moduleIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController();
  final _xpRewardController = TextEditingController();
  String _selectedContentType = 'text';
  int? _currentModuleId;
  LessonModel? _editingLesson;

  final List<Map<String, String>> _contentTypes = [
    {'value': 'text', 'label': 'Texto'},
    {'value': 'video', 'label': 'Video'},
    {'value': 'audio', 'label': 'Audio'},
    {'value': 'quiz', 'label': 'Quiz'},
    {'value': 'interactive', 'label': 'Interactivo'},
  ];

  @override
  void dispose() {
    _moduleIdController.dispose();
    _titleController.dispose();
    _orderController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = _currentModuleId != null
        ? ref.watch(lessonsByModuleProvider(_currentModuleId!))
        : const AsyncValue<List<LessonModel>>.loading();

    final notifier = ref.read(lessonNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestión de Lecciones'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _currentModuleId != null
                ? () => _showAddEditDialog(context)
                : null,
            tooltip: 'Crear lección',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _currentModuleId != null
                ? () => notifier.refresh(_currentModuleId!)
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
              // Campo de búsqueda por ID de Módulo
              BrandedTextField(
                controller: _moduleIdController,
                label: 'ID de Módulo',
                hint: 'Ej: 1, 2, 3...',
                prefixIcon: Icons.view_module_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Buscar',
                onPressed: () {
                  final id = int.tryParse(_moduleIdController.text);
                  if (id != null && id > 0) {
                    setState(() => _currentModuleId = id);
                    notifier.refresh(id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa un ID de módulo válido'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: Icons.search_rounded,
              ),
              const SizedBox(height: 16),

              // Lista de lecciones
              Expanded(
                child: _currentModuleId == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Busca un módulo para ver sus lecciones',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ingresa el ID del módulo y presiona Buscar',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => notifier.refresh(_currentModuleId!),
                        child: lessonsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => _buildErrorView(error, notifier),
                          data: (lessons) {
                            if (lessons.isEmpty) {
                              return Center(
                                child: EmptyState(
                                  title: 'No hay lecciones',
                                  subtitle: 'Crea la primera lección para este módulo',
                                  icon: Icons.menu_book_rounded,
                                  buttonText: 'Crear lección',
                                  onButtonPressed: () => _showAddEditDialog(context),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                return _LessonCard(
                                  lesson: lesson,
                                  onEdit: () => _showAddEditDialog(
                                    context,
                                    lesson: lesson,
                                  ),
                                  onDelete: () => _confirmDelete(
                                    context,
                                    lesson.id,
                                    _currentModuleId!,
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

  Widget _buildErrorView(Object error, LessonNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error al cargar lecciones', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            onPressed: () => notifier.refresh(_currentModuleId!),
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {LessonModel? lesson}) {
    _editingLesson = lesson;
    final isEditing = lesson != null;

    if (isEditing) {
      _titleController.text = lesson.title;
      _orderController.text = lesson.order.toString();
      _xpRewardController.text = lesson.xpReward.toString();
      _selectedContentType = lesson.contentType;
    } else {
      _titleController.clear();
      _orderController.clear();
      _xpRewardController.clear();
      _selectedContentType = 'text';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar lección' : 'Crear lección'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandedTextField(
                    controller: _titleController,
                    label: 'Título de la lección',
                    prefixIcon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El título es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedContentType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de contenido',
                      prefixIcon: Icon(Icons.content_paste_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: _contentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['value'],
                        child: Text(type['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedContentType = value);
                      }
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
                  const SizedBox(height: 16),
                  BrandedTextField(
                    controller: _xpRewardController,
                    label: 'XP por completar',
                    hint: 'Ej: 10, 20, 50...',
                    prefixIcon: Icons.star_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La XP es obligatoria';
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
                final notifier = ref.read(lessonNotifierProvider.notifier);

                final data = {
                  'module_id': _currentModuleId!,
                  'title': _titleController.text.trim(),
                  'content_type': _selectedContentType,
                  'order': int.parse(_orderController.text.trim()),
                  'xp_reward': int.parse(_xpRewardController.text.trim()),
                };

                if (isEditing) {
                  // ✅ ACTUALIZAR LECCIÓN
                  notifier.updateLesson(_editingLesson!.id, data);
                } else {
                  // ✅ CREAR LECCIÓN
                  notifier.addLesson(data);
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
    int lessonId,
    int moduleId,
    LessonNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar lección'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta lección?\n'
          'Esta acción eliminará todos los ejercicios asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteLesson(lessonId, moduleId);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.onEdit,
    required this.onDelete,
  });

  final LessonModel lesson;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _getContentTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Texto';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'quiz':
        return 'Quiz';
      case 'interactive':
        return 'Interactivo';
      default:
        return type;
    }
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'quiz':
        return Colors.orange;
      case 'interactive':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getContentTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'interactive':
        return Icons.touch_app_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentTypeColor = _getContentTypeColor(lesson.contentType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: contentTypeColor.withValues(alpha: 0.3),
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
            color: contentTypeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getContentTypeIcon(lesson.contentType),
            color: contentTypeColor,
          ),
        ),
        title: Text(
          lesson.title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Módulo: ${lesson.moduleTitle}',
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
                    color: contentTypeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getContentTypeLabel(lesson.contentType),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: contentTypeColor,
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
                    'Orden: ${lesson.order}',
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
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'XP: ${lesson.xpReward}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lesson.exercisesCount} ejercicios',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green,
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