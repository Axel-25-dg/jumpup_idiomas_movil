import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';

class TeacherInboxScreen extends ConsumerWidget {
  const TeacherInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Mensajes de Alumnos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(chatThreadsProvider),
          ),
        ],
      ),
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
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
                  const Icon(Icons.inbox_rounded, size: 64, color: Colors.white30),
                  const SizedBox(height: 12),
                  const Text('Bandeja vacía', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  const Text('No tienes mensajes de tus alumnos aún.', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  opacity: 0.1,
                  blur: 10,
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.2),
                        child: Text(
                          thread.participants.first.name[0].toUpperCase(),
                          style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(thread.participants.map((p) => p.name).join(', '),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              thread.lastMessage?.content ?? 'Sin mensajes',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (thread.lastMessage != null)
                        Text(
                          DateFormat('HH:mm').format(thread.lastMessage!.createdAt),
                          style: const TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
