import 'package:flutter/material.dart';

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
        TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre')),
        TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: 'Descripción')),
        TextField(
            controller: courseController,
            decoration: const InputDecoration(labelText: 'ID Curso'),
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const CircularProgressIndicator()
              : const Text('Crear Aula'),
        ),
      ],
    );
  }
}
