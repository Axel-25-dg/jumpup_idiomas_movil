import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

class CreateLessonScreen extends ConsumerStatefulWidget {
  const CreateLessonScreen({super.key});

  @override
  ConsumerState<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends ConsumerState<CreateLessonScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _moduleIdCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: "1");
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _moduleIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa el título y el ID del Módulo')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(adminCoursesProvider.notifier).addLesson({
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'order': int.tryParse(_orderCtrl.text.trim()) ?? 1,
        'module': int.parse(_moduleIdCtrl.text.trim()),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lección creada correctamente')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              BrandedTextField(controller: _moduleIdCtrl, label: 'ID del Módulo', keyboardType: TextInputType.number),
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
