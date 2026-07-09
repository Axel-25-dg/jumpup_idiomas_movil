import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jumpup_app/presentation/providers/enrollment_provider.dart';

class ManageClassroomScreen extends ConsumerStatefulWidget {
  final int classroomId;
  const ManageClassroomScreen({super.key, required this.classroomId});

  @override
  ConsumerState<ManageClassroomScreen> createState() => _ManageClassroomScreenState();
}

class _ManageClassroomScreenState extends ConsumerState<ManageClassroomScreen> {

  Future<void> _removeStudent(int id) async {
    try {
      await ref.read(enrollmentNotifierProvider.notifier).removeStudent(id);
      if (!mounted) return;
      ref.invalidate(enrollmentsProvider(widget.classroomId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollments = ref.watch(enrollmentsProvider(widget.classroomId));
    final actionState = ref.watch(enrollmentNotifierProvider);

    ref.listen(enrollmentNotifierProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Aula')),
      body: enrollments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (students) => ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              title: Text(student.studentUsername),
              subtitle: Text(student.studentEmail),
              trailing: actionState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeStudent(student.id),
                    ),
            );
          },
        ),
      ),
    );
  }
}