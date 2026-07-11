import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/screens/social/message_detail_screen.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
        error: (e, _) => _buildError(ref, isDark),
        data: (threads) {
          if (threads.isEmpty) return _buildEmpty(isDark);
          return RefreshIndicator(
            color: const Color(0xFF7C4DFF),
            backgroundColor: isDark ? const Color(0xFF1A1B2E) : Colors.white,
            onRefresh: () => ref.refresh(chatThreadsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ThreadTile(thread: threads[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(WidgetRef ref, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 12),
          Text('Error al cargar mensajes',
              style: AppTextStyles.titleMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(chatThreadsProvider),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), foregroundColor: Colors.white),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: Color(0xFF7C4DFF)),
          ),
          const SizedBox(height: 16),
          Text('Sin conversaciones',
              style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Inicia un nuevo chat desde el foro',
              style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
        ],
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread});
  final MessageThread thread;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white38 : Colors.black38;
    final iconFadeColor = isDark ? Colors.white24 : Colors.black26;
    final initial = thread.participantName.isNotEmpty
        ? thread.participantName[0].toUpperCase()
        : '?';

    return GlassContainer(
      opacity: 0.08,
      blur: 10,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
          backgroundImage: thread.participantAvatar != null
              ? NetworkImage(thread.participantAvatar!)
              : null,
          child: thread.participantAvatar == null
              ? Text(initial,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: const Color(0xFF7C4DFF), fontWeight: FontWeight.w900,
                  ))
              : null,
        ),
        title: Text(thread.subject.isNotEmpty ? thread.subject : thread.participantName,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: thread.unreadCount > 0 ? FontWeight.w900 : FontWeight.bold,
              color: textColor,
            )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            thread.lastMessageBody ?? 'Sin mensajes',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: thread.unreadCount > 0 ? textColor : subtextColor,
              fontWeight: thread.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (thread.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF7C4DFF).withValues(alpha: 0.4), blurRadius: 8)
                  ],
                ),
                child: Text('${thread.unreadCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
              ),
            const SizedBox(height: 4),
            Icon(Icons.chevron_right_rounded, color: iconFadeColor, size: 20),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MessageDetailScreen(thread: thread)),
        ),
      ),
    );
  }
}
