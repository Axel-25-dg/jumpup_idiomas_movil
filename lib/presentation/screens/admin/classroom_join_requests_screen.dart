import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/domain/model/admin/classroom_join_request_model.dart';
import 'package:jumpup_app/presentation/providers/classroom_provider.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ClassroomJoinRequestsScreen extends ConsumerWidget {
  const ClassroomJoinRequestsScreen({super.key, required this.classroomId});
  final int classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(classroomJoinRequestsProvider(classroomId));
    final mutationState = ref.watch(classroomJoinRequestsNotifierProvider);

    ref.listen(classroomJoinRequestsNotifierProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Solicitudes de Ingreso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          // Background decorative blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.05), blurRadius: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(color: Colors.purpleAccent.withValues(alpha: 0.05), blurRadius: 100),
                ],
              ),
            ),
          ),
          
          requestsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar las solicitudes',
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(classroomJoinRequestsProvider(classroomId)),
                    child: const Text('Reintentar', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ),
            data: (requests) {
              final pendingRequests = requests.where((r) => r.status == 'pending').toList();
              
              if (pendingRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.white24),
                      const SizedBox(height: 20),
                      Text(
                        '¡Todo al día!',
                        style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tienes solicitudes de ingreso pendientes.',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: pendingRequests.length,
                    itemBuilder: (context, index) {
                      final req = pendingRequests[index];
                      return FadeInRight(
                        delay: Duration(milliseconds: index * 100),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(20),
                            opacity: 0.05,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                                      child: const Icon(Icons.person_rounded, color: Colors.blueAccent),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            req.studentUsername,
                                            style: AppTextStyles.titleMedium.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            req.studentEmail,
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: Colors.white54,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Solicitada: ${DateFormat('dd/MM/yyyy HH:mm').format(req.createdAt.toLocal())}',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (req.message != null && req.message!.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.02),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                    ),
                                    child: Text(
                                      req.message!,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: mutationState.isLoading
                                            ? null
                                            : () => _rejectRequest(context, ref, req),
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        label: const Text('Rechazar'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.redAccent,
                                          side: const BorderSide(color: Colors.redAccent),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: mutationState.isLoading
                                            ? null
                                            : () => _approveRequest(context, ref, req),
                                        icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                                        label: const Text('Aprobar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (mutationState.isLoading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _approveRequest(BuildContext context, WidgetRef ref, ClassroomJoinRequest req) async {
    await ref.read(classroomJoinRequestsNotifierProvider.notifier).approveRequest(classroomId, req.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud aprobada con éxito'),
          backgroundColor: Colors.greenAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _rejectRequest(BuildContext context, WidgetRef ref, ClassroomJoinRequest req) async {
    // Show confirmation dialog before rejecting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('¿Rechazar solicitud?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que quieres rechazar la solicitud de ${req.studentUsername}?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RECHAZAR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(classroomJoinRequestsNotifierProvider.notifier).rejectRequest(classroomId, req.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
