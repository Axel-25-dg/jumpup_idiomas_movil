import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/colors.dart';

class CreateCourseScreen extends ConsumerStatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  ConsumerState<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends ConsumerState<CreateCourseScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _selectedLanguageId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(adminLanguagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        title: const Text('Crear Nuevo Curso', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
              boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.1), blurRadius: 100)],
            ),
          )),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Información del Curso",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassContainer(
                    opacity: 0.1,
                    child: Column(
                      children: [
                        BrandedTextField(
                          controller: _titleCtrl,
                          label: 'Título del Curso',
                          hint: 'Ej: Inglés Técnico para Negocios',
                          prefixIcon: Icons.title,
                        ),
                        const SizedBox(height: 20),
                        BrandedTextField(
                          controller: _descCtrl,
                          label: 'Descripción',
                          hint: 'Breve resumen del contenido...',
                          prefixIcon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        languagesAsync.when(
                          data: (langs) => DropdownButtonFormField<int>(
                            initialValue: _selectedLanguageId,
                            dropdownColor: const Color(0xFF1A1828),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Idioma',
                              prefixIcon: Icon(Icons.language),
                            ),
                            hint: const Text("Selecciona Idioma", style: TextStyle(color: Colors.white54)),
                            items: langs
                                .map((l) => DropdownMenuItem(
                                      value: l.id,
                                      child: Text(l.name),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedLanguageId = val),
                          ),
                          loading: () => const LinearProgressIndicator(color: AppColors.secondary),
                          error: (_, __) => const Text("Error cargando idiomas", style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      loading: _isSaving,
                      label: 'Guardar Curso',
                      onPressed: (_selectedLanguageId == null || _titleCtrl.text.isEmpty)
                          ? null
                          : () async {
                              setState(() => _isSaving = true);
                              try {
                                await ref.read(adminCoursesProvider.notifier).addCourse({
                                  'title': _titleCtrl.text,
                                  'description': _descCtrl.text,
                                  'language': _selectedLanguageId,
                                  'difficulty_level': 'A1',
                                });
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                setState(() => _isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
