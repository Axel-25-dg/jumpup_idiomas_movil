import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});
  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  final _contentController = TextEditingController();
  bool _posting = false;
  bool _showCompose = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _posting = true);
    try {
      await ref.read(socialRepositoryProvider).createSocialPost(content: content);
      _contentController.clear();
      setState(() => _showCompose = false);
      if (mounted) ref.invalidate(socialFeedProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _toggleReaction(SocialPost post) async {
    final repo = ref.read(socialRepositoryProvider);
    try {
      if (post.isLiked) {
        await repo.removeReaction(post.id);
      } else {
        await repo.reactToPost(post.id);
      }
      if (mounted) ref.invalidate(socialFeedProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(socialFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Publicar',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
        onPressed: () => setState(() => _showCompose = !_showCompose),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showCompose ? 160 : 0,
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _contentController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '¿Qué quieres compartir?',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showCompose = false;
                              _contentController.clear();
                            });
                          },
                          child: Text('Cancelar',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 36,
                          child: FilledButton(
                            onPressed: _posting ? null : _createPost,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _posting
                                ? const SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Publicar',
                                    style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: feedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => _buildErrorState(ref),
              data: (posts) => posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      itemCount: posts.length,
                      itemBuilder: (ctx, i) => _PostCard(
                        post: posts[i],
                        onLike: () => _toggleReaction(posts[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('No se pudo cargar el feed', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.invalidate(socialFeedProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(Icons.explore_rounded, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('¡Sé el primero en publicar!',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Comparte tu progreso con la comunidad',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final SocialPost post;
  final VoidCallback onLike;
  const _PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd MMM, HH:mm').format(post.createdAt);
    final initial = post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                  child: post.authorAvatar == null
                      ? Text(initial,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16,
                          ))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: AppTextStyles.labelLarge),
                      Text(time, style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorForType(post.postType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labelForType(post.postType),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(post.content, style: AppTextStyles.bodyMedium.copyWith(height: 1.4)),
          ),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                child: Image.network(post.imageUrl!, fit: BoxFit.cover, height: 200, width: double.infinity),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onLike,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: post.isLiked ? AppColors.error : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.reactionCount}',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: post.isLiked ? AppColors.error : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary, size: 19),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary, fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'progress': return AppColors.success;
      case 'question': return AppColors.warning;
      case 'achievement': return AppColors.secondary;
      default: return AppColors.primary;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'progress': return 'Progreso';
      case 'question': return 'Pregunta';
      case 'achievement': return 'Logro';
      default: return 'General';
    }
  }
}
