import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_providers.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(teacherDashboardSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A), // Fondo oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text(
          'Portal del Profesor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF)),
                onPressed: () => ref.invalidate(teacherDashboardSummaryProvider),
                child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          color: const Color(0xFF7C4DFF),
          backgroundColor: const Color(0xFF1A1828),
          onRefresh: () async => ref.invalidate(teacherDashboardSummaryProvider),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Resumen de tu actividad',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _StatCard(
                    title: 'Alumnos',
                    value: data.students.toString(),
                    icon: Icons.people_outline,
                    color: const Color(0xFF4CAF50),
                  ),
                  _StatCard(
                    title: 'Clases Activas',
                    value: data.classrooms.toString(),
                    icon: Icons.class_outlined,
                    color: const Color(0xFF2196F3),
                  ),
                  _StatCard(
                    title: 'Lecciones',
                    value: data.lessons.toString(),
                    icon: Icons.menu_book_outlined,
                    color: const Color(0xFFFF9800),
                  ),
                  _StatCard(
                    title: 'Certificados',
                    value: data.certificates.toString(),
                    icon: Icons.workspace_premium_outlined,
                    color: const Color(0xFFE91E63),
                  ),
                  _StatCard(
                    title: 'Recursos',
                    value: data.resources.toString(),
                    icon: Icons.folder_open_outlined,
                    color: const Color(0xFF00BCD4),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Aquí se podrían añadir más secciones, por ejemplo "Próximas Tutorías"
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1828),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones Rápidas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.2),
                        child: const Icon(Icons.add_task, color: Color(0xFF7C4DFF)),
                      ),
                      title: const Text('Crear nueva lección', style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                      onTap: () {
                        // Navegar a creación
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
                        child: const Icon(Icons.upload_file, color: Color(0xFF4CAF50)),
                      ),
                      title: const Text('Subir recurso', style: TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                      onTap: () {
                        // Navegar a recursos
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
