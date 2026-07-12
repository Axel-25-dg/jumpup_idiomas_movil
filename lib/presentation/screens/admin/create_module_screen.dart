import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/colors.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un título y selecciona un curso'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Módulo creado correctamente'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Crear Nuevo Módulo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detalles del Módulo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Curso asociado',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      coursesAsync.when(
                        loading: () => const LinearProgressIndicator(
                            color: AppColors.secondary),
                        error: (e, _) => Text('Error al cargar cursos: $e',
                            style: const TextStyle(color: Colors.redAccent)),
                        data: (courses) {
                          return DropdownButtonFormField<int>(
                            dropdownColor: const Color(0xFF1A1828),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Seleccionar curso',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.book_rounded,
                                  color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.secondary),
                              ),
                            ),
                            initialValue: _selectedCourseId,
                            hint: const Text('Seleccionar curso...',
                                style: TextStyle(color: Colors.white54)),
                            items: courses
                                .map((c) => DropdownMenuItem(
                                    value: c.id, child: Text(c.title)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCourseId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      BrandedTextField(
                        controller: _titleCtrl,
                        label: 'Título del módulo',
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: _descriptionCtrl,
                        label: 'Descripción (Opcional)',
                        prefixIcon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: _orderCtrl,
                        label: 'Orden (Ej. 1)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.sort,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Guardar Módulo',
                    loading: _isLoading,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


