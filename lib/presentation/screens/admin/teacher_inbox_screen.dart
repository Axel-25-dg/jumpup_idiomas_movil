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
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1828),
        elevation: 0,
        title: const Text('Mensajes de Alumnos',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(chatThreadsProvider),
          ),
        ],
      ),
      body: threadsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Error: $e',
                  style: const TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
        data: (threads) {
          if (threads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Colors.white30),
                  SizedBox(height: 12),
                  Text('Bandeja vacía',
                      style:
                          TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(height: 8),
                  Text('No tienes mensajes de tus alumnos aún.',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              // MessageThread usa: subject, participantNames, participantName,
              // unreadCount, lastMessageBody, lastMessageAt
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
                        backgroundColor:
                            const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                        child: Text(
                          thread.participantName.isNotEmpty
                              ? thread.participantName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Color(0xFF7C4DFF),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              thread.participantNames.isNotEmpty
                                  ? thread.participantNames.join(', ')
                                  : thread.participantName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              thread.lastMessageBody ?? thread.subject,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (thread.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (thread.lastMessageAt != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            DateFormat('HH:mm').format(thread.lastMessageAt!),
                            style: const TextStyle(
                                color: Colors.white30, fontSize: 12),
                          ),
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
