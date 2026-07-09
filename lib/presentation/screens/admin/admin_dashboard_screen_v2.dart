import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/presentation/screens/admin/announcements_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/create_course_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/report_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/subscriptions_screen.dart';
import 'package:jumpup_app/presentation/screens/admin/users_list_screen.dart';
import 'package:jumpup_app/presentation/providers/admin_stats_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administracion')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          await ref.read(adminStatsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _ErrorPanel(
                message: 'No se pudieron cargar las estadisticas: $err',
              ),
              data: (stats) => LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 520 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.25,
                    children: [
                      _StatCard(
                          title: 'Usuarios', value: '${stats.totalUsers}'),
                      _StatCard(
                          title: 'Profesores', value: '${stats.teachers}'),
                      _StatCard(
                          title: 'Estudiantes', value: '${stats.students}'),
                      _StatCard(title: 'Cursos', value: '${stats.courses}'),
                      _StatCard(title: 'Aulas', value: '${stats.classrooms}'),
                      _StatCard(
                        title: 'Suscripciones',
                        value: '${stats.subscriptions}',
                      ),
                      _StatCard(title: 'Pagos', value: '${stats.payments}'),
                      _StatCard(
                        title: 'Certificados',
                        value: '${stats.certificates}',
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gestion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.people_alt_outlined,
              title: 'Usuarios',
              subtitle: 'Activar, desactivar y revisar roles',
              screen: const UsersListScreen(),
            ),
            _ActionTile(
              icon: Icons.menu_book_outlined,
              title: 'Cursos e idiomas',
              subtitle: 'Crear cursos conectados a idiomas',
              screen: const CreateCourseScreen(),
            ),
            _ActionTile(
              icon: Icons.campaign_outlined,
              title: 'Anuncios',
              subtitle: 'Ver comunicados publicados',
              screen: const AnnouncementsScreen(),
            ),
            _ActionTile(
              icon: Icons.report_gmailerrorred_outlined,
              title: 'Reportes',
              subtitle: 'Moderar reportes de la comunidad',
              screen: const ReportsScreen(),
            ),
            _ActionTile(
              icon: Icons.workspace_premium_outlined,
              title: 'Suscripciones',
              subtitle: 'Planes premium y checkout',
              screen: const SubscriptionsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
