import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/courses_provider.dart';
import 'package:jumpup_app/presentation/providers/language_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/empty_state.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  int? _selectedLanguageId;
  String? _selectedDifficulty;
  String? _selectedImagePath;
  late AnimationController _blobController;

  Future<void> _pickCourseImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
          _imageUrlController.text = 'imagen-galeria';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  final List<Map<String, String>> _difficultyLevels = [
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
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blobController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(courseNotifierProvider);
    final notifier = ref.read(courseNotifierProvider.notifier);
    final languagesAsync = ref.watch(languageNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cursos',
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
            onPressed: () => _showAddEditDialog(context, languagesAsync),
            tooltip: 'Agregar curso',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Blobs Animated
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
            onRefresh: () => notifier.refresh(),
            child: coursesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C4DFF)),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(20),
                child: _buildErrorView(error, notifier),
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return EmptyState(
                    title: 'No hay cursos creados',
                    subtitle: 'Crea tu primer curso para comenzar',
                    icon: Icons.menu_book_rounded,
                    buttonText: 'Crear curso',
                    onButtonPressed: () =>
                        _showAddEditDialog(context, languagesAsync),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    kToolbarHeight + 60,
                    20,
                    100,
                  ),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return _CourseCard(
                      course: course,
                      onEdit: () => _showAddEditDialog(
                        context,
                        languagesAsync,
                        course: course,
                      ),
                      onDelete: () =>
                          _confirmDelete(context, course.id, notifier),
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

  Widget _buildErrorView(Object error, CourseNotifier notifier) {
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
              'Error al cargar cursos',
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
                onPressed: () => notifier.refresh(),
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
    AsyncValue<List<Language>> languagesAsync, {
    Course? course,
  }) {
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _imageUrlController.text = course.imageUrl;
      _selectedLanguageId = course.languageId;
      _selectedDifficulty = course.difficultyLevel;
      _selectedImagePath = null;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _selectedLanguageId = null;
      _selectedDifficulty = null;
      _selectedImagePath = null;
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
              course != null ? 'Editar curso' : 'Nuevo curso',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: StatefulBuilder(
              builder: (ctx, dialogSetState) {
                return SizedBox(
                  width: 450,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Idioma
                          languagesAsync.when(
                            loading: () => const CircularProgressIndicator(
                              color: Color(0xFF7C4DFF),
                            ),
                            error: (_, __) => const Text(
                              'Error al cargar idiomas',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            data: (languages) => DropdownButtonFormField<int>(
                              dropdownColor: const Color(0xFF1E1E2A),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Idioma',
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(
                                  Icons.language_rounded,
                                  color: Colors.white54,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              value: _selectedLanguageId,
                              items: languages.map((lang) {
                                return DropdownMenuItem(
                                  value: lang.id,
                                  child: Text(lang.name),
                                );
                              }).toList(),
                              onChanged: (value) => _selectedLanguageId = value,
                              validator: (value) =>
                                  value == null ? 'Selecciona un idioma' : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Título
                          BrandedTextField(
                            controller: _titleController,
                            label: 'Título del curso',
                            prefixIcon: Icons.title_rounded,
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                    ? 'El título es obligatorio'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          // Descripción
                          BrandedTextField(
                            controller: _descriptionController,
                            label: 'Descripción',
                            prefixIcon: Icons.description_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Dificultad A1-C2
                          DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF1E1E2A),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nivel de dificultad',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.signal_cellular_alt_rounded,
                                color: Colors.white54,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            value: _selectedDifficulty,
                            items: _difficultyLevels.map((level) {
                              return DropdownMenuItem(
                                value: level['value'],
                                child: Text(level['label']!),
                              );
                            }).toList(),
                            onChanged: (value) => _selectedDifficulty = value,
                          ),
                          const SizedBox(height: 16),

                          // Selector de imagen de la galería
                          const Text('Imagen del curso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              try {
                                final ImagePicker picker = ImagePicker();
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  dialogSetState(() {
                                    _selectedImagePath = image.path;
                                    _imageUrlController.text = 'imagen-galeria';
                                  });
                                  setState(() {}); // outer rebuild
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al seleccionar imagen: $e')),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: _selectedImagePath != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            'file://$_selectedImagePath',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  _selectedImagePath!.split('/').last,
                                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 14,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                              onPressed: () {
                                                dialogSetState(() {
                                                  _selectedImagePath = null;
                                                  _imageUrlController.clear();
                                                });
                                                setState(() {}); // outer rebuild
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : (course != null && course.imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            course.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF00E5FF), size: 32),
                                              SizedBox(height: 4),
                                              Text('Seleccionar de galería', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                            ],
                                          ),
                                        )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                label: course != null ? 'Actualizar' : 'Guardar',
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedLanguageId != null) {
                    final notifier = ref.read(
                      courseNotifierProvider.notifier,
                    );
                    final data = {
                      'language': _selectedLanguageId!,
                      'title': _titleController.text.trim(),
                      'description': _descriptionController.text.trim(),
                      'difficulty_level': _selectedDifficulty ?? 'A1',
                      'image_url': _imageUrlController.text.trim(),
                      'image_path': _selectedImagePath,
                    };
                    if (course != null) {
                      notifier.editCourse(course.id, data);
                    } else {
                      notifier.addCourse(data);
                    }
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

  void _confirmDelete(BuildContext context, int id, CourseNotifier notifier) {
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
              'Eliminar curso',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este curso?\n'
              'Esta acción eliminará todos los módulos y lecciones asociadas.',
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
                  notifier.deleteCourse(id);
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

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _getDifficultyLabel(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return 'Principiante A1';
      case 'A2':
        return 'Elemental A2';
      case 'B1':
        return 'Intermedio B1';
      case 'B2':
        return 'Intermedio Alto B2';
      case 'C1':
        return 'Avanzado C1';
      case 'C2':
        return 'Maestría C2';
      default:
        return level;
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return Colors.greenAccent;
      case 'A2':
        return Colors.lightGreenAccent;
      case 'B1':
        return Colors.orangeAccent;
      case 'B2':
        return Colors.deepOrangeAccent;
      case 'C1':
        return Colors.redAccent;
      case 'C2':
        return Colors.deepPurpleAccent;
      default:
        return Colors.grey;
    }
  }

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
                  // Leading
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
                    child: course.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              course.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.menu_book_rounded,
                                color: accentColor,
                                size: 28,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.menu_book_rounded,
                            color: accentColor,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Idioma: ${course.languageName}',
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
                            color: _getDifficultyColor(course.difficultyLevel)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getDifficultyLabel(course.difficultyLevel)
                                .toUpperCase(),
                            style: TextStyle(
                              color: _getDifficultyColor(
                                course.difficultyLevel,
                              ),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Trailing buttons
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