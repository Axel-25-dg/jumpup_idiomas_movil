import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';
import 'package:jumpup_app/presentation/providers/social_providers.dart';
import 'package:jumpup_app/theme/text_styles.dart';
import 'package:jumpup_app/widgets/glass_container.dart';

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
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 4,
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Nuevo Tema',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
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
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: FilterChip(
                        label: Text('Todos',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _selectedCategoryId == null
                                  ? Colors.white
                                  : Colors.white38,
                              fontWeight: FontWeight.bold,
                            )),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) => setState(() => _selectedCategoryId = null),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: _selectedCategoryId == null
                              ? const Color(0xFF7C4DFF)
                              : Colors.white12,
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
                                  : Colors.white38,
                              fontWeight: FontWeight.bold,
                            )),
                        selected: _selectedCategoryId == cat.id,
                        onSelected: (_) => setState(() =>
                            _selectedCategoryId = _selectedCategoryId == cat.id ? null : cat.id),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        selectedColor: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: _selectedCategoryId == cat.id
                              ? const Color(0xFF7C4DFF)
                              : Colors.white12,
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
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white24),
                    const SizedBox(height: 12),
                    Text('Error al cargar el foro', style: AppTextStyles.titleMedium.copyWith(color: Colors.white54)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(forumThreadsProvider(_selectedCategoryId)),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C4DFF), foregroundColor: Colors.white),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (threads) {
                if (threads.isEmpty) return _buildEmpty();
                return RefreshIndicator(
                  color: const Color(0xFF7C4DFF),
                  onRefresh: () => ref.refresh(forumThreadsProvider(_selectedCategoryId).future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.forum_outlined, size: 56, color: Color(0xFF7C4DFF)),
          ),
          const SizedBox(height: 20),
          Text('No hay temas aún', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('¡Crea el primer tema!',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
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
    return GlassContainer(
      opacity: 0.08,
      blur: 10,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: thread.isPinned
              ? const Color(0xFF00B4DB).withValues(alpha: 0.15)
              : const Color(0xFF7C4DFF).withValues(alpha: 0.15),
          child: Icon(
            thread.isPinned ? Icons.push_pin_rounded : Icons.forum_outlined,
            size: 22,
            color: thread.isPinned ? const Color(0xFF00B4DB) : const Color(0xFF7C4DFF),
          ),
        ),
        title: Text(thread.title,
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Flexible(
                child: Text(thread.authorName, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: Colors.white54)),
              ),
              if (thread.categoryName.isNotEmpty) ...[
                Text(' · ', style: AppTextStyles.bodySmall.copyWith(color: Colors.white24)),
                Flexible(
                  child: Text(thread.categoryName, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.white24),
              const SizedBox(width: 4),
              Text('${thread.views}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
              const SizedBox(width: 12),
              const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.white24),
              const SizedBox(width: 4),
              Text('${thread.postCount}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
            ],
          ),
        ),
        trailing: thread.isPinned
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4DB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Fijado', style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF00B4DB), fontWeight: FontWeight.bold, fontSize: 10)),
              )
            : const Icon(Icons.chevron_right_rounded, color: Colors.white24),
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

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, 
          MediaQuery.of(context).viewInsets.bottom + 32
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nuevo Tema', 
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                )
              ),
              const SizedBox(height: 8),
              Text(
                'Comparte tus dudas o conocimientos con la comunidad.',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 32),
              
              categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error cargando categorías', style: TextStyle(color: Colors.redAccent)),
                data: (categories) => DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  dropdownColor: const Color(0xFF2A2D3E),
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  decoration: _inputDecoration('Seleccionar categoría', Icons.category_outlined),
                  items: categories.map((c) => DropdownMenuItem(
                    value: c.id, 
                    child: Text(c.name)
                  )).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                decoration: _inputDecoration('Título del tema', Icons.title_rounded),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyCtrl,
                maxLines: 4,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                decoration: _inputDecoration('Escribe tu mensaje...', Icons.text_fields_rounded),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_loading || _categoryId == null || _titleCtrl.text.trim().isEmpty)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('PUBLICAR TEMA', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white24),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _submit() async {
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.thread.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Thread header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E).withValues(alpha: 0.5),
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.thread.body, 
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, height: 1.6)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                          child: const Icon(Icons.person_outline, size: 14, color: Color(0xFF7C4DFF)),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.thread.authorName,
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: Colors.white70)),
                        const Spacer(),
                        const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.white24),
                        const SizedBox(width: 4),
                        Text('${widget.thread.views} vistas', 
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
                      ],
                    ),
                  ],
                ),
              ),

              // Posts
              Expanded(
                child: postsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white54))),
                  data: (posts) {
                    final visible = posts.where((p) => !p.isDeleted).toList();
                    if (visible.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.white.withValues(alpha: 0.05)),
                            const SizedBox(height: 16),
                            Text('No hay respuestas aún',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white24)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: visible.length,
                      itemBuilder: (ctx, i) => _ForumPostCard(post: visible[i]),
                    );
                  },
                ),
              ),
            ],
          ),

          // Reply input
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F111A).withValues(alpha: 0.8),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyCtrl,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Escribe una respuesta...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                        ),
                        child: IconButton(
                          onPressed: _sendReply,
                          icon: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      await ref.read(socialRepositoryProvider).createForumPost(
            threadId: widget.thread.id,
            body: text,
          );
      _replyCtrl.clear();
      ref.invalidate(forumPostsProvider(widget.thread.id));
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}

class _ForumPostCard extends StatelessWidget {
  const _ForumPostCard({required this.post});
  final ForumPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                child: Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                  style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF7C4DFF), fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(post.authorName,
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              if (post.reactionCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_rounded, size: 12, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Text('${post.reactionCount}', 
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white54, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.body, style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
