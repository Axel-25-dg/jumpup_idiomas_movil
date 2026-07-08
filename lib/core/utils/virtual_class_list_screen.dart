import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/virtual_class_models.dart';
import '../../models/virtual_class_providers.dart';

class VirtualClassListScreen extends ConsumerWidget {
  const VirtualClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(virtualClassesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        title: const Text('Clases Virtuales', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (_, __) => const Center(child: Text('Error al cargar clases', style: TextStyle(color: Colors.redAccent))),
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('No hay clases programadas', style: TextStyle(color: Colors.white54)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (_, i) => _VirtualClassCard(vClass: classes[i]),
          );
        },
      ),
    );
  }
}

class _VirtualClassCard extends ConsumerWidget {
  const _VirtualClassCard({required this.vClass});
  final VirtualClassModel vClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinStatus = ref.watch(joinClassNotifierProvider);
    final isFull = vClass.isFull;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: vClass.isOngoing ? const Color(0xFF4CAF50).withOpacity(0.2) : const Color(0xFF7C4DFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  vClass.isOngoing ? 'EN VIVO' : 'PROGRAMADA',
                  style: TextStyle(
                    color: vClass.isOngoing ? const Color(0xFF4CAF50) : const Color(0xFF7C4DFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.people_outline, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${vClass.currentParticipants}/${vClass.maxParticipants}',
                    style: TextStyle(color: isFull ? Colors.redAccent : Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(vClass.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text(vClass.description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 16, color: Colors.white)),
              const SizedBox(width: 8),
              Text(vClass.instructorName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isFull && !vClass.canJoin) || joinStatus == JoinClassStatus.loading
                  ? null
                  : () {
                      ref.read(joinClassNotifierProvider.notifier).joinClass(vClass.id);
                      if (vClass.canJoin) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Redirigiendo a la sala...')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inscripción exitosa. Te notificaremos antes de empezar.')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFull && !vClass.canJoin ? Colors.white12 : const Color(0xFF7C4DFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                vClass.canJoin ? 'Unirse ahora' : (isFull ? 'Clase llena' : 'Inscribirse'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
