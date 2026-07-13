import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/providers/course_providers.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/domain/model/admin/admin_course_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

class CreateLessonScreen extends ConsumerStatefulWidget {
  const CreateLessonScreen({super.key});

  @override
  ConsumerState<CreateLessonScreen> createState() =>
      _CreateLessonScreenState();
}

class _CreateLessonScreenState extends ConsumerState<CreateLessonScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: '1');
  int? _selectedCourseId;
  int? _selectedModuleId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final orderText = _orderCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa el título de la lección')));
      return;
    }
    if (_selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona un módulo')));
      return;
    }
    final order = int.tryParse(orderText) ?? 1;

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'title': title,
        'module': _selectedModuleId,
        'order': order,
      };
      // Solo incluir descripción si no está vacía
      final desc = _descriptionCtrl.text.trim();
      if (desc.isNotEmpty) data['description'] = desc;

      await ref.read(adminCoursesProvider.notifier).addLesson(data);

      ref.invalidate(lessonsByModuleProvider(_selectedModuleId!));
      if (_selectedCourseId != null) {
        ref.invalidate(modulesByCourseProvider(_selectedCourseId!));
        ref.invalidate(modulesForCourseProvider(_selectedCourseId!));
        ref.invalidate(courseDetailProvider(_selectedCourseId!));
      }
      ref.invalidate(coursesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lección creada correctamente')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Crear Lección', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Theme(
          data: ThemeData.dark(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandedTextField(controller: _titleCtrl, label: 'Título de la lección'),
              const SizedBox(height: 20),
              BrandedTextField(controller: _descriptionCtrl, label: 'Descripción (Opcional)', maxLines: 3),
              const SizedBox(height: 20),
              const Text('Curso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<List<Course>>(
                future: ref.read(teacherRepositoryProvider).fetchCourses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Cargando cursos...', style: TextStyle(color: Colors.white70)),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Error al cargar cursos', style: TextStyle(color: Colors.redAccent));
                  }
                  final courses = snapshot.data!;
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF122033),
                    ),
                    value: _selectedCourseId,
                    items: courses.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text('${c.title} (id: ${c.id})', style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCourseId = v;
                        _selectedModuleId = null;
                      });
                    },
                    hint: const Text('Selecciona un curso', style: TextStyle(color: Colors.white70)),
                  );
                },
              ),
              if (_selectedCourseId != null) ...[
                const SizedBox(height: 20),
                const Text('Módulo', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final modulesAsync = ref.watch(modulesForCourseProvider(_selectedCourseId!));
                    return modulesAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Cargando módulos...', style: TextStyle(color: Colors.white70)),
                      ),
                      error: (err, _) => const Text('Error al cargar módulos', style: TextStyle(color: Colors.redAccent)),
                      data: (modules) {
                        if (modules.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('No hay módulos creados para este curso. Por favor, crea un módulo primero.', style: TextStyle(color: Colors.orangeAccent)),
                          );
                        }
                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFF122033),
                          ),
                          value: _selectedModuleId,
                          items: modules.map((m) {
                            final id = m['id'] as int;
                            final title = m['title'] as String;
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text('$title (ID: $id)', style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedModuleId = v),
                          hint: const Text('Selecciona un módulo', style: TextStyle(color: Colors.white70)),
                        );
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 20),
              BrandedTextField(controller: _orderCtrl, label: 'Orden (Ej. 1)', keyboardType: TextInputType.number),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Guardar Lección',
                loading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

