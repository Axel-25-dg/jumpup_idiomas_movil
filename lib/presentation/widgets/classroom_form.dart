import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/course_provider.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';
import 'package:jumpup_app/theme/colors.dart';

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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? 'Editar Detalles del Aula' : 'Detalles de la Nueva Aula',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GlassContainer(
            opacity: 0.1,
            padding: const EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandedTextField(
                  controller: nameController,
                  label: 'Nombre del Aula',
                  hint: 'Ej: English Advanced A1',
                  prefixIcon: Icons.school_rounded,
                ),
                const SizedBox(height: 20),
                BrandedTextField(
                  controller: descController,
                  label: 'Descripción',
                  hint: 'Ej: Grupo de la mañana - Lunes y Miércoles',
                  prefixIcon: Icons.description,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                
                // ── Dropdown de Cursos ─────────────────────────────────────────
                coursesAsync.when(
                  loading: () => const LinearProgressIndicator(color: AppColors.secondary),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error al cargar cursos: $err', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                  data: (courses) {
                    return DropdownButtonFormField<int>(
                      value: selectedCourseId,
                      dropdownColor: const Color(0xFF1A1828),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Curso Relacionado',
                        prefixIcon: Icon(Icons.book_rounded),
                      ),
                      hint: const Text("Selecciona un curso", style: TextStyle(color: Colors.white54)),
                      items: courses.map((c) => DropdownMenuItem<int>(
                        value: c.id,
                        key: ValueKey('course_${c.id}'),
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
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: isEdit ? 'Actualizar Aula' : 'Crear Aula',
              loading: loading,
              onPressed: onSubmit,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
