import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';

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
      appBar: AppBar(title: const Text('Nuevo Curso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título')),
            TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 16),
            languagesAsync.when(
              data: (langs) => DropdownButtonFormField<int>(
                hint: const Text("Selecciona Idioma"),
                items: langs
                    .map((l) =>
                        DropdownMenuItem(value: l.id, child: Text(l.name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedLanguageId = val),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text("Error cargando idiomas"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_isSaving ||
                      _selectedLanguageId == null ||
                      _titleCtrl.text.isEmpty)
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
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar Curso'),
            )
          ],
        ),
      ),
    );
  }
}
