import 'package:flutter/material.dart';
import 'package:jumpup_app/presentation/widgets/branded_text_field.dart';
import 'package:jumpup_app/presentation/widgets/primary_button.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ClassroomForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController courseController;
  final bool loading;
  final VoidCallback onSubmit;

  const ClassroomForm({
    super.key,
    required this.nameController,
    required this.descController,
    required this.courseController,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  Icon(Icons.school_rounded, color: Color(0xFF7C4DFF), size: 20),
                  SizedBox(width: 8),
                  Text('Información del Aula', 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              BrandedTextField(
                controller: courseController,
                label: 'ID del Curso',
                hint: '12',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          label: 'Crear Aula Premium',
          loading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
