import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';

// Provider para cargar módulos de un curso
final modulesForCourseProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>(
        (ref, courseId) async {
  // Llamamos directamente al repo para listar módulos del curso
  final repo = ref.read(teacherRepositoryProvider);
  try {
    final res = await repo.fetchModulesForCourse(courseId);
    return res;
  } catch (_) {
    return [];
  }
});

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
    if (_titleCtrl.text.trim().isEmpty || _selectedModuleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ingresa un título y selecciona un módulo')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(coursesProvider.notifier).addLesson({
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'order': int.tryParse(_orderCtrl.text.trim()) ?? 1,
        'module': _selectedModuleId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lección creada correctamente')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva Lección'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paso 1: Seleccionar Curso
            _Label('1. Selecciona el Curso'),
            const SizedBox(height: 8),
            coursesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Text('Error: $e',
                  style: const TextStyle(color: AppColors.error)),
              data: (courses) => DropdownButtonFormField<int>(
                value: _selectedCourseId,
                decoration: _dropdownDecoration(),
                hint: const Text('Seleccionar curso...',
                    style: TextStyle(color: AppColors.textSecondary)),
                items: courses
                    .map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.title,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedCourseId = val;
                  _selectedModuleId = null;
                }),
              ),
            ),

            if (_selectedCourseId != null) ...[
              const SizedBox(height: 20),
              // Paso 2: Seleccionar Módulo
              _Label('2. Selecciona el Módulo'),
              const SizedBox(height: 8),
              ref.watch(modulesForCourseProvider(_selectedCourseId!)).when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                    error: (e, _) => Text('Error cargando módulos',
                        style: const TextStyle(color: AppColors.error)),
                    data: (modules) {
                      if (modules.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'No hay módulos en este curso. Crea un módulo primero.',
                            style: TextStyle(color: AppColors.warning),
                          ),
                        );
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedModuleId,
                        decoration: _dropdownDecoration(),
                        hint: const Text('Seleccionar módulo...',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                        items: modules
                            .map((m) => DropdownMenuItem<int>(
                                  value: m['id'] as int,
                                  child: Text(m['title'] as String,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedModuleId = val),
                      );
                    },
                  ),
            ],
            const SizedBox(height: 20),

            _Label('Título de la lección'),
            const SizedBox(height: 8),
            _InputField(
                controller: _titleCtrl,
                hint: 'Ej. Lección 1: Presentaciones'),
            const SizedBox(height: 20),
            _Label('Descripción (opcional)'),
            const SizedBox(height: 8),
            _InputField(
                controller: _descriptionCtrl,
                hint: 'Describe esta lección...',
                maxLines: 3),
            const SizedBox(height: 20),
            _Label('Orden'),
            const SizedBox(height: 8),
            _InputField(
                controller: _orderCtrl,
                hint: '1',
                keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar Lección',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _dropdownDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2)),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
