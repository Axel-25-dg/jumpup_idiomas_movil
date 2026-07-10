import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/providers/enrollment_provider.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ManageClassroomScreen extends ConsumerStatefulWidget {
  final int classroomId;
  const ManageClassroomScreen({super.key, required this.classroomId});

  @override
  ConsumerState<ManageClassroomScreen> createState() =>
      _ManageClassroomScreenState();
}

class _ManageClassroomScreenState extends ConsumerState<ManageClassroomScreen> {
  Future<void> _removeStudent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Eliminar Estudiante', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que deseas retirar a este estudiante del aula?', 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(enrollmentNotifierProvider.notifier).removeStudent(id);
      if (!mounted) return;
      ref.invalidate(enrollmentsProvider(widget.classroomId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudiante eliminado con éxito'), backgroundColor: Colors.greenAccent)
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.redAccent)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollments = ref.watch(enrollmentsProvider(widget.classroomId));
    final actionState = ref.watch(enrollmentNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Administrar Aula', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text('Lista de Estudiantes Inscritos', 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: enrollments.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
                  data: (students) {
                    if (students.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            const Text('No hay estudiantes en esta aula', style: TextStyle(color: Colors.white30)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return GlassContainer(
                          opacity: 0.05,
                          padding: const EdgeInsets.all(12),
                          borderRadius: BorderRadius.circular(16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                              child: Text(student.studentUsername[0].toUpperCase(), 
                                style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                            ),
                            title: Text(student.studentUsername, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(student.studentEmail, 
                              style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            trailing: actionState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 22),
                                    onPressed: () => _removeStudent(student.id),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
