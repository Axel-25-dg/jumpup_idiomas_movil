import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ClassroomForm extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final int? selectedCourseId;
  final ValueChanged<int?> onCourseChanged;
  final bool loading;
  final VoidCallback onSubmit;
  final bool isEdit;

  const ClassroomForm({
    super.key,
    required this.nameController,
    required this.descController,
    required this.selectedCourseId,
    required this.onCourseChanged,
    required this.loading,
    required this.onSubmit,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Column(
      children: [
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school_rounded, color: Color(0xFF7C4DFF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Editar Información del Aula' : 'Información del Aula', 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BrandedTextField(
                controller: nameController,
                label: 'Nombre del Aula',
                hint: 'Ej: English Advanced A1',
              ),
              const SizedBox(height: 20),
              BrandedTextField(
                controller: descController,
                label: 'Descripción',
                hint: 'Ej: Grupo de la mañana - Lunes y Miércoles',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              // ── Dropdown de Cursos ─────────────────────────────────────────
              coursesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(color: Color(0xFF7C4DFF), strokeWidth: 2),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error al cargar cursos: $err', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ),
                data: (courses) {
                  return DropdownButtonFormField<int>(
                    initialValue: selectedCourseId,
                    dropdownColor: const Color(0xFF1E1E2A),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Curso Relacionado',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    items: courses.map((c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.title, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: onCourseChanged,
                    validator: (val) => val == null ? 'Por favor selecciona un curso' : null,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          label: isEdit ? 'Actualizar Aula Premium' : 'Crear Aula Premium',
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
