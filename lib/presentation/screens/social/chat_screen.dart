import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/presentation/screens/social/message_detail_screen.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final threadsAsync = ref.watch(chatThreadsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6A11CB))),
        error: (e, _) => _buildError(ref, isDark),
        data: (threads) {
          if (threads.isEmpty) return _buildEmpty(isDark);
          return RefreshIndicator(
            color: const Color(0xFF6A11CB),
            backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
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
              style: AppTextStyles.titleMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
            ),
            child: FilledButton(
              onPressed: () => ref.invalidate(chatThreadsProvider),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reintentar'),
            ),
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
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6A11CB).withValues(alpha: 0.1),
                  const Color(0xFF2575FC).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: Color(0xFF2575FC)),
          ),
          const SizedBox(height: 20),
          Text('Sin conversaciones',
              style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark ? Colors.white : Colors.black87, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          const SizedBox(height: 8),
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
      opacity: isDark ? 0.06 : 0.08,
      blur: 24,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF6A11CB).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF6A11CB).withValues(alpha: 0.1),
            backgroundImage: thread.participantAvatar != null
                ? NetworkImage(thread.participantAvatar!)
                : null,
            child: thread.participantAvatar == null
                ? Text(initial,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: const Color(0xFF6A11CB), fontWeight: FontWeight.w900,
                    ))
                : null,
          ),
        ),
        title: Text(thread.subject.isNotEmpty ? thread.subject : thread.participantName,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: thread.unreadCount > 0 ? FontWeight.w900 : FontWeight.w800,
              color: textColor,
              letterSpacing: -0.3,
            )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            thread.lastMessageBody ?? 'Sin mensajes',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: thread.unreadCount > 0 ? textColor : subtextColor,
              fontWeight: thread.unreadCount > 0 ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (thread.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2575FC).withValues(alpha: 0.4), blurRadius: 8)
                  ],
                ),
                child: Text('${thread.unreadCount}',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
              )
            else
              Icon(Icons.chevron_right_rounded, color: iconFadeColor, size: 22),
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
