import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jumpup_app/presentation/providers/language_provider.dart';
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
  String? _selectedImagePath;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
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

  @override
  Widget build(BuildContext context) {
    final languagesAsync = ref.watch(adminLanguagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        title: const Text('Nuevo Curso', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Título',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              languagesAsync.when(
                data: (langs) => DropdownButtonFormField<int>(
                  dropdownColor: const Color(0xFF1E1E2A),
                  style: const TextStyle(color: Colors.white),
                  hint: const Text("Selecciona Idioma", style: TextStyle(color: Colors.white70)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: langs
                      .map((l) =>
                          DropdownMenuItem(value: l.id, child: Text(l.name)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLanguageId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text("Error cargando idiomas", style: TextStyle(color: Colors.redAccent)),
              ),
              const SizedBox(height: 24),
              
              // Selector de Imagen de Galería
              const Text('Imagen del curso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, style: BorderStyle.solid),
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        _selectedImagePath!.split('/').last,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                                  onPressed: () => setState(() => _selectedImagePath = null),
                                ),
                              ),
                            )
                          ],
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF00E5FF), size: 40),
                              SizedBox(height: 8),
                              Text('Seleccionar de galería', style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (_isSaving ||
                        _selectedLanguageId == null ||
                        _titleCtrl.text.isEmpty ||
                        _selectedImagePath == null)
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        try {
                          final payload = {
                            'title': _titleCtrl.text,
                            'description': _descCtrl.text,
                            'language_id': _selectedLanguageId,
                            'difficulty_level': 'A1',
                            'image_url': 'imagen-galeria',
                            'image_path': _selectedImagePath,
                          };
                          await ref.read(adminCoursesProvider.notifier).addCourse(payload);
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar Curso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}