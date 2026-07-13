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

class _CommunityScreenState extends ConsumerState<CommunityScreen> with AutomaticKeepAliveClientMixin {
  int? _selectedCategoryId;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Importante para KeepAlive
    final categoriesAsync = ref.watch(forumCategoriesProvider);
    final threadsAsync = ref.watch(forumThreadsProvider(_selectedCategoryId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2575FC).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => _showCreateDialog(context, ref),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('NUEVO TEMA',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                )),
          ),
        ),
      ),
      body: Column(
        children: [
          categoriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: FilterChip(
                        label: Text('Todos',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _selectedCategoryId == null ? Colors.white : (isDark ? Colors.white38 : Colors.black45),
                              fontWeight: FontWeight.w800,
                            )),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) => setState(() => _selectedCategoryId = null),
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        selectedColor: const Color(0xFF6A11CB),
                        showCheckmark: false,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: FilterChip(
                        label: Text(cat.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _selectedCategoryId == cat.id ? Colors.white : (isDark ? Colors.white38 : Colors.black45),
                              fontWeight: FontWeight.w800,
                            )),
                        selected: _selectedCategoryId == cat.id,
                        onSelected: (_) => setState(() =>
                            _selectedCategoryId = _selectedCategoryId == cat.id ? null : cat.id),
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        selectedColor: const Color(0xFF6A11CB),
                        showCheckmark: false,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    )),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: threadsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6A11CB))),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 12),
                    Text('Error al cargar el foro',
                        style: AppTextStyles.titleMedium.copyWith(color: subtextColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                      ),
                      child: FilledButton(
                        onPressed: () => ref.invalidate(forumThreadsProvider(_selectedCategoryId)),
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
              ),
              data: (threads) {
                if (threads.isEmpty) return _buildEmpty(textColor, subtextColor);
                return RefreshIndicator(
                  color: const Color(0xFF6A11CB),
                  onRefresh: () => ref.refresh(forumThreadsProvider(_selectedCategoryId).future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
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

  Widget _buildEmpty(Color textColor, Color subtextColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6A11CB).withValues(alpha: 0.1),
                  const Color(0xFF2575FC).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(Icons.forum_outlined, size: 56, color: Color(0xFF2575FC)),
          ),
          const SizedBox(height: 24),
          Text('No hay temas aún',
              style: AppTextStyles.headlineSmall.copyWith(
                color: textColor, 
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 8),
          Text('¡Crea el primer tema!',
              style: AppTextStyles.bodyMedium.copyWith(color: subtextColor)),
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
        onCreated: () => ref.invalidate(forumThreadsProvider(_selectedCategoryId)),
      ),
    );
  }

  void _showThreadPosts(BuildContext context, ForumThread thread) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => _ForumThreadDetailScreen(thread: thread)));
  }
}

class _ForumThreadCard extends StatelessWidget {
  const _ForumThreadCard({required this.thread, required this.onTap});
  final ForumThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final iconFadeColor = isDark ? Colors.white24 : Colors.black26;
    final statColor = isDark ? Colors.white38 : Colors.black38;

