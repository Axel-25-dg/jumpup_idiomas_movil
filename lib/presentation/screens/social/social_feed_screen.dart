import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/colors.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Publicar',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => setState(() => _showCompose = !_showCompose),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: _showCompose ? 180 : 0,
            curve: Curves.fastOutSlowIn,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GlassContainer(
                  opacity: 0.1,
                  blur: 15,
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _contentController,
                        maxLines: 3,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '¿Qué quieres compartir?',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                      const Divider(color: Colors.white10),
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
                                style: AppTextStyles.labelMedium.copyWith(color: Colors.white54)),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: FilledButton(
                              onPressed: _posting ? null : _createPost,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7C4DFF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _posting
                                  ? const SizedBox(width: 16, height: 16,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Publicar',
                                      style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: feedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
              error: (e, _) => _buildErrorState(ref),
              data: (posts) => posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      physics: const BouncingScrollPhysics(),
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
          const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.white24),
          const SizedBox(height: 12),
          Text('No se pudo cargar el feed', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => ref.invalidate(socialFeedProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), foregroundColor: Colors.white),
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
              color: const Color(0xFF7C4DFF).withOpacity(0.1),
            ),
            child: const Icon(Icons.explore_rounded, size: 56, color: Color(0xFF7C4DFF)),
          ),
          const SizedBox(height: 20),
          Text('¡Sé el primero en publicar!',
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Comparte tu progreso con la comunidad',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        opacity: 0.08,
        blur: 10,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.15),
                    backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                    child: post.authorAvatar == null
                        ? Text(initial,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: const Color(0xFF7C4DFF), fontWeight: FontWeight.w900, fontSize: 16,
                            ))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName, style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(time, style: AppTextStyles.labelSmall.copyWith(color: Colors.white38)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _colorForType(post.postType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _colorForType(post.postType).withOpacity(0.5)),
                    ),
                    child: Text(
                      _labelForType(post.postType),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _colorForType(post.postType), fontWeight: FontWeight.w700, fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(post.content, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), height: 1.5)),
            ),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                  child: Image.network(post.imageUrl!, fit: BoxFit.cover, height: 220, width: double.infinity),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                              color: post.isLiked ? Colors.redAccent : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text('${post.reactionCount}',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: post.isLiked ? Colors.redAccent : Colors.white54,
                                  fontWeight: FontWeight.bold,
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
                        const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white38, size: 19),
                        const SizedBox(width: 6),
                        Text('${post.commentCount}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white54, fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white38, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'progress': return const Color(0xFF00E676);
      case 'question': return const Color(0xFFFFD54F);
      case 'achievement': return const Color(0xFF00B4DB);
      default: return const Color(0xFF7C4DFF);
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
