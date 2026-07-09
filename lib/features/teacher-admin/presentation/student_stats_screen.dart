import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/providers/student_stats_provider.dart';

class StudentStatsScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;

  const StudentStatsScreen({
    super.key, 
    required this.studentId, 
    required this.studentName
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(studentStatsProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text('Progreso: $studentName')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard(Icons.emoji_events, 'XP Total', '${stats.totalXp}'),
            _buildStatCard(Icons.local_fire_department, 'Racha Actual', '${stats.currentStreak} días'),
            _buildStatCard(Icons.military_tech, 'Mejor Racha', '${stats.longestStreak} días'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}