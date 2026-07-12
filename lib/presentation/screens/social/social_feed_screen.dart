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

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> with AutomaticKeepAliveClientMixin {
  final _contentController = TextEditingController();
  bool _posting = false;
  bool _showCompose = false;

  @override
  bool get wantKeepAlive => true;

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
      if (mounted) _contentController.clear();
      if (mounted) setState(() => _showCompose = false);
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
    super.build(context); // Importante para KeepAlive
    final feedAsync = ref.watch(socialFeedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    const accentColor = Color(0xFF6A11CB);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2575FC).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Publicar',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            onPressed: () => setState(() => _showCompose = !_showCompose),
          ),
        ),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: _showCompose ? 200 : 0,
            curve: Curves.fastOutSlowIn,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: GlassContainer(
                  opacity: isDark ? 0.08 : 0.12,
                  blur: 24,
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    children: [
                      TextField(
                        controller: _contentController,
                        maxLines: 3,
                        style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: '¿Qué quieres compartir?',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: subtextColor),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                style: AppTextStyles.labelMedium.copyWith(color: subtextColor, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                            ),
                            child: ElevatedButton(
                              onPressed: _posting ? null : _createPost,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              child: _posting
                                  ? const SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Publicar',
                                      style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
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
              loading: () => const Center(child: CircularProgressIndicator(color: accentColor)),
              error: (e, _) => _buildErrorState(ref, isDark),
              data: (posts) => posts.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
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

  Widget _buildErrorState(WidgetRef ref, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 12),
          Text('No se pudo cargar el feed',
              style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.explore_rounded, size: 56, color: Color(0xFF7C4DFF)),
          ),
          const SizedBox(height: 20),
          Text('¡Sé el primero en publicar!',
              style: AppTextStyles.titleLarge.copyWith(
                  color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Comparte tu progreso con la comunidad',
              style: AppTextStyles.bodyMedium.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white38 : Colors.black38;
    final bodyColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final iconFadeColor = isDark ? Colors.white38 : Colors.black38;
    final time = DateFormat('dd MMM, HH:mm').format(post.createdAt);
    final initial = post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        opacity: isDark ? 0.05 : 0.08,
        blur: 20,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: isDark ? Colors.black26 : Colors.white,
                      backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                      child: post.authorAvatar == null
                          ? Text(initial,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: const Color(0xFF6A11CB), fontWeight: FontWeight.w900, fontSize: 16,
                              ))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorName,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: textColor, fontWeight: FontWeight.w900, letterSpacing: -0.2
                            )),
                        Text(time, style: AppTextStyles.labelSmall.copyWith(color: subtextColor)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _colorForType(post.postType).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _labelForType(post.postType).toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _colorForType(post.postType), fontWeight: FontWeight.w900, fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(post.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: bodyColor, height: 1.6, fontWeight: FontWeight.w500
                  )),
            ),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(post.imageUrl!, fit: BoxFit.cover, height: 240, width: double.infinity),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: GlassContainer(
                opacity: 0.05,
                blur: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    _ActionButton(
                      icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      label: '${post.reactionCount}',
                      color: post.isLiked ? Colors.redAccent : iconFadeColor,
                      onTap: onLike,
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: '${post.commentCount}',
                      color: iconFadeColor,
                      onTap: () {},
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share_rounded, color: iconFadeColor, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
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
      case 'question': return const Color(0xFFFFAB00);
      case 'achievement': return const Color(0xFF2575FC);
      default: return const Color(0xFF6A11CB);
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color, fontWeight: FontWeight.w900,
                )),
          ],
        ),
      ),
    );
  }
}

