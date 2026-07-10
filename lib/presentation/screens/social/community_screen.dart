import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(forumCategoriesProvider);
    final threadsAsync = ref.watch(forumThreadsProvider(_selectedCategoryId));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 3,
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Nuevo Tema',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Category chips
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: FilterChip(
                        label: Text('Todos',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _selectedCategoryId == null
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            )),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) => setState(() => _selectedCategoryId = null),
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color: _selectedCategoryId == null
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: FilterChip(
                        label: Text(cat.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _selectedCategoryId == cat.id
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            )),
                        selected: _selectedCategoryId == cat.id,
                        onSelected: (_) => setState(() =>
                            _selectedCategoryId = _selectedCategoryId == cat.id ? null : cat.id),
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color: _selectedCategoryId == cat.id
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    )),
                  ],
                ),
              );
            },
          ),

          // Thread list
          Expanded(
            child: threadsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('Error al cargar el foro', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(forumThreadsProvider(_selectedCategoryId)),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (threads) {
                if (threads.isEmpty) return _buildEmpty();
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(forumThreadsProvider(_selectedCategoryId).future),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: threads.length,
                    itemBuilder: (context, index) => _ForumThreadCard(
                      thread: threads[index],
                      onTap: () => _showThreadPosts(context, threads[index]),
                    ),
                  ),
                );
              },
            ),
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
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.forum_outlined, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          Text('No hay temas aún', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('¡Crea el primer tema!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateForumThreadSheet(
        selectedCategoryId: _selectedCategoryId,
        onCreated: () {
          ref.invalidate(forumThreadsProvider(_selectedCategoryId));
        },
      ),
    );
  }

  void _showThreadPosts(BuildContext context, ForumThread thread) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ForumThreadDetailScreen(thread: thread)),
    );
  }
}

class _ForumThreadCard extends StatelessWidget {
  const _ForumThreadCard({required this.thread, required this.onTap});
  final ForumThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: thread.isPinned ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: thread.isPinned
              ? AppColors.secondary.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            thread.isPinned ? Icons.push_pin_rounded : Icons.forum_outlined,
            size: 20,
            color: thread.isPinned ? AppColors.secondary : AppColors.primary,
          ),
        ),
        title: Text(thread.title,
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(thread.authorName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
              if (thread.categoryName.isNotEmpty) ...[
                Text(' · ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                Text(thread.categoryName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
              ],
              const Spacer(),
              Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Text('${thread.views}', style: AppTextStyles.bodySmall),
              const SizedBox(width: 8),
              Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${thread.postCount}', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        trailing: thread.isPinned
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Fijado', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary)),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _CreateForumThreadSheet extends ConsumerStatefulWidget {
  const _CreateForumThreadSheet({this.selectedCategoryId, this.onCreated});
  final int? selectedCategoryId;
  final VoidCallback? onCreated;

  @override
  ConsumerState<_CreateForumThreadSheet> createState() => _CreateForumThreadSheetState();
}

class _CreateForumThreadSheetState extends ConsumerState<_CreateForumThreadSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  int? _categoryId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.selectedCategoryId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(forumCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuevo tema', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) => DropdownButtonFormField<int>(
              value: _categoryId,
              hint: const Text('Seleccionar categoría'),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Título del tema',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Escribe tu mensaje...',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_loading || _categoryId == null || _titleCtrl.text.trim().isEmpty)
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        await ref.read(socialRepositoryProvider).createForumThread(
                              categoryId: _categoryId!,
                              title: _titleCtrl.text.trim(),
                              body: _bodyCtrl.text.trim(),
                            );
                        widget.onCreated?.call();
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Publicar', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ForumThreadDetailScreen extends ConsumerStatefulWidget {
  const _ForumThreadDetailScreen({required this.thread});
  final ForumThread thread;

  @override
  ConsumerState<_ForumThreadDetailScreen> createState() => _ForumThreadDetailScreenState();
}

class _ForumThreadDetailScreenState extends ConsumerState<_ForumThreadDetailScreen> {
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider(widget.thread.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(widget.thread.title,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Thread header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.thread.body, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(widget.thread.authorName,
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${widget.thread.views} vistas', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Posts
          Expanded(
            child: postsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (posts) {
                final visible = posts.where((p) => !p.isDeleted).toList();
                if (visible.isEmpty) {
                  return Center(
                    child: Text('No hay respuestas aún',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: visible.length,
                  itemBuilder: (ctx, i) => _ForumPostCard(post: visible[i]),
                );
              },
            ),
          ),

          // Reply input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyCtrl,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Escribe una respuesta...',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      final text = _replyCtrl.text.trim();
                      if (text.isEmpty) return;
                      try {
                        await ref.read(socialRepositoryProvider).createForumPost(
                              threadId: widget.thread.id,
                              body: text,
                            );
                        _replyCtrl.clear();
                        ref.invalidate(forumPostsProvider(widget.thread.id));
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.send, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForumPostCard extends StatelessWidget {
  const _ForumPostCard({required this.post});
  final ForumPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(post.authorName,
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (post.reactionCount > 0)
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('${post.reactionCount}', style: AppTextStyles.bodySmall),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.body, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
