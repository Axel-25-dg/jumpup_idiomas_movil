import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/app_theme.dart';

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});
  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  final _repo = SocialMediaRepository();
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
      await _repo.createSocialPost(content: content);
      _contentController.clear();
      setState(() => _showCompose = false);
      if (mounted) ref.invalidate(socialFeedProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  Future<void> _toggleLike(SocialPost post) async {
    try {
      if (post.isLiked) {
        await _repo.unlikePost(post.id);
      } else {
        await _repo.likePost(post.id);
      }
      if (mounted) ref.invalidate(socialFeedProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(socialFeedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F9FF),
      appBar: AppBar(
        backgroundColor: AppTheme.celeste,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Feed JumpUp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref.invalidate(socialFeedProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.celeste,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Publicar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => setState(() => _showCompose = !_showCompose),
      ),
      body: Column(
        children: [
          // Compose box
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.celeste.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: '¿Qué quieres compartir con la comunidad JumpUp?',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppTheme.textoClaro),
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() { _showCompose = false; _contentController.clear(); }),
                          child: const Text('Cancelar', style: TextStyle(color: AppTheme.textoClaro)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.celeste),
                          onPressed: _posting ? null : _createPost,
                          child: _posting
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Publicar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Feed
          Expanded(
            child: feedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.celeste)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 60, color: AppTheme.textoClaro),
                    const SizedBox(height: 12),
                    const Text('No se pudo cargar el feed', style: TextStyle(color: AppTheme.textoClaro)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.celeste),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                      onPressed: () => ref.invalidate(socialFeedProvider),
                    ),
                  ],
                ),
              ),
              data: (posts) => posts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      itemCount: posts.length,
                      itemBuilder: (ctx, i) => _PostCard(
                        post: posts[i],
                        onLike: () => _toggleLike(posts[i]),
                      ),
                    ),
            ),
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
              color: AppTheme.celeste.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.rocket_launch_outlined, size: 56, color: AppTheme.celeste),
          ),
          const SizedBox(height: 20),
          const Text('¡Sé el primero en publicar!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textoOscuro)),
          const SizedBox(height: 8),
          const Text('Comparte tu progreso con la comunidad', style: TextStyle(color: AppTheme.textoClaro)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppTheme.celeste.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.celeste.withValues(alpha: 0.15),
                  backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                  child: post.authorAvatar == null
                      ? Text(initial, style: const TextStyle(color: AppTheme.celeste, fontWeight: FontWeight.bold, fontSize: 16))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textoOscuro, fontSize: 14)),
                      Text(time, style: const TextStyle(color: AppTheme.textoClaro, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.celeste.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Estudiante', style: TextStyle(color: AppTheme.celeste, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(post.content, style: const TextStyle(color: AppTheme.textoOscuro, fontSize: 15, height: 1.4)),
          ),
          // Imagen si hay
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                child: Image.network(post.imageUrl!, fit: BoxFit.cover, height: 200, width: double.infinity),
              ),
            ),
          // Acciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Like
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onLike,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Icon(post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: post.isLiked ? Colors.red : AppTheme.textoClaro, size: 20),
                          const SizedBox(width: 4),
                          Text('${post.likes}', style: TextStyle(color: post.isLiked ? Colors.red : AppTheme.textoClaro, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Comentarios
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.textoClaro, size: 19),
                      const SizedBox(width: 4),
                      Text('${post.comments}', style: const TextStyle(color: AppTheme.textoClaro, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Spacer(),
                // Compartir
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppTheme.textoClaro, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
