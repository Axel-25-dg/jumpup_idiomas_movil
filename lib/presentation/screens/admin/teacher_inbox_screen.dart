import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class TeacherInboxScreen extends ConsumerWidget {
  const TeacherInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bandeja de Entrada', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.invalidate(chatThreadsProvider),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF66BB6A).withValues(alpha: 0.05),
              ),
            ),
          ),
          threadsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
            data: (threads) {
              if (threads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.forum_rounded, size: 64, color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Bandeja vacía', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('No tienes conversaciones activas aún.', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: threads.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final thread = threads[index];
                  return InkWell(
                    onTap: () {
                      // context.push(AppRoutes.chatDetail.replaceAll(':id', thread.id.toString()));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: GlassContainer(
                      opacity: 0.05,
                      blur: 12,
                      padding: const EdgeInsets.all(16),
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                              child: Text(
                                thread.participantName.isNotEmpty ? thread.participantName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(thread.participantName,
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    if (thread.lastMessageAt != null)
                                      Text(
                                        DateFormat('HH:mm').format(thread.lastMessageAt!),
                                        style: const TextStyle(color: Colors.white30, fontSize: 11),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  thread.lastMessageBody ?? 'Inicia una conversación...',
                                  style: TextStyle(
                                    color: thread.lastMessageBody != null ? Colors.white70 : Colors.white30,
                                    fontSize: 13,
                                    fontStyle: thread.lastMessageBody != null ? FontStyle.normal : FontStyle.italic
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
