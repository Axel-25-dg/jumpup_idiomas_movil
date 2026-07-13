// lib/presentation/screens/admin/lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/lesson_provider.dart';
import 'package:jumpup_app/presentation/providers/module_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/theme/app_theme.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController();
  final _xpRewardController = TextEditingController();
  String _searchQuery = '';
  String _selectedContentType = 'text';
  LessonModel? _editingLesson;
  int? _selectedModuleId;

  final List<Map<String, String>> _contentTypes = [
    {'value': 'text', 'label': 'Texto'},
    {'value': 'video', 'label': 'Video'},
    {'value': 'audio', 'label': 'Audio'},
    {'value': 'interactive', 'label': 'Interactivo'},
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
    _orderController.dispose();
    _xpRewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonNotifierProvider);
    final notifier = ref.read(lessonNotifierProvider.notifier);
    final modulesAsync = ref.watch(moduleNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        title: const Text(
          'Gestión de Lecciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => _showAddEditDialog(context, modulesAsync),
            tooltip: 'Crear lección',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
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
              label: 'Buscar lección',
              hint: 'ID de módulo o nombre de la lección...',
              prefixIcon: Icons.search_rounded,
            ),
          ),

          // Lista de lecciones
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              color: const Color(0xFF7C4DFF),
              backgroundColor: const Color(0xFF1E1E2A),
              child: lessonsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                ),
                error: (error, stack) => _buildErrorView(error, notifier),
                data: (lessons) {
                  // Filtrar por ID de módulo o nombre
                  final filtered = lessons.where((lesson) {
                    if (_searchQuery.isEmpty) return true;
                    return lesson.module.toString().contains(_searchQuery) ||
                        lesson.title.toLowerCase().contains(_searchQuery) ||
                        lesson.moduleTitle.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyState(
                      title: _searchQuery.isEmpty
                          ? 'No hay lecciones creadas'
                          : 'No se encontraron lecciones',
                      subtitle: _searchQuery.isEmpty
                          ? 'Crea tu primera lección para comenzar'
                          : 'Intenta con otro término de búsqueda',
                      icon: Icons.menu_book_rounded,
                      buttonText: _searchQuery.isEmpty ? 'Crear lección' : 'Limpiar búsqueda',
                      onButtonPressed: _searchQuery.isEmpty
                          ? () => _showAddEditDialog(context, modulesAsync)
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
                      final lesson = filtered[index];
                      return _LessonCard(
                        lesson: lesson,
                        onEdit: () => _showAddEditDialog(
                          context,
                          modulesAsync,
                          lesson: lesson,
                        ),
                        onDelete: () => _confirmDelete(
                          context,
                          lesson.id,
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
    );
  }

  Widget _buildErrorView(Object error, LessonNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF5252)),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar lecciones',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
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
    AsyncValue<List<ModuleModel>> modulesAsync, {
    LessonModel? lesson,
  }) {
    _editingLesson = lesson;
    final isEditing = lesson != null;

    if (isEditing) {
      _titleController.text = lesson.title;
      _orderController.text = lesson.order.toString();
      _xpRewardController.text = lesson.xpReward.toString();
      _selectedContentType = lesson.contentType;
      _selectedModuleId = lesson.module;
    } else {
      _titleController.clear();
      _orderController.clear();
      _xpRewardController.clear();
      _selectedContentType = 'text';
      _selectedModuleId = null;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        int? localModuleId = _selectedModuleId;
        String? localContentType = _selectedContentType;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2A),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                isEditing ? 'Editar lección' : 'Crear lección',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Selector de módulo
                        modulesAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                          ),
                          error: (_, __) => const Text(
                            'Error al cargar módulos',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          data: (modules) {
                            if (modules.isEmpty) {
                              return const Text(
                                'No hay módulos disponibles. Crea un módulo primero.',
                                style: TextStyle(color: Colors.white70),
                              );
                            }
                            return DropdownButtonFormField<int>(
                              dropdownColor: const Color(0xFF1E1E2A),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Módulo',
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(
                                  Icons.view_module_rounded,
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              hint: const Text(
                                'Selecciona un módulo',
                                style: TextStyle(color: Colors.white54),
                              ),
                              value: localModuleId,
                              items: modules.map((module) {
                                return DropdownMenuItem(
                                  value: module.id,
                                  child: Text(
                                    '${module.title} (ID: ${module.id})',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                localModuleId = value;
                                setDialogState(() {});
                              },
                              validator: (value) =>
                                  value == null ? 'Selecciona un módulo' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Título
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

                        // Tipo de contenido
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1E1E2A),
                          style: const TextStyle(color: Colors.white),
                          value: localContentType,
                          decoration: InputDecoration(
                            labelText: 'Tipo de contenido',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.content_paste_rounded,
                              color: Colors.white54,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: _contentTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'],
                              child: Text(
                                type['label']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              localContentType = value;
                              setDialogState(() {});
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Orden
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

                        // XP Reward
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
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
                PrimaryButton(
                  label: isEditing ? 'Actualizar' : 'Guardar',
                  onPressed: () {
                    if (_formKey.currentState!.validate() && localModuleId != null) {
                      final notifier = ref.read(lessonNotifierProvider.notifier);

                      final data = {
                        'module': localModuleId!,
                        'title': _titleController.text.trim(),
                        'content_type': localContentType!,
                        'order': int.parse(_orderController.text.trim()),
                        'xp_reward': int.parse(_xpRewardController.text.trim()),
                      };

                      if (isEditing) {
                        notifier.updateLesson(_editingLesson!.id, data);
                      } else {
                        notifier.addLesson(data);
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

  void _confirmDelete(BuildContext context, int lessonId, LessonNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar lección',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta lección?\n'
          'Esta acción eliminará todos los ejercicios asociados.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          PrimaryButton(
            label: 'Eliminar',
            onPressed: () {
              notifier.deleteLesson(lessonId);
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
        return const Color(0xFF00E5FF);
      case 'video':
        return const Color(0xFFFF5252);
      case 'audio':
        return const Color(0xFF7C4DFF);
      case 'quiz':
        return const Color(0xFFFFAB40);
      case 'interactive':
        return const Color(0xFF00C853);
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                size: 24,
              ),
            ),
            title: Text(
              lesson.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Módulo: ${lesson.moduleTitle} (ID: ${lesson.module})',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildBadge(
                      text: _getContentTypeLabel(lesson.contentType),
                      color: contentTypeColor,
                    ),
                    _buildBadge(
                      text: 'Orden: ${lesson.order}',
                      color: Colors.blue,
                    ),
                    _buildBadge(
                      text: 'XP: ${lesson.xpReward}',
                      color: Colors.amber,
                    ),
                    _buildBadge(
                      text: '${lesson.exercisesCount} ejercicios',
                      color: Colors.green,
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
                  color: Colors.white38,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: onDelete,
                  color: Colors.redAccent.withValues(alpha: 0.7),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}