    return GlassContainer(
      opacity: isDark ? 0.06 : 0.08,
      blur: 24,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: thread.isPinned
                  ? [const Color(0xFF00B4DB), const Color(0xFF0083B0)]
                  : [const Color(0xFF6A11CB).withValues(alpha: 0.1), const Color(0xFF2575FC).withValues(alpha: 0.1)],
            ),
          ),
          child: Icon(
            thread.isPinned ? Icons.push_pin_rounded : Icons.forum_outlined,
            size: 24,
            color: thread.isPinned ? Colors.white : const Color(0xFF2575FC),
          ),
        ),
        title: Text(thread.title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w800, 
              color: textColor,
              letterSpacing: -0.3,
            )),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Flexible(
                child: Text(thread.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700, color: subtextColor)),
              ),
              if (thread.categoryName.isNotEmpty) ...[
                Text(' · ', style: AppTextStyles.bodySmall.copyWith(color: iconFadeColor)),
                Flexible(
                  child: Text(thread.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF2575FC), fontWeight: FontWeight.w900)),
                ),
              ],
              const SizedBox(width: 8),
              Icon(Icons.remove_red_eye_outlined, size: 14, color: iconFadeColor),
              const SizedBox(width: 4),
              Text('${thread.views}', style: AppTextStyles.bodySmall.copyWith(color: statColor, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Icon(Icons.chat_bubble_outline_rounded, size: 14, color: iconFadeColor),
              const SizedBox(width: 4),
              Text('${thread.postCount}', style: AppTextStyles.bodySmall.copyWith(color: statColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: iconFadeColor, size: 22),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E2E).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.97);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Nuevo Tema',
                    style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Comparte tus dudas o conocimientos con la comunidad.',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54)),
                const SizedBox(height: 32),
                categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (categories) => categories.isEmpty
                      ? const SizedBox.shrink()
                      : DropdownButtonFormField<int>(
                          initialValue: _categoryId,
                          dropdownColor: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                          style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                          decoration: _inputDecoration('Categoría (opcional)', Icons.category_outlined, isDark),
                          items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (v) => setState(() => _categoryId = v),
                        ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleCtrl,
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                  decoration: _inputDecoration('Título del tema', Icons.title_rounded, isDark),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bodyCtrl,
                  maxLines: 4,
                  style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                  decoration: _inputDecoration('Escribe tu mensaje...', Icons.text_fields_rounded, isDark),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 58,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2575FC).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text('PUBLICAR TEMA',
                              style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isDark) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5), size: 20),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3)),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2575FC), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    
    // Si no hay categoría seleccionada, intentar obtener la primera disponible
    int? categoryId = _categoryId;
    if (categoryId == null) {
      final categoriesAsync = ref.read(forumCategoriesProvider);
      categoryId = categoriesAsync.value?.isNotEmpty == true 
          ? categoriesAsync.value!.first.id 
          : null;
    }

    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(socialRepositoryProvider).createForumThread(
            categoryId: categoryId,
            title: _titleCtrl.text.trim(),
            body: _bodyCtrl.text.trim(),
          );
      ref.invalidate(forumThreadsProvider(widget.selectedCategoryId));
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
  ConsumerState<_ForumThreadDetailScreen> createState() =>
      _ForumThreadDetailScreenState();
}

class _ForumThreadDetailScreenState
    extends ConsumerState<_ForumThreadDetailScreen> {
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider(widget.thread.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final fadeColor = isDark ? Colors.white24 : Colors.black26;
    final statColor = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.thread.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge.copyWith(
                color: textColor, fontWeight: FontWeight.w800)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              GlassContainer(
                opacity: isDark ? 0.08 : 0.05,
                blur: 20,
                borderRadius: BorderRadius.zero,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.thread.body,
                        style: AppTextStyles.bodyLarge.copyWith(color: textColor, height: 1.6, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                          ),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: isDark ? Colors.black26 : Colors.white,
                            child: const Icon(Icons.person_rounded, size: 14, color: Color(0xFF6A11CB)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(widget.thread.authorName,
                            style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w800, color: subtextColor)),
                        const Spacer(),
                        Icon(Icons.remove_red_eye_outlined, size: 14, color: fadeColor),
                        const SizedBox(width: 4),
                        Text('${widget.thread.views} vistas',
                            style: AppTextStyles.bodySmall.copyWith(color: statColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: postsAsync.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C4DFF))),
                  error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
                  data: (posts) {
                    final visible = posts.where((p) => !p.isDeleted).toList();
                    if (visible.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: fadeColor),
                            const SizedBox(height: 16),
                            Text('No hay respuestas aún',
                                style: AppTextStyles.bodyMedium.copyWith(color: statColor)),
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
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.85),
                    border: Border(
                        top: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyCtrl,
                          style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Escribe una respuesta...',
                            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
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
      if (mounted) _replyCtrl.clear();
      if (mounted) ref.invalidate(forumPostsProvider(widget.thread.id));
      if (mounted) FocusScope.of(context).unfocus();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        opacity: isDark ? 0.05 : 0.08,
        blur: 20,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: isDark ? Colors.black26 : Colors.white,
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF6A11CB), fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(post.authorName,
                      style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w900, color: textColor)),
                ),
                if (post.reactionCount > 0)
                  GlassContainer(
                    opacity: 0.1,
                    blur: 0,
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded, size: 12, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text('${post.reactionCount}',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.body,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: bodyColor, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
