import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el título y el ID del Módulo'),
          backgroundColor: Colors.redAccent,
        )
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lección creada correctamente'),
            backgroundColor: Colors.greenAccent,
          )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent)
        );
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
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Crear Lección', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4DB).withValues(alpha: 0.05),
                boxShadow: [BoxShadow(color: const Color(0xFF00B4DB).withValues(alpha: 0.05), blurRadius: 100)],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  opacity: 0.05,
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.play_circle_fill_rounded, color: Color(0xFF00B4DB), size: 20),
                          SizedBox(width: 8),
                          Text('Detalles de la Lección', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      BrandedTextField(
                        controller: _titleCtrl, 
                        label: 'Título de la lección',
                        hint: 'Ej: Presente Simple - Verbo To Be',
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: _descriptionCtrl, 
                        label: 'Contenido / Descripción', 
                        maxLines: 5,
                        hint: 'Escribe aquí el contenido principal de la lección...',
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: BrandedTextField(
                              controller: _moduleIdCtrl, 
                              label: 'ID del Módulo', 
                              keyboardType: TextInputType.number,
                              hint: '123',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BrandedTextField(
                              controller: _orderCtrl, 
                              label: 'Orden', 
                              keyboardType: TextInputType.number,
                              hint: '1',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Publicar Lección',
                  loading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
