import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';

class CreateLessonScreen extends ConsumerStatefulWidget {
  const CreateLessonScreen({super.key});

  @override
  ConsumerState<CreateLessonScreen> createState() =>
      _CreateLessonScreenState();
}

class _CreateLessonScreenState extends ConsumerState<CreateLessonScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _moduleIdCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: '1');
  final _contentBodyCtrl = TextEditingController();
  final _audioUrlCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();
  final _resourceUrlCtrl = TextEditingController();
  String _contentType = 'text';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _moduleIdCtrl.dispose();
    _orderCtrl.dispose();
    _contentBodyCtrl.dispose();
    _audioUrlCtrl.dispose();
    _videoUrlCtrl.dispose();
    _resourceUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final moduleIdText = _moduleIdCtrl.text.trim();
    final orderText = _orderCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa el título de la lección')));
      return;
    }
    final moduleId = int.tryParse(moduleIdText);
    if (moduleId == null || moduleId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor ingresa un ID de Módulo válido (número entero)')));
      return;
    }
    final order = int.tryParse(orderText) ?? 1;

    setState(() => _isLoading = true);

    try {
      final data = <String, dynamic>{
        'title': title,
        'module': moduleId,
        'order': order,
        'content_type': _contentType,
      };
      final desc = _descriptionCtrl.text.trim();
      if (desc.isNotEmpty) data['description'] = desc;
      final contentBody = _contentBodyCtrl.text.trim();
      if (contentBody.isNotEmpty) data['content_body'] = contentBody;
      final audioUrl = _audioUrlCtrl.text.trim();
      if (audioUrl.isNotEmpty) data['audio_url'] = audioUrl;
      final videoUrl = _videoUrlCtrl.text.trim();
      if (videoUrl.isNotEmpty) data['video_url'] = videoUrl;
      final resourceUrl = _resourceUrlCtrl.text.trim();
      if (resourceUrl.isNotEmpty) data['resource_url'] = resourceUrl;

      await ref.read(adminCoursesProvider.notifier).addLesson(data);

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
              DropdownButtonFormField<String>(
                value: _contentType,
                decoration: const InputDecoration(labelText: 'Tipo de contenido'),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Texto / lectura')),
                  DropdownMenuItem(value: 'video', child: Text('Video')),
                  DropdownMenuItem(value: 'audio', child: Text('Audio')),
                  DropdownMenuItem(value: 'interactive', child: Text('Interactivo')),
                ],
                onChanged: (value) => setState(() => _contentType = value ?? 'text'),
              ),
              const SizedBox(height: 20),
              BrandedTextField(controller: _contentBodyCtrl, label: 'Contenido (texto, instrucciones o resumen)', maxLines: 4),
              const SizedBox(height: 20),
              BrandedTextField(controller: _audioUrlCtrl, label: 'URL de audio (opcional)'),
              const SizedBox(height: 20),
              BrandedTextField(controller: _videoUrlCtrl, label: 'URL de video (opcional)'),
              const SizedBox(height: 20),
              BrandedTextField(controller: _resourceUrlCtrl, label: 'URL de recurso/PDF (opcional)'),
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

