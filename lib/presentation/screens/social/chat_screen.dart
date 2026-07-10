import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/screens/social/message_detail_screen.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => _buildError(ref),
        data: (threads) {
          if (threads.isEmpty) return _buildEmpty();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(chatThreadsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) => _ThreadTile(thread: threads[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Error al cargar mensajes', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.invalidate(chatThreadsProvider),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text('Sin conversaciones', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Inicia un nuevo chat desde el foro',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
    final initial = thread.participantName.isNotEmpty
        ? thread.participantName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: thread.unreadCount > 0 ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: thread.participantAvatar != null
                  ? NetworkImage(thread.participantAvatar!)
                  : null,
              child: thread.participantAvatar == null
                  ? Text(initial,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700,
                      ))
                  : null,
            ),
          ],
        ),
        title: Text(thread.subject.isNotEmpty ? thread.subject : thread.participantName,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: thread.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            )),
        subtitle: Text(
          thread.lastMessageBody ?? 'Sin mensajes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            color: thread.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: thread.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: thread.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${thread.unreadCount}',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              )
            : null,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MessageDetailScreen(thread: thread)),
        ),
      ),
    );
  }
}
