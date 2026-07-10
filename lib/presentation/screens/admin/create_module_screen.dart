import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class CreateModuleScreen extends ConsumerStatefulWidget {
  const CreateModuleScreen({super.key});

  @override
  ConsumerState<CreateModuleScreen> createState() => _CreateModuleScreenState();
}

class _CreateModuleScreenState extends ConsumerState<CreateModuleScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: "1");
  String? _selectedCourseId;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un título y selecciona un curso'),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(adminCoursesProvider.notifier).addModule({
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'order': int.tryParse(_orderCtrl.text.trim()) ?? 1,
        'course': int.parse(_selectedCourseId!),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Módulo creado correctamente'),
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
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Crear Módulo', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
                boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.05), blurRadius: 80)],
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
                          Icon(Icons.library_books_rounded, color: Color(0xFF7C4DFF), size: 20),
                          SizedBox(width: 8),
                          Text('Configuración Básica', 
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Curso asociado', 
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      coursesAsync.when(
                        loading: () => const LinearProgressIndicator(color: Color(0xFF7C4DFF), backgroundColor: Colors.white10),
                        error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
                        data: (courses) {
                          return DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF1A1828),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16), 
                                borderSide: BorderSide.none
                              ),
                            ),
                            initialValue: _selectedCourseId,
                            hint: const Text('Seleccionar curso...', style: TextStyle(color: Colors.white54)),
                            items: courses.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.title))).toList(),
                            onChanged: (val) => setState(() => _selectedCourseId = val),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: _titleCtrl, 
                        label: 'Título del módulo',
                        hint: 'Ej: Gramática Básica I',
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: _descriptionCtrl, 
                        label: 'Descripción (Opcional)', 
                        maxLines: 3,
                        hint: 'Breve resumen de lo que se aprenderá...',
                      ),
                      const SizedBox(height: 20),
                      BrandedTextField(
                        controller: _orderCtrl, 
                        label: 'Orden de aparición', 
                        keyboardType: TextInputType.number,
                        hint: '1',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Guardar Módulo',
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
