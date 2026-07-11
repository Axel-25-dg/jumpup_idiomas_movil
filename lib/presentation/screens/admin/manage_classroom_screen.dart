import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jumpup_app/presentation/navigation/app_router.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
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
  String _searchQuery = '';

  Future<void> _removeStudent(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Estudiante', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas retirar a este estudiante del aula?', 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
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
      ref.invalidate(classroomsListProvider);
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

  Future<void> _deleteClassroom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Aula', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro de que deseas eliminar permanentemente esta aula virtual? Los estudiantes inscritos perderán el acceso.', 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(classroomNotifierProvider.notifier).delete(widget.classroomId);
      if (!mounted) return;
      ref.invalidate(classroomsListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aula eliminada con éxito'), backgroundColor: Colors.greenAccent)
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el aula: $e'), backgroundColor: Colors.redAccent)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classroomsAsync = ref.watch(classroomsListProvider);
    final classroom = classroomsAsync.valueOrNull?.firstWhere(
      (c) => c.id == widget.classroomId,
      orElse: () => null as dynamic,
    );

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
        actions: [
          if (classroom != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white70),
              tooltip: 'Editar Aula',
              onPressed: () => context.push(AppRoutes.teacherCreateClassroom, extra: classroom),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              tooltip: 'Eliminar Aula',
              onPressed: _deleteClassroom,
            ),
          ]
        ],
      ),
      body: Stack(
        children: [
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
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B4DB).withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (classroom != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: GlassContainer(
                    opacity: 0.08,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                classroom.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: classroom.isActive
                                    ? const Color(0xFF00E676).withValues(alpha: 0.15)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: classroom.isActive ? const Color(0xFF00E676).withValues(alpha: 0.3) : Colors.white10,
                                ),
                              ),
                              child: Text(
                                classroom.isActive ? 'Activa' : 'Inactiva',
                                style: TextStyle(
                                  color: classroom.isActive ? const Color(0xFF00E676) : Colors.white38,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (classroom.description.isNotEmpty)
                          Text(
                            classroom.description,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Código de acceso: ',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                classroom.accessCode,
                                style: const TextStyle(
                                  color: Color(0xFFB388FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 18),
                              tooltip: 'Copiar código',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: classroom.accessCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Código de acceso copiado al portapapeles'),
                                    backgroundColor: Color(0xFF7C4DFF),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                      hintText: 'Buscar estudiantes por nombre o correo...',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text('Lista de Estudiantes Inscritos', 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: enrollments.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
                  data: (students) {
                    final filteredStudents = students.where((student) {
                      return student.studentUsername.toLowerCase().contains(_searchQuery) ||
                             student.studentEmail.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredStudents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            Text(
                              students.isEmpty ? 'No hay estudiantes en esta aula' : 'No se encontraron estudiantes',
                              style: const TextStyle(color: Colors.white30),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredStudents.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
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
