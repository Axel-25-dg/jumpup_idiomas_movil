// lib/presentation/screens/admin/modules_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart'; // ✅ Import correcto
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/providers/module_provider.dart';
import 'package:jumpup_app/presentation/providers/courses_provider.dart';
import 'package:jumpup_app/presentation/screens/admin/courses_screen.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ModulesScreen extends ConsumerStatefulWidget {
  final int? initialCourseId;

  const ModulesScreen({super.key, this.initialCourseId});

  @override
  ConsumerState<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends ConsumerState<ModulesScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController();
  final _courseIdController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCourseId;
  int? _currentCourseId;
  ModuleModel? _editingModule;
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moduleNotifierProvider.notifier).fetchAllModules();
    });

    if (widget.initialCourseId != null && widget.initialCourseId! > 0) {
      _currentCourseId = widget.initialCourseId;
      _courseIdController.text = widget.initialCourseId.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(moduleNotifierProvider.notifier).getModulesByCourse(widget.initialCourseId!);
      });
    }
  }

  @override
  void dispose() {
    _blobController.dispose();
    _searchController.dispose();
    _titleController.dispose();
    _orderController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modulesAsync = ref.watch(moduleNotifierProvider);
    final notifier = ref.read(moduleNotifierProvider.notifier);
    final coursesAsync = ref.watch(courseNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Modulos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF00E5FF)),
            onPressed: () => _showAddEditDialog(context, coursesAsync),
            tooltip: 'Agregar modulo',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () {
              if (_currentCourseId != null) {
                notifier.refresh(_currentCourseId!);
              } else {
                notifier.fetchAllModules();
              }
            },
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -60 + (30 * _blobController.value),
                    left: -50 + (25 * _blobController.value),
                    child: _blob(const Color(0xFF7C4DFF), 350, 0.12),
                  ),
                  Positioned(
                    bottom: 100 - (30 * _blobController.value),
                    right: -80 + (20 * _blobController.value),
                    child: _blob(const Color(0xFF00C853), 300, 0.08),
                  ),
                ],
              );
            },
          ),

          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            backgroundColor: const Color(0xFF1E1E2A),
            onRefresh: () async {
              if (_currentCourseId != null) {
                await notifier.refresh(_currentCourseId!);
              } else {
                await notifier.fetchAllModules();
              }
            },
            child: coursesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(20),
                child: _buildErrorView(error, notifier),
              ),
              data: (courses) {
                return modulesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildErrorView(error, notifier),
                  ),
                  data: (modules) {
                    final filtered = modules.where((module) {
                      if (_searchQuery.isEmpty) return true;
                      return module.title.toLowerCase().contains(_searchQuery) ||
                          module.courseTitle.toLowerCase().contains(_searchQuery);
                    }).toList();

                    final finalModules = _currentCourseId != null
                        ? filtered.where((m) => m.course == _currentCourseId).toList()
                        : filtered;

                    if (finalModules.isEmpty) {
                      return EmptyState(
                        title: _searchQuery.isEmpty
                            ? 'No hay modulos creados'
                            : 'No se encontraron modulos',
                        subtitle: _searchQuery.isEmpty
                            ? 'Crea tu primer modulo para comenzar'
                            : 'Intenta con otro termino de busqueda',
                        icon: Icons.view_module_rounded,
                        buttonText: _searchQuery.isEmpty
                            ? 'Crear modulo'
                            : 'Limpiar busqueda',
                        onButtonPressed: _searchQuery.isEmpty
                            ? () => _showAddEditDialog(context, coursesAsync)
                            : () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 60, 20, 100),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: finalModules.length,
                      itemBuilder: (context, index) {
                        final module = finalModules[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ModuleCard(
                            module: module,
                            onEdit: () => _showAddEditDialog(
                              context,
                              coursesAsync,
                              module: module,
                            ),
                            onDelete: () => _confirmDelete(
                              context,
                              module.id,
                              _currentCourseId ?? module.course,
                              notifier,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity + 0.05),
              blurRadius: 100,
              spreadRadius: 20,
            ),
          ],
        ),
      );

  Widget _buildErrorView(Object error, ModuleNotifier notifier) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        blur: 24,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'Error al cargar modulos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error.toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Reintentar',
                onPressed: () {
                  if (_currentCourseId != null) {
                    notifier.refresh(_currentCourseId!);
                  } else {
                    notifier.fetchAllModules();
                  }
                },
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        ),
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
      _selectedCourseId = _currentCourseId;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              isEditing ? 'Editar modulo' : 'Nuevo modulo',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 450,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selector de curso
                      coursesAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
                        ),
                        error: (_, __) => const Text(
                          'Error al cargar cursos',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        data: (courses) {
                          if (courses.isEmpty) {
                            return Column(
                              children: [
                                const Text(
                                  'No hay cursos disponibles. Crea un curso primero.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 12),
                                PrimaryButton(
                                  label: 'Ir a Cursos',
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CoursesScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icons.menu_book_rounded,
                                ),
                              ],
                            );
                          }
                          return DropdownButtonFormField<int>(
                            dropdownColor: const Color(0xFF1E1E2A),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Curso',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.menu_book_rounded,
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
                              'Selecciona un curso',
                              style: TextStyle(color: Colors.white54),
                            ),
                            value: _selectedCourseId,
                            items: courses.map((course) {
                              return DropdownMenuItem(
                                value: course.id,
                                child: Text(
                                  course.title,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              _selectedCourseId = value;
                            },
                            validator: (value) =>
                                value == null ? 'Selecciona un curso' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Titulo
                      BrandedTextField(
                        controller: _titleController,
                        label: 'Titulo del modulo',
                        prefixIcon: Icons.title_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El titulo es obligatorio';
                          }
                          return null;
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
                            return 'Ingresa un numero valido';
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
                  style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PrimaryButton(
                label: isEditing ? 'Actualizar' : 'Guardar',
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedCourseId != null) {
                    final notifier = ref.read(moduleNotifierProvider.notifier);

                    final data = {
                      'course': _selectedCourseId!,
                      'title': _titleController.text.trim(),
                      'order': int.parse(_orderController.text.trim()),
                    };

                    notifier.addModule(data);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    int moduleId,
    int courseId,
    ModuleNotifier notifier,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Eliminar modulo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              '¿Estas seguro de que deseas eliminar este modulo?\n'
              'Esta accion eliminara todas las lecciones asociadas.',
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
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  notifier.deleteModule(moduleId, courseId);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
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
    final accentColor = const Color(0xFF7C4DFF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 20,
        opacity: 0.06,
        borderRadius: BorderRadius.circular(24),
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.2),
                          accentColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.view_module_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Curso: ${module.courseTitle} (ID: ${module.course})',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Orden: ${module.order}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: Colors.white38,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Eliminar',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}