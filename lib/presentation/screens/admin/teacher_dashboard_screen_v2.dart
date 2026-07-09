import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/screens/admin/create_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_exercise_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/manage_classroom_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/profile_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/upload_resource_screen.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/presentation/providers/dashboard_teacher_provider.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final classroomsAsync = ref.watch(classroomsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel del Docente')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statsProvider);
          ref.invalidate(classroomsListProvider);
          await ref.read(statsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _ErrorPanel(
                message: 'No se pudieron cargar los datos: $err',
              ),
              data: (stats) => Row(
                children: [
                  _StatCard(
                    title: 'Aulas activas',
                    value: '${stats.totalAulas}',
                    icon: Icons.school_outlined,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    title: 'Alumnos',
                    value: '${stats.totalAlumnos}',
                    icon: Icons.people_alt_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Acciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.add_business_outlined,
              title: 'Crear aula',
              subtitle: 'Crear una clase con codigo de acceso',
              screen: const CreateClassroomScreen(),
            ),
            _ActionTile(
              icon: Icons.quiz_outlined,
              title: 'Crear ejercicio',
              subtitle: 'Publicar actividades para una leccion',
              screen: const CreateExerciseScreen(),
            ),
            _ActionTile(
              icon: Icons.upload_file_outlined,
              title: 'Subir recurso',
              subtitle: 'Compartir material con estudiantes',
              screen: const UploadResourceScreen(),
            ),
            _ActionTile(
              icon: Icons.person_outline,
              title: 'Perfil docente',
              subtitle: 'Actualizar idiomas y datos del profesor',
              screen: const ProfileScreen(),
            ),
            const SizedBox(height: 24),
            Text('Mis aulas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            classroomsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _ErrorPanel(
                message: 'No se pudieron cargar las aulas: $err',
              ),
              data: (classrooms) {
                if (classrooms.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No tienes aulas creadas todavia.'),
                    ),
                  );
                }

                return Column(
                  children: classrooms
                      .map(
                        (classroom) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.class_outlined),
                            title: Text(classroom.name),
                            subtitle: Text(
                              '${classroom.totalStudents} alumnos - Codigo ${classroom.accessCode}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ManageClassroomScreen(
                                  classroomId: classroom.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon,
                  size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => screen),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}
