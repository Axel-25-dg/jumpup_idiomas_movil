import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

class CreateModuleScreen extends ConsumerStatefulWidget {
  const CreateModuleScreen({super.key});

  @override
  ConsumerState<CreateModuleScreen> createState() =>
      _CreateModuleScreenState();
}

class _CreateModuleScreenState extends ConsumerState<CreateModuleScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: '1');
  int? _selectedCourseId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa un título y selecciona un curso')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(adminCoursesProvider.notifier).addModule({
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'order': int.tryParse(_orderCtrl.text.trim()) ?? 1,
        'course': _selectedCourseId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Módulo creado correctamente')));
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
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Crear Módulo', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Curso asociado', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            coursesAsync.when(
              loading: () => const CircularProgressIndicator(color: Color(0xFF7C4DFF)),
              error: (e, _) => Text('Error al cargar cursos: $e', style: const TextStyle(color: Colors.redAccent)),
              data: (courses) {
                return DropdownButtonFormField<int>(
                  dropdownColor: const Color(0xFF1A1828),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  value: _selectedCourseId,
                  hint: const Text('Seleccionar curso...', style: TextStyle(color: Colors.white54)),
                  items: courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                );
              },
            ),
            const SizedBox(height: 24),
            Theme(
              data: ThemeData.dark(),
              child: Column(
                children: [
                  BrandedTextField(controller: _titleCtrl, label: 'Título del módulo'),
                  const SizedBox(height: 20),
                  BrandedTextField(controller: _descriptionCtrl, label: 'Descripción (Opcional)', maxLines: 3),
                  const SizedBox(height: 20),
                  BrandedTextField(controller: _orderCtrl, label: 'Orden (Ej. 1)', keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Guardar Módulo',
              loading: _isLoading,
              onPressed: _submit,
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
