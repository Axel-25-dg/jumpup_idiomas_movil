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
      body: Stack(
        children: [
          // Decorative Blobs
          Positioned(
            top: -100,
            right: -100,
            child: _blob(const Color(0xFF7C4DFF), 300),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _blob(const Color(0xFF00E5FF), 250),
          ),

          RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            onRefresh: () async => ref.invalidate(chatThreadsProvider),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverAppBar(
                  expandedHeight: 120,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    title: Text(
                      'Bandeja de Entrada',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    centerTitle: false,
                  ),
                ),

                threadsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  ),
                  error: (e, stack) {
                    debugPrint('Inbox Error: $e\n$stack');
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Error al cargar mensajes. Por favor, intenta de nuevo.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    );
                  },
                  data: (threads) {
                    if (threads.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded, size: 64, color: Colors.white30),
                              SizedBox(height: 12),
                              Text('Bandeja vacía',
                                  style: TextStyle(color: Colors.white, fontSize: 18)),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final thread = threads[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                opacity: 0.1,
                                blur: 15,
                                padding: const EdgeInsets.all(16),
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF7C4DFF),
                                            const Color(0xFF00E5FF).withValues(alpha: 0.5)
                                          ],
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(0xFF1E1E2A),
                                        child: Text(
                                          (thread.participantName.isNotEmpty)
                                              ? thread.participantName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            thread.lastMessageBody ?? thread.subject,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (thread.lastMessageAt != null)
                                          Text(
                                            DateFormat('HH:mm').format(thread.lastMessageAt!),
                                            style: const TextStyle(
                                              color: Colors.white30,
                                              fontSize: 11,
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        if (thread.unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7C4DFF),
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                )
                                              ],
                                            ),
                                            child: Text(
                                              '${thread.unreadCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: threads.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.05),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 80)],
        ),
      );
}
