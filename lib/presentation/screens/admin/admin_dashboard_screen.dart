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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        centerTitle: true,
      ),
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
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _ErrorPanel(
                message: 'No se pudieron cargar las estadísticas: $err',
              ),
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen General',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 600 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: [
                          _StatCard(
                            title: 'Usuarios',
                            value: '${stats.totalUsers}',
                            icon: Icons.people_alt,
                            color: colors.primary,
                          ),
                          _StatCard(
                            title: 'Profesores',
                            value: '${stats.teachers}',
                            icon: Icons.school,
                            color: colors.secondary,
                          ),
                          _StatCard(
                            title: 'Estudiantes',
                            value: '${stats.students}',
                            icon: Icons.person,
                            color: colors.tertiary,
                          ),
                          _StatCard(
                            title: 'Cursos',
                            value: '${stats.courses}',
                            icon: Icons.menu_book,
                            color: Colors.green,
                          ),
                          _StatCard(
                            title: 'Aulas',
                            value: '${stats.classrooms}',
                            icon: Icons.school,
                            color: Colors.orange,
                          ),
                          _StatCard(
                            title: 'Suscripciones',
                            value: '${stats.subscriptions}',
                            icon: Icons.workspace_premium,
                            color: Colors.purple,
                          ),
                          _StatCard(
                            title: 'Pagos',
                            value: '${stats.payments}',
                            icon: Icons.payment,
                            color: Colors.teal,
                          ),
                          _StatCard(
                            title: 'Certificados',
                            value: '${stats.certificates}',
                            icon: Icons.verified,
                            color: Colors.indigo,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gestión',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.people_alt_outlined,
              title: 'Usuarios',
              subtitle: 'Activar, desactivar y revisar roles',
              color: colors.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UsersListScreen()),
              ),
            ),
            _ActionTile(
              icon: Icons.menu_book_outlined,
              title: 'Cursos e idiomas',
              subtitle: 'Crear cursos conectados a idiomas',
              color: Colors.green,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
              ),
            ),
            _ActionTile(
              icon: Icons.campaign_outlined,
              title: 'Anuncios',
              subtitle: 'Ver y publicar comunicados',
              color: Colors.orange,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
              ),
            ),
            _ActionTile(
              icon: Icons.report_gmailerrorred_outlined,
              title: 'Reportes',
              subtitle: 'Moderar reportes de la comunidad',
              color: Colors.red,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
            _ActionTile(
              icon: Icons.workspace_premium_outlined,
              title: 'Suscripciones',
              subtitle: 'Planes premium y checkout',
              color: Colors.purple,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
              ),
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
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
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
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